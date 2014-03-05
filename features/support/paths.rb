module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

      when /^the home\s?page$/
        '/'

      # User paths
      when /the login page/
        new_user_session_path

      when /the logout page/
        destroy_user_session_path

      when /the user profile page/
        users_profile_path

      when /the request account page/
        new_user_registration_path

      when /the edit my details page/
        edit_user_registration_path

      when /^the user details page for (.*)$/
        user_path(User.find_by_email!($1))

      when /^the edit role page for (.*)$/
        edit_role_user_path(User.find_by_email!($1))

      when /^the reset password page$/
        edit_user_password_path

      when /the access requests page/
        access_requests_users_path

      when /the list users page/
        users_path

      # Data file paths
      when /the list data files page/
        data_files_path

      when /the data file details page for (.*)$/
        data_file_path(DataFile.find_by_filename($1))

      when /the edit data file page for (.*)$/
        edit_data_file_path(DataFile.find_by_filename($1))

      when /the data file download page for (.*)$/
        download_data_file_path(DataFile.find_by_filename($1))

      when /the upload page/
        new_data_file_path

      when /the bulk update page/
        bulk_update_data_files_path

      # Facility paths
      when /the view facility page for '(.*)'/
        facility_path(Facility.find_by_name($1))

      # Experiment paths
      when /the view experiment page for '(.*)'/
        exp = Experiment.find_by_name!($1)
        facility_experiment_path(exp.facility, exp)

      when /the edit experiment page for '(.*)'/
        exp = Experiment.find_by_name!($1)
        edit_facility_experiment_path(exp.facility, exp)

      when /the new experiment page for facility '(.*)'/
        facility = Facility.find_by_name!($1)
        new_facility_experiment_path(facility)

      # Parameter paths
      when /the create experiment parameter page for '(.*)'/
        exp = Experiment.find_by_name!($1)
        new_facility_experiment_experiment_parameter_path(exp.facility, exp)

      when /the edit experiment parameter page for '(.*)'/
        param = ExperimentParameter.find_by_parameter_category_id!(ParameterCategory.find_by_name!($1))
        edit_facility_experiment_experiment_parameter_path(param.experiment.facility, param.experiment, param)

      # Publish paths
      when /the publish page/
        new_from_search_published_collections_path

      # Cart paths
      when /the edit cart page/
        cart_items_path

      when /the create package page/
        new_package_path

      when /the edit system config page/
        edit_admin_config_path

      when /the system config page/
        admin_config_path

      when /the admin dashboard page/
        edit_admin_dashboard_path

      #  Access Control Groups paths
      when /the list access groups page/
        admin_access_groups_path

      when /the new access groups page/
        new_admin_access_group_path

      when /the view access group page for '(.*)'$/
        admin_access_group_path(AccessGroup.find_by_id($1))

      when /^the edit access group page for '(.*)'$/
        group = AccessGroup.find_by_name!($1)
        edit_admin_access_group_path(group.id)

      else
        begin
          page_name =~ /^the (.*) page$/
          path_components = $1.split(/\s+/)
          self.send(path_components.push('path').join('_').to_sym)
        rescue NoMethodError, ArgumentError
          raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
                    "Now, go and add a mapping in #{__FILE__}"
        end
    end
  end
end

World(NavigationHelpers)
