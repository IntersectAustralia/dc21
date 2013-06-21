class ResqueController < ApplicationController

  before_filter :authenticate_user!
  set_tab :admin
  set_tab :resque, :contentnavigation
  layout 'admin'

  def landing
  end

end