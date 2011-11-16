class ApplicationController < ActionController::Base
  protect_from_forgery
  # catch access denied and redirect to the home page
  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = exception.message
    redirect_to root_url
  end
end

class MenuTabBuilder < TabsOnRails::Tabs::Builder
  def tab_for(tab, name, options, item_options = {})
    item_options[:class] = 'active' if current_tab?(tab)
    @context.content_tag(:li, item_options) do
      @context.link_to(name, options)
    end
  end
end

class AccountTabBuilder < TabsOnRails::Tabs::Builder
  def tab_for(tab, name, options, item_options = {})
    item_options[:class] = 'active' if current_tab?(tab)
    @context.content_tag(:li, name, item_options) do
      @context.content_tag(:span, name, options)
    end
  end
end

class SearchTabBuilder < TabsOnRails::Tabs::Builder
  def tab_for(tab, name, options, item_options = {})
    item_options[:class] = 'active' if current_tab?(tab)
    @context.content_tag(:li, name, item_options) do
      @context.content_tag(:input, name, options)
    end
  end
end
