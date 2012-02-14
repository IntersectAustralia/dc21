class ForCodesLookup
  include HTTParty

  URL =

  base_uri APP_CONFIG['for_codes_lookup_base_url']
  format :json

  def top_level_codes
    response = self.class.get('/mint/ANZSRC_FOR/opensearch/lookup?level=top&count=9999', :timeout => 300)
    codes = []
    response["results"].each do |result|
      codes << [result["rdf:about"], result["skos:prefLabel"]]
    end
    codes.sort { |x, y| x[1] <=> y[1] }
  end

end