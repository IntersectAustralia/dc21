require "net/http"
class MintServerStatus
  MINT_URL = "#{APP_CONFIG['for_codes_lookup_base_url']}#{APP_CONFIG['for_codes_path']}"
  HTTP_OK_CODE = "200"

  def self.server_up?
    # Don't rely on external services if running locally
    env = ENV["RAILS_ENV"] || "development"
    if env == "development" || env == "test"
      return true
    end

    url = URI.parse(MINT_URL)
    req = Net::HTTP.new(url.host, url.port)
    begin
      res = req.request_head(url.path)
    rescue Exception => e
      puts e
      return false
    end

    if res.code.eql? HTTP_OK_CODE
      return true
    else
      return false
    end
  end

end