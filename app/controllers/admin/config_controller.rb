class Admin::ConfigController < ApplicationController

  # load_and_authorize_resource :system_configuration
  before_filter :authenticate_user!
  before_filter :authorize_admin
  layout 'admin'
  set_tab :admin

  def show
    set_tab :systemconfig, :contentnavigation
  end

  def edit
    set_tab :systemconfig, :contentnavigation
  end

  def update

    respond_to do |format|
      if params[:system_configuration][:supported_ocr_types].nil?
        params[:system_configuration].merge!(:supported_ocr_types => [])
      end
      if params[:system_configuration][:supported_sr_types].nil?
        params[:system_configuration].merge!(:supported_sr_types => [])
      end
      if @config.update_attributes(params[:system_configuration])
        format.html { redirect_to admin_config_path, notice: 'System configuration updated successfully.' }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  def authorize_admin
    authorize! :manage, @config
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @config =  SystemConfiguration.instance
    end


end
