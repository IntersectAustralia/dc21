class Ability
  include CanCan::Ability

  def initialize(user)

    # alias edit_role to update_role so that they don't have to be declared separately
    alias_action :edit_role, :to => :update_role
    alias_action :edit_approval, :to => :approve

    # alias activate and deactivate to "activate_deactivate" so its just a single permission
    alias_action :deactivate, :to => :activate_deactivate
    alias_action :activate, :to => :activate_deactivate

    # alias access_requests to view_access_requests so the permission name is more meaningful
    alias_action :access_requests, :to => :admin

    # alias reject_as_spam to reject so they are considered the same
    alias_action :reject_as_spam, :to => :reject

    # alias search to read
    alias_action :search, :to => :read

    # alias clear to read
    alias_action :clear, :to => :read

    return unless user && user.role

    can :manage, Facility
    can :manage, Experiment
    can :manage, ExperimentParameter
    can :manage, ColumnMapping

    # all users can read and add data files, and can delete their own. This *could* be expressed more simply,
    #   but shouldn't until we actually have explicitly defined permissions and roles
    can :index, DataFile
    can [:show,
         :create, #new, create
         :download,
         :download_selected,
         :bulk_update,
         :api_create,
         :api_search,
         :process_metadata_extraction], DataFile do |datafile|
      datafile.is_authorised_for_access_by?(user)
    end
    can :destroy, DataFile, :created_by_id => user.id, :published => false
    can :update, DataFile, :created_by_id => user.id, :published => false
    cannot :update, DataFile do |datafile|
      datafile.is_error_file?
    end

    if user.role.admin?
      # only admins can manage users
      can :read, User
      can :update_role, User
      can :activate_deactivate, User
      can :admin, User
      can :reject, User
      can :approve, User
      can :add_access_group_to, User
      can :remove_access_group_from, User

      can :manage, DataFile
      cannot :update, DataFile do |datafile|
        datafile.is_error_file?
      end

      can :manage, SystemConfiguration
      can :manage, AccessGroup
    end

  end
end
