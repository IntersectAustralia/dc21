class Admin::ConfigController < ApplicationController

  # load_and_authorize_resource :system_configuration
  before_filter :authenticate_user!
  before_filter :authorize_admin
  layout 'admin'
  set_tab :admin

  def index
    set_tab :systemconfig, :contentnavigation
  end

  def edit
    set_tab :systemconfig, :contentnavigation
  end

  def update
    puts @config.inspect
    puts params.inspect

    respond_to do |format|
      if @config.update_attributes(params[:system_configuration])
        format.html { redirect_to edit_admin_config_path, notice: 'System name updated.' }
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

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_group_params
#      params[:group]
      params.require(:name).permit!  #very bad lazy thing todo
    end

end
