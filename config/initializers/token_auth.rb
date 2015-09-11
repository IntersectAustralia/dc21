require 'devise/strategies/base'
require 'devise/strategies/token_authenticatable'
module Devise
  module Strategies
    class TokenAuthenticatable
      def valid?
        super && valid_operation?
      end

      private

      def valid_operation?
        if params[:controller] == 'data_files'
          return valid_data_files_operation?
        end
        if params[:controller] == 'packages'
          return valid_packages_operation?
        end
        return false
      end

      def valid_data_files_operation?
        params[:action] == 'download' || params[:action] == 'api_create' || params[:action] == 'api_search' || params[:action] == 'variable_list' || params[:action] == 'facility_and_experiment_list' || params[:action] == 'api_update'
      end

      def valid_packages_operation?
        params[:action] == 'api_create' || params[:action] == 'api_publish'
      end
    end
  end
end