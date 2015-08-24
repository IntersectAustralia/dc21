class AccessRightsLookup

  #TODO: for now, just hardcoded, eventually we may pull from MINT
  RIGHTS = [{:id => 'CC-BY',               :url => "http://creativecommons.org/licenses/by/4.0",       :name => "CC BY: Attribution"},
            {:id => 'CC-BY-SA',            :url => "http://creativecommons.org/licenses/by-sa/4.0",    :name => "CC BY-SA: Attribution-Share Alike"},
            {:id => 'CC-BY-ND',            :url => "http://creativecommons.org/licenses/by-nd/4.0",    :name => "CC BY-ND: Attribution-No Derivative Works"},
            {:id => 'CC-BY-NC',            :url => "http://creativecommons.org/licenses/by-nc/4.0",    :name => "CC BY-NC: Attribution-Noncommercial"},
            {:id => 'CC-BY-NC-SA',         :url => "http://creativecommons.org/licenses/by-nc-sa/4.0", :name => "CC BY-NC-SA: Attribution-Noncommercial-Share Alike"},
            {:id => 'CC-BY-NC-ND',         :url => "http://creativecommons.org/licenses/by-nc-nd/4.0", :name => "CC BY-NC-ND: Attribution-Noncommercial-No Derivatives"},
            {:id => 'All rights reserved', :url => "N/A",                                              :name => "All rights reserved"}]

  def access_rights
    RIGHTS.map { |access_right| {:url => access_right[:url], :name => access_right[:name]} }
  end
  
  def get_name(url)
    access_right = RIGHTS.select{ |access_right| access_right[:url] == url }
    if !access_right.empty?
      return access_right.first[:name]
    end
  end

  def get_id(url)
    access_right = RIGHTS.select{ |access_right| access_right[:url] == url }
    if !access_right.empty?
      return access_right.first[:id]
    end
  end

  private

end
