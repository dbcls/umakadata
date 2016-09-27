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
    else
      GithubHelper.edit_issue(self.issue_id, self.name)
    end
    GithubHelper.add_labels_to_an_issue(self.issue_id, ['endpoints'])
  end

  after_destroy do
    GithubHelper.close_issue(self.issue_id) unless self.issue_id.nil?
  end

  def self.crawled_at(date)
    day_begin = Time.zone.local(date.year, date.month, date.day, 0, 0, 0)
    day_end = Time.zone.local(date.year, date.mon, date.day, 23, 59, 59)
    self.includes(:evaluation).created_at(day_begin..day_end).references(:evaluation)
  end

  def self.crawled_before(date)
    sql = <<-SQL
    SELECT id
    FROM evaluations AS l
    WHERE id = (
      SELECT id
      FROM evaluations AS r
      WHERE (l.endpoint_id = r.endpoint_id)
      AND (r.created_at <= '#{date.end_of_day}')
      ORDER BY r.created_at DESC
      LIMIT 1
    );
    SQL
    evaluation_ids = Evaluation.find_by_sql(sql).map(&:id)
    self.joins(:evaluation).eager_load(:evaluation).where(evaluations: { id: evaluation_ids })
  end

  def self.alive_statistics_from_to(b, e)
    range = b.beginning_of_day..e.end_of_day
    percentage_of_alive = '(count(evaluations.created_at) * 1.0) / (select count(endpoints.id) from endpoints) * 100'
    self.joins(:evaluation).where(evaluations: {created_at: range, alive: true}).group('date(evaluations.created_at)').pluck("date(evaluations.created_at),#{percentage_of_alive}").to_h
  end

  def self.sd_statistics_from_to(b, e)
    range = b.beginning_of_day..e.end_of_day
    percentage_of_sd = '(count(evaluations.created_at) * 1.0) / (select count(endpoints.id) from endpoints) * 100'
    self.joins(:evaluation).where(evaluations: {created_at: range}).where.not('evaluations.service_description': [nil,'']).group('date(evaluations.created_at)').pluck("date(evaluations.created_at),#{percentage_of_sd}").to_h
  end

  def self.get_last_crawled_date
    endpoints = self.joins(:evaluation)
    start_or_end_datetime = endpoints.first.evaluations.order('created_at DESC').first.created_at
    end_or_start_datetime = endpoints.last.evaluations.order('created_at DESC').first.created_at
    start_or_end_date = start_or_end_datetime.strftime('%Y-%m-%d')
    end_or_start_date = end_or_start_datetime.strftime('%Y-%m-%d')
    if start_or_end_date == end_or_start_date
      Time.parse(start_or_end_date)
    else
      date = endpoints.select('date(evaluations.created_at)').group('date(evaluations.created_at)').order('date(evaluations.created_at) DESC').limit(2)[1].date
      Time.parse(date.to_s)
    end
  end

  def self.score_statistics_from_to(b, e)
    range = b.beginning_of_day..e.end_of_day
    data = {}
    data['average'] = self.joins(:evaluation).where(evaluations: {created_at: range}).group('date(evaluations.created_at)').average('evaluations.score')
    data['median']  = self.joins(:evaluation).where(evaluations: {created_at: range}).group('date(evaluations.created_at)').median('evaluations.score')
    data
  end

end
