module EndpointHelper
  def class_for_criteria(score)
    case score
    when 0..19
      'poor'
    when 20..39
      'below_average'
    when 40..59
      'average'
    when 60..79
      'good'
    else
      'excellent'
    end
  end

  def log_title(measurement)
    case measurement&.name
    when 'availability.alive'
      'Availability / Alive'
    when 'freshness.last_updated'
      'Freshness / Last Updated'
    when 'operation.service_description'
      'Operation / Service Description'
    when 'operation.void'
      'Operation / VoID'
    when 'usefulness.metadata'
      'Usefulness / Metadata'
    when 'usefulness.ontology'
      'Usefulness / Ontology'
    when 'usefulness.links_to_other_datasets'
      'Usefulness / Links to Other Dataset'
    when 'usefulness.data_entry'
      'Usefulness / Data Entry'
    when 'usefulness.support_html_format'
      'Usefulness / Support for HTML Data Format'
    when 'usefulness.support_turtle_format'
      'Usefulness / Support for Turtle Data Format'
    when 'usefulness.support_rdfxml_format'
      'Usefulness / Support for RDF/XML Data Format'
    when 'validity.http_uri'
      'Validity / HTTP URIs are used?'
    when 'validity.provide_useful_information'
      'Validity / URI provides useful information?'
    when 'validity.link_to_other_uri'
      'Validity / Include links to other URIs?'
    when 'validity.cool_uri'
      'Validity / Cool URI'
    when 'performance.execution_time'
      'Performance / Execution Time'
    else
      'Unknown'
    end
  end
end
