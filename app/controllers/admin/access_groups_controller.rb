class Admin::AccessGroupsController < ApplicationController
  load_and_authorize_resource
  before_filter :authenticate_user!
  before_filter :authorize_admin
  layout 'admin'
  set_tab :admin

  def index
    @access_groups = AccessGroup.all
    set_tab :accessgroups, :contentnavigation
  end

  def show
    set_tab :accessgroups, :contentnavigation
    @access_group = AccessGroup.find(params[:id])
  end

  def new
    @access_group = AccessGroup.new
    set_tab :accessgroups, :contentnavigation
  end

  def create
    set_tab :accessgroups, :contentnavigation
    primary_user = params[:primary_user_select]
    params[:access_group][:primary_user] = User.find(primary_user)
    params[:access_group][:user_ids] = params[:user_ids]

    @access_group = AccessGroup.new

    if @access_group.update_attributes(params[:access_group])
      redirect_to admin_access_group_path(@access_group), :notice => "Access group successfully added."
    else
      render 'new'
    end
  end

  def edit
    @access_group = AccessGroup.find(params[:id])
    set_tab :accessgroups, :contentnavigation
  end

  def update
    set_tab :accessgroups, :contentnavigation
    @access_group = AccessGroup.find(params[:id])
    primary_user = params[:primary_user_select]
    params[:access_group][:primary_user] = User.find(primary_user)
    params[:access_group][:user_ids] = params[:user_ids]

    if @access_group.update_attributes(params[:access_group]) #:status => params[:status]) #
      redirect_to admin_access_group_path(@access_group), :notice => "Access group successfully updated."
    else
      render 'edit'
    end
  end

  def authorize_admin
    authorize! :manage, AccessGroup
  end

  def activate
    set_tab :accessgroups, :contentnavigation
    @access_group.activate
    redirect_to(admin_access_groups_path, :notice => "The access group has been activated.")
  end

  def deactivate
    set_tab :accessgroups, :contentnavigation
    @access_group.deactivate
    redirect_to(admin_access_groups_path, :notice => "The access group has been deactivated.")
  end
end