module EndpointsHelper

  def format_text(str) 
    html_escape(str).gsub(/\t/, "&nbsp;" * 4).gsub(/\r\n|\r|\n/, "<br />").html_safe
  end

end
