class Endpoint < ApplicationRecord
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
end
