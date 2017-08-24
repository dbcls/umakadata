module EndpointsHelper

  def format_text(str)
    html_escape(str).gsub(/\t/, "&nbsp;" * 4).gsub(/\r\n|\r|\n/, "<br />").html_safe
  end

  def show_rank(rank)
    case rank
    when 1 then 'E'
    when 2 then 'D'
    when 3 then 'C'
    when 4 then 'B'
    when 5 then 'A'
    else '-'
    end
  end

end
