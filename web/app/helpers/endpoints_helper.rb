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

  def twitter_widget
    url = 'https://twitter.com/umakayummy?ref_src=twsrc%5Etfw'
    options = { class: 'twitter-timeline', data: { height: 600 } }
    js = 'https://platform.twitter.com/widgets.js'
    content_tag :div do
      concat link_to 'Tweets by umakayummy', url, options
      concat javascript_include_tag js, cache: true, async: true, charset: 'utf-8'
    end
  end
end
