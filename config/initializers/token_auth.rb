require 'devise/strategies/base'
require 'devise/strategies/token_authenticatable'
module Devise
  module Strategies
    class TokenAuthenticatable
      def valid?
        super && params[:controller] == 'data_files' && (params[:action] == 'download' || params[:action] == 'api_create' || params[:action] == 'api_search')
      end
    end
  end
end