module ApplicationHelper

  def createRowRecursive(key, content, id, parent_id)
    if content.is_a?(Hash)
      data = {'tt-id' => id, 'tt-parent-id' => parent_id}
      content_tag(:tr, class: ["active"], data: data) do
        if key.nil?
          concat content_tag(:td, (content.has_key?('result') ? content['result'] : ''), :colspan => '2')
        else
          concat content_tag(:td, key)
          concat content_tag(:td)
        end
        parent_id = id
        i = 0
        content.each do |key, value|
          next if key == "result"
          result = createRowRecursive(key, value, "#{parent_id}_#{i += 1}", parent_id)
          concat result unless result.nil?
        end
      end
    elsif content.is_a?(Array)
      i = 0
      if content.size == 1 && !content[0].has_key?('result')
        content[0].each do |key, value|
          result = createRowRecursive(key, value, "#{parent_id}_#{i += 1}", parent_id)
          concat result unless result.nil?
        end
      else
        content.each do |log|
          result = createRowRecursive(nil, log, "#{parent_id}_#{i += 1}", parent_id)
          concat result unless result.nil?
        end
      end
      nil
    else
      data = {'tt-id' => id, 'tt-parent-id' => parent_id}
      content_tag(:tr, data: data) do
        concat content_tag(:td, key)
        concat content_tag(:td, content)
      end
    end
  end

end
