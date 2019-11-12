class Endpoint < ApplicationRecord
  has_many :dataset_relations
  has_many :evaluations
  has_many :excluding_graphs
  has_many :resource_uris, class_name: ResourceURI.name
  has_many :vocabulary_prefixes

  scope :active, -> { where(enabled: true) }

  def latest_alive_evaluation
    evaluations.where(alive: true).order(created_at: :desc).limit(1).first
  end

  def just_registered?
    created_at > Date.current.ago(3.days) && evaluations.count.zero?
  end

  def dead?
    (xs = evaluations.order(created_at: :desc).limit(3)).present? && xs.all? { |x| x.alive == false }
  end

  def update_vocabulary_prefixes!(*prefixes)
    return unless prefixes.present?

    transaction do
      prefixes = prefixes.dup
      vocabulary_prefixes.each do |vp|
        if prefixes.delete(vp.uri)
          vp.update!(updated_at: Time.current)
          next
        end
        vp.destroy!
      end

      prefixes.each do |p|
        VocabularyPrefix.create!(uri: p, endpoint: self)
      end
    end
  end

  module GitHubMethods
    COLORS = %w[000000 f0f8ff 008b8b ffffe0 ff7f50 696969 e6e6fa 008080 fafad2 ff6347 808080 b0c4de 2f4f4f fffacd ff4500
                a9a9a9 778899 006400 f5deb3 ff0000 c0c0c0 708090 008000 deb887 dc143c d3d3d3 4682b4 228b22 d2b48c c71585
                dcdcdc 4169e1 2e8b57 f0e68c ff1493 f5f5f5 191970 3cb371 ffff00 ff69b4 ffffff 000080 66cdaa ffd700 db7093
                fffafa 00008b 8fbc8f ffa500 ffc0cb f8f8ff 0000cd 7fffd4 f4a460 ffb6c1 fffaf0 0000ff 98fb98 ff8c00 d8bfd8
                faf0e6 1e90ff 90ee90 daa520 ff00ff faebd7 6495ed 00ff7f cd853f ff00ff ffefd5 00bfff 00fa9a b8860b ee82ee
                ffebcd 87cefa 7cfc00 d2691e dda0dd ffe4c4 87ceeb 7fff00 a0522d da70d6 ffe4b5 add8e6 adff2f 8b4513 ba55d3
                ffdead b0e0e6 00ff00 800000 9932cc ffdab9 afeeee 32cd32 8b0000 9400d3 ffe4e1 e0ffff 9acd32 a52a2a 8b008b
                fff0f5 00ffff 556b2f b22222 800080 fff5ee 00ffff 6b8e23 cd5c5c 4b0082 fdf5e6 40e0d0 808000 bc8f8f 483d8b
                fffff0 48d1cc bdb76b e9967a 8a2be2 f0fff0 00ced1 eee8aa f08080 9370db f5fffa 20b2aa fff8dc fa8072 6a5acd
                f0ffff 5f9ea0 f5f5dc ffa07a 7b68ee].freeze

    def create_label
      name = id.to_s
      label = if GithubHelper.label_exists?(name)
                GithubHelper.get_label(name)
              else
                GithubHelper.add_label(name, COLORS[(id - 1) % COLORS.size])
              end

      update(label_id: label[:id]) unless label.nil?

      label
    end

    def create_issue
      raise(StandardError, "issue for #{name} already exists") if GithubHelper.issue_exists?(name)

      issue = GithubHelper.create_issue(name)
      update(issue_id: issue[:number]) unless issue.nil?

      issue
    end

    def sync_label
      labels = GithubHelper.labels_for_issue(issue_id)
      label = labels.select { |label| label[:id] == label_id }.first

      raise(StandardError, "issue for #{name} does not have a label") if label.nil?

      GithubHelper.update_label(label[:name], name: id.to_s)
    end
  end

  include GitHubMethods
end
