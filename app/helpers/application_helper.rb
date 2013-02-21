module ApplicationHelper
  def title(page_title)
    content_for(:title) { page_title }
  end

  #shorthand for the required asterisk
  def required
    "<span class='asterisk' title='Required'>*</span>".html_safe
  end

  # convenience method to render a field on a view screen - saves repeating the div/span etc each time
  def render_field(label, value)
    render_field_content(label, (h value))
  end

  def render_field_if_not_empty(label, value)
    render_field_content(label, (h value)) unless value.blank?
  end

  def icon(type)
    "<img src='/images/icon_#{type}.png' border=0 class='icon' alt='#{type}' />".html_safe
  end

  # as above but takes a block for the field value
  def render_field_with_block(label, &block)
    content = with_output_buffer(&block)
    render_field_content(label, content)
  end

  def cancel_button(link_text, path, options = {})
    link_to(h(link_text), path, options.merge(:class => "btn")).html_safe
  end

  private
  def render_field_content(label, content)
    div_id = label.tr(" ,", "_").downcase
    html = "<div class='control-group'>"
    html << "<label class='control-label'>"
    html << (h label)
    html << ":"
    html << '</label>'
    html << "<div class='controls'>"
    html << "<div class='record' id='#{div_id + '_display'}'>"
    html << content
    html << '</div>'
    html << '</div>'
    html << '</div>'
    html.html_safe
  end


  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = (column == sort_column) ? "sort_link current #{sort_direction}" : "sort_link"
    direction = (column == sort_column && sort_direction == "asc") ? "desc" : "asc"
    link_to title, "", {:"data-sort" => column, :"data-direction" => direction, :class => css_class}
  end
 #def sortable(column, title = nil)
 #   title ||= column.titleize
 #   css_class = (column == sort_column) ? "current #{sort_direction}" : nil
 #   direction = (column == sort_column && sort_direction == "asc") ? "desc" : "asc"
 #   link_to title, params.merge(:sort => column, :direction => direction), {:class => css_class}
 # end

end
