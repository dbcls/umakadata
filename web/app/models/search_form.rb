class SearchForm
  include ActiveModel::Model

  attr_accessor :name, :prefix, :date, :score_lower, :score_upper, :alive_rate_lower, :alive_rate_upper,
                :rank, :cool_uri_rate_lower, :cool_uri_rate_upper, :ontology_lower, :ontology_upper,
                :metadata_lower, :metadata_upper, :service_description, :void, :content_negotiation,
                :html, :turtle, :xml, :element_type, :prefix_filter_uri, :prefix_filter_uri_fragment

  def search
    @endpoints = Endpoint.joins(:evaluation).eager_load(:evaluation).order('evaluations.score DESC')
    @endpoints = @endpoints.includes(:prefixes) unless prefix.blank?
    add_like_condition_for_name_url(name) if !name.blank?
    add_like_condition_for_prefix(prefix) if !prefix.blank?
    add_date_condition(date.blank? ? Endpoint.get_last_crawled_date.to_s : date)
    add_range_condition('evaluations.score', score_lower, score_upper)
    add_range_condition('evaluations.alive_rate', alive_rate_lower, alive_rate_upper)
    add_rank_condition('evaluations.rank', rank) if !rank.blank?
    add_range_condition('evaluations.cool_uri_rate', cool_uri_rate_lower, cool_uri_rate_upper)
    add_range_condition('evaluations.ontology_score', ontology_lower, ontology_upper)
    add_range_condition('evaluations.metadata_score', metadata_lower, metadata_upper)
    add_is_not_empty_condition('evaluations.service_description') if !service_description.blank?
    add_is_not_empty_condition('evaluations.void_ttl') if !void.blank?
    add_is_true_condition('evaluations.support_content_negotiation') if !content_negotiation.blank?
    add_is_true_condition('evaluations.support_html_format') if !html.blank?
    add_is_true_condition('evaluations.support_turtle_format') if !turtle.blank?
    add_is_true_condition('evaluations.support_xml_format') if !xml.blank?
    add_equal_condition_for_prefix_filter(element_type, prefix_filter_uri, prefix_filter_uri_fragment) if element_type.present? && prefix_filter_uri.present?

    @endpoints
  end

  private

  def add_like_condition_for_name_url(value)
    @endpoints = @endpoints.where("LOWER(name) LIKE ? OR LOWER(url) LIKE ?", "%#{value.downcase}%", "%#{value.downcase}%")
  end

  def add_like_condition_for_prefix(value)
    @endpoints = @endpoints.where("LOWER(prefixes.allow_regex) LIKE ?", "%#{value.downcase}%")
  end

  def add_is_not_empty_condition(column)
    @endpoints = @endpoints.where("#{column} IS NOT NULL AND #{column} <> ''")
  end

  def add_is_true_condition(column)
    @endpoints = @endpoints.where(column => true)
  end

  def add_equal_condition(column, value)
    @endpoints = @endpoints.where(column => value)
  end

  def add_rank_condition(column, value)
    rank_values = { 'A' => 5, 'B' => 4, 'C' => 3, 'D' => 2, 'E' => 1 }
    add_equal_condition(column, rank_values[value]) unless rank_values[value].nil?
  end

  def add_date_condition(value)
    begin
      date = Time.zone.parse(value)
      @endpoints = @endpoints.retrieved_at(date)
    rescue
    end
  end

  def add_range_condition(column, lower, upper)
    if lower.blank? && upper.blank?
      return
    elsif lower.blank?
      @endpoints = @endpoints.where("#{column} <= ?", "#{upper}")
    elsif upper.blank?
      @endpoints = @endpoints.where("#{column} >= ?", "#{lower}")
    else
      @endpoints = @endpoints.where(column => Range.new(lower, upper))
    end
  end

  def add_equal_condition_for_prefix_filter(element_type, uri, fragment)
    identifier = "##{fragment}" unless fragment.blank?
    input_uri = "#{uri}#{identifier}"
    uri_obj = URI(uri)
    domain = uri_obj.scheme + "://" + uri_obj.host
    prefix_filters = PrefixFilter.where(element_type: element_type).where('uri LIKE ?', "#{domain}%")
    endpoint_ids = prefix_filters.select{|prefix_filter| input_uri =~ /#{prefix_filter.uri}.*/}.map(&:endpoint_id)
    add_equal_condition(:id, endpoint_ids)
    filter_endpoints_with_sparql_query(element_type, input_uri)
  end


  def filter_endpoints_with_sparql_query(element_type, uri)
    query = create_filter_endpoints_query(element_type, uri)
    endpoint_ids = Array.new
    @endpoints.each do |endpoint|
      [:post, :get].each do |method|
        response = Umakadata::SparqlHelper.query(URI(endpoint.url), query, logger: nil, options: {method: method})
        if !response.nil? && response.length > 0
          endpoint_ids.push endpoint.id
          break
        end
      end
    end
    add_equal_condition(:id, endpoint_ids)
  end

  def create_filter_endpoints_query(element_type, uri)
    case element_type
    when 'subject'
      subject = "<#{uri}>"
      object = "?o"
    when 'object'
      subject = '?s'
      object = "<#{uri}>"
    end
    <<-SPARQL
SELECT
  *
WHERE
  {
    #{subject} ?p #{object}
  }
LIMIT 1
    SPARQL

  end

end