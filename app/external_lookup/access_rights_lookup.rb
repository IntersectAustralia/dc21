class AccessRightsLookup

  #TODO: for now, just hardcoded, eventually we may pull from MINT
  RIGHTS = {"http://creativecommons.org/licenses/by/3.0/au" => "CC BY: Attribution",
            "http://creativecommons.org/licenses/by-sa/3.0/au" => "CC BY-SA: Attribution-Share Alike",
            "http://creativecommons.org/licenses/by-nd/3.0/au" => "CC BY-ND: Attribution-No Derivative Works",
            "http://creativecommons.org/licenses/by-nc/3.0/au" => "CC BY-NC: Attribution-Noncommercial",
            "http://creativecommons.org/licenses/by-nc-sa/3.0/au" => "CC BY-NC-SA: Attribution-Noncommercial-Share Alike",
            "http://creativecommons.org/licenses/by-nc-nd/3.0/au" => "CC BY-NC-ND: Attribution-Noncommercial-No Derivatives",
            "N/A" => "All rights reserved"}
  

  def access_rights
    RIGHTS.map { |k, v| [v, k] }
  end
  
  def get_name(id)
    RIGHTS[id]
  end
end
