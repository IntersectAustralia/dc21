class Admin::DashboardController < ApplicationController

  # load_and_authorize_resource :system_configuration
  before_filter :authenticate_user!
  before_filter :authorize_admin
  layout 'admin'
  set_tab :admin

  def edit
    set_tab :dashboard, :contentnavigation
    @config =  SystemConfiguration.instance
  end

  def update
    respond_to do |format|
      attributes = params[:system_configuration]

      if @config.update_attributes(attributes)
        format.html { redirect_to root_path, notice: 'Dashboard contents updated successfully.' }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  def authorize_admin
    authorize! :manage, @config
  end
end