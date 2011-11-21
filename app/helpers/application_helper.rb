module ApplicationHelper
  def title(page_title)
    content_for(:title) { page_title }
  end

  #shorthand for the required asterisk
  def required
    "<a class='asterisk_icon' title='Required'></a>".html_safe
  end

  # convenience method to render a field on a view screen - saves repeating the div/span etc each time
  def render_field(label, value)
    render_field_content(label, (h value))
  end

  def render_field_if_not_empty(label, value)
    render_field_content(label, (h value)) if value != nil && !value.empty?
  end

  def icon(type)
    "<img src='/images/icon_#{type}.png' border=0 class='icon' alt='#{type}' />".html_safe
  end

  # as above but takes a block for the field value
  def render_field_with_block(label, &block)
    content = with_output_buffer(&block)
    render_field_content(label, content)
  end

  private
  def render_field_content(label, content)
    div_class = cycle("field_bg","field_nobg")
    div_id = label.tr(" ,", "_").downcase
    html = "<div class='#{div_class} row' id='display_#{div_id}'>"
    html << '<label>'
    html << (h label)
    html << ":"
    html << '</label>'
    html << '<span>'
    html << content
    html << '</span>'
    html << '</div>'
    html.html_safe
  end


end
