class SearchTabBuilder < TabsOnRails::Tabs::Builder
  def tab_for(tab, name, options, item_options = {})
    item_options[:class] = 'active' if current_tab?(tab)
    @context.content_tag(:li, name, item_options) do
      @context.content_tag(:input, name, options)
    end
  end
end
