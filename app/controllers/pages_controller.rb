class PagesController < ApplicationController
  skip_before_filter :authenticate_user!

  def routing_error
    render :file => "#{Rails.root}/public/404.html", :status => 404
  end

  def home
    if !user_signed_in?
      set_tab :login
      render :layout => 'guest' and return
    else
      @action_items = build_action_items
      set_tab :home
      set_tab :dashboard, :contentnavigation
      @data_files = DataFile.most_recent_first.limit(5)
      render :layout => 'main'
    end
  end

  def about
      set_tab :about
      render :layout => 'application'
  end

  private

  #Anythng that we need to alert the user about on the home page
  def build_action_items
    list_of_items = Array.new

    #Missing processing status
    unprocessed_files = DataFile.unprocessed.count
    if unprocessed_files  > 0
      list_of_items << {text: "There are #{unprocessed_files} files missing status or experiment information", link: list_for_post_processing_data_files_path}
    end


    list_of_items
  end

end
