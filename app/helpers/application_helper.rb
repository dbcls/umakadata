module ApplicationHelper
  def title(str = nil)
    title = 'Umaka Data'
    title << " | #{str}" if str.present?

    title
  end
end
