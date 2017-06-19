class Endpoint < ActiveRecord::Base

  has_many :evaluations
  has_many :prefixes
  has_many :relations
  has_many :prefix_filters
  has_one :evaluation

  validates :name, uniqueness: true
  validates :url, uniqueness: true
  validates :url, format: /\A#{URI::regexp(%w(http https))}\z/, if: 'url.present?'
  validates :description_url, format: /\A#{URI::regexp(%w(http https))}\z/, if: 'description_url.present?'

  scope :created_at, ->(date) { where('evaluations.created_at': date) }

  RETRIEVED_DATE = 'date(evaluations.retrieved_at)'.freeze

  def self.rdf_graph
    endpoints = self.thin_out_attributes
    UmakaRDF.build(endpoints)
  end

  def self.thin_out_attributes
    endpoints = []
    all.each do |endpoint|
      hash = endpoint.attributes
      hash['evaluation'] = endpoint.evaluation.attributes.select {|key, value| /_log$/ !~ key }
      endpoints << hash
    end
    endpoints
  end

  def self.to_jsonld
    self.rdf_graph.dump(:jsonld, prefixes: UmakaRDF.prefixes)
  end

  def self.to_rdfxml
    self.rdf_graph.dump(:rdfxml, prefixes: UmakaRDF.prefixes)
  end

  def self.to_ttl
    self.rdf_graph.dump(:ttl, prefixes: UmakaRDF.prefixes)
  end

  def self.to_pretty_json
    endpoints = self.thin_out_attributes
    JSON.pretty_generate(JSON.parse(endpoints.to_json))
  end

  after_save do
    if self.issue_id.nil?
      issue = GithubHelper.create_issue(self.name)
      self.update_column(:issue_id, issue[:number]) unless issue.nil?

      label = GithubHelper.add_label(self.name.gsub(",", ""), Color.get_color(self.id))
      GithubHelper.add_labels_to_an_issue(issue[:number], [label[:name]])
      self.update_column(:label_id, label[:id]) unless label.nil?
    else
      issue = GithubHelper.edit_issue(self.issue_id, self.name)

      labels = GithubHelper.labels_for_issue(self.issue_id)
      label = labels.select {|label| label[:id] == self.label_id}.first
      GithubHelper.update_label(label[:name], {:name => self.name.gsub(",", "")})
    end
    GithubHelper.add_labels_to_an_issue(self.issue_id, ['endpoints'])
  end

  after_destroy do
    GithubHelper.close_issue(self.issue_id) unless self.issue_id.nil?
  end

  def self.retrieved_at(date)
    self.joins(:evaluation).eager_load(:evaluation).where(evaluations: {retrieved_at: date.all_day})
  end

  def self.alive_statistics_latest_n(date, n)
    data = {}
    data['date'] = self.joins(:evaluation).select(RETRIEVED_DATE).where(Evaluation.arel_table[:retrieved_at].lteq(date.end_of_day)).group(RETRIEVED_DATE).order("#{RETRIEVED_DATE} DESC").limit(n).pluck(RETRIEVED_DATE)
    percentage_of_alive = '(count(evaluations.retrieved_at) * 1.0) / (select count(endpoints.id) from endpoints) * 100'
    data['alive'] = self.joins(:evaluation).where(Evaluation.arel_table[:retrieved_at].lteq(date.end_of_day)).group(RETRIEVED_DATE).where(evaluations: {alive: true}).order("#{RETRIEVED_DATE} DESC").limit(n).pluck("#{RETRIEVED_DATE},#{percentage_of_alive}").to_h
    data
  end

  def self.sd_statistics_latest_n(date, n)
    data = {}
    data['date'] = self.joins(:evaluation).select(RETRIEVED_DATE).where(Evaluation.arel_table[:retrieved_at].lteq(date.end_of_day)).group(RETRIEVED_DATE).order("#{RETRIEVED_DATE} DESC").limit(n).pluck(RETRIEVED_DATE)
    percentage_of_sd = '(count(evaluations.retrieved_at) * 1.0) / (select count(endpoints.id) from endpoints) * 100'
    data['sd'] = self.joins(:evaluation).where(Evaluation.arel_table[:retrieved_at].lteq(date.end_of_day)).group(RETRIEVED_DATE).where.not('evaluations.service_description': [nil,'']).order("#{RETRIEVED_DATE} DESC").limit(n).pluck("#{RETRIEVED_DATE},#{percentage_of_sd}").to_h
    data
  end

  def self.get_last_crawled_date
    endpoint_id_min = self.minimum(:id)
    endpoint_id_max = self.maximum(:id)
    endpoints = self.joins(:evaluation)
    start_or_end_date = endpoints.where(id: endpoint_id_min).order('evaluations.retrieved_at DESC').limit(1).pluck('date(retrieved_at)').first
    end_or_start_date = endpoints.where(id: endpoint_id_max).order('evaluations.retrieved_at DESC').limit(1).pluck('date(retrieved_at)').first
    if start_or_end_date == end_or_start_date
      Time.zone.parse(start_or_end_date.to_s)
    else
      date = endpoints.group('date(evaluations.retrieved_at)').order('date(evaluations.retrieved_at) DESC').limit(2).pluck('date(retrieved_at)').second
      Time.zone.parse(date.to_s)
    end
  end

  def self.score_statistics_lastest_n(date, n)
    data = {}
    data['date'] = self.joins(:evaluation).select(RETRIEVED_DATE).where(Evaluation.arel_table[:retrieved_at].lteq(date.end_of_day)).group(RETRIEVED_DATE).order("#{RETRIEVED_DATE} DESC").limit(n).pluck(RETRIEVED_DATE)
    data['average'] = self.joins(:evaluation).where(Evaluation.arel_table[:retrieved_at].lteq(date.end_of_day)).group(RETRIEVED_DATE).order("#{RETRIEVED_DATE} DESC").limit(n).average('evaluations.score')
    data['median']  = self.joins(:evaluation).where(Evaluation.arel_table[:retrieved_at].lteq(date.end_of_day)).group(RETRIEVED_DATE).order("#{RETRIEVED_DATE} DESC").limit(n).median('evaluations.score')
    data
  end

end
