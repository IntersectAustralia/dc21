class ForCodesLookup
  include HTTParty

  FOR_CODES_PATH = APP_CONFIG['for_codes_path']
  base_uri APP_CONFIG['for_codes_lookup_base_url']
  format :json

  def self.get_instance
    #if we 're in dev or test, use the mock lookup, so we don't depend on external services
    env = ENV["RAILS_ENV"] || "development"
    if env == "development" || env == "test"
      MockForCodesLookup.new
    else
      ForCodesLookup.new
    end

  end

  def top_level_codes
    get_codes("top")
  end

  def second_level_codes(top_level_code)
    get_codes(top_level_code)
  end

  def third_level_codes(second_level_code)
    get_codes(second_level_code)
  end

  private
  def get_codes(level)
    response = self.class.get(FOR_CODES_PATH, :query => {:level => level, :count => 9999}, :timeout => 1000)
    filter_codes(response)
  end

  def filter_codes(response)
    codes = response["results"].collect { |result| [result["skos:prefLabel"], result["rdf:about"]] }
    codes.sort { |x, y| x[1] <=> y[1] }
  end
end