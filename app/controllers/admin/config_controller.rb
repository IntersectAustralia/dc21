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
      attributes = params[:system_configuration]

      if attributes[:supported_ocr_types].nil?
        attributes[:supported_ocr_types] = []
      end
      if attributes[:supported_sr_types].nil?
        attributes[:supported_sr_types] = []
      end
      if attributes[:ocr_cloud_token].blank?
        attributes.delete(:ocr_cloud_token)
      end
      if attributes[:sr_cloud_token].blank?
        attributes.delete(:sr_cloud_token)
      end

      if @config.update_attributes(attributes)
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
