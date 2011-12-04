class DataController < ApplicationController

  # if there's some other layout that's better for these pages
  #layout 'overview' 

  def upload
      set_tab :home
  end

end
