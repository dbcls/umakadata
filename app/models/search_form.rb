class SearchForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :name, :string
  attribute :resource_uri, :string
  attribute :date, :date
  attribute :rank, array: :string
  attribute :score_lower, :integer
  attribute :score_upper, :integer
  attribute :alive_rate_lower, :float
  attribute :alive_rate_upper, :float
  attribute :cool_uri_rate_lower, :integer
  attribute :cool_uri_rate_upper, :integer
  attribute :ontology_lower, :integer
  attribute :ontology_upper, :integer
  attribute :metadata_lower, :integer
  attribute :metadata_upper, :integer
  attribute :service_description, :boolean
  attribute :void, :boolean
  attribute :content_negotiation, :boolean
  attribute :html, :boolean
  attribute :turtle, :boolean
  attribute :xml, :boolean

  def search
    raise 'Missing value: date' unless date.present?

    @endpoint = Endpoint
                  .eager_load(:evaluations, :resource_uris)
                  .where(evaluations: { crawl_id: (crawl_id = Crawl.find_by(started_at: date.all_day)) })

    add_condition_for_name(name) if name.present?
    add_condition_for_resource_uri(resource_uri) if resource_uri.present?
    add_condition_for_rank(*rank) if rank.present?
    add_range_condition('evaluations.score', score_lower, score_upper)
    add_range_condition('evaluations.alive_rate', alive_rate_lower, alive_rate_upper)
    add_range_condition('evaluations.cool_uri', cool_uri_rate_lower, cool_uri_rate_upper)
    add_range_condition('evaluations.ontology', ontology_lower, ontology_upper)
    add_range_condition('evaluations.metadata', metadata_lower, metadata_upper)
    add_is_true_condition('evaluations.service_description') if service_description.present?
    add_is_true_condition('evaluations.void') if void.present?
    add_is_true_condition('evaluations.support_html_format') if html.present?
    add_is_true_condition('evaluations.support_turtle_format') if turtle.present?
    add_is_true_condition('evaluations.support_rdfxml_format') if xml.present?

    Endpoint
      .eager_load(:evaluations)
      .where(id: @endpoint.pluck(:id))
      .where(evaluations: { crawl_id: crawl_id })
      .order(score: :desc)
  end

  private

  NAME_CONDITION = 'LOWER(endpoints.name) LIKE ? OR LOWER(endpoints.endpoint_url) LIKE ?'.freeze

  def add_condition_for_name(value)
    @endpoint = @endpoint.where(NAME_CONDITION, "%#{value.downcase}%", "%#{value.downcase}%")
  end

  RESOURCE_URI_CONDITION = 'LOWER(resource_uris.uri) LIKE ? OR LOWER(resource_uris.allow) LIKE ?'.freeze

  def add_condition_for_resource_uri(value)
    @endpoint = @endpoint.where(RESOURCE_URI_CONDITION, "%#{value.downcase}%", "%#{value.downcase}%")
  end

  def add_condition_for_rank(*value)
    @endpoint = @endpoint.where(evaluations: { rank: value.map { |x| Evaluation.rank_number(x) }.compact })
  end

  def add_range_condition(column, lower, upper)
    return if lower.blank? && upper.blank?

    @endpoint = @endpoint.where("#{column} <= ?", "#{upper}") if upper.present?
    @endpoint = @endpoint.where("#{column} >= ?", "#{lower}") if lower.present?
  end

  def add_is_true_condition(column)
    @endpoint = @endpoint.where(column => true)
  end
end
