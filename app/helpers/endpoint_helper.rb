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
end
