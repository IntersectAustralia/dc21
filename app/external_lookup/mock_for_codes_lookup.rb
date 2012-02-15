class MockForCodesLookup

  def top_level_codes
    result = []
    result << ["01 - MATHEMATICAL SCIENCES", "http://purl.org/asc/1297.0/2008/for/01"]
    result << ["02 - PHYSICAL SCIENCES", "http://purl.org/asc/1297.0/2008/for/02"]
    result << ["03 - CHEMICAL SCIENCES", "http://purl.org/asc/1297.0/2008/for/03"]
    result << ["04 - EARTH SCIENCES", "http://purl.org/asc/1297.0/2008/for/04"]
    result << ["05 - ENVIRONMENTAL SCIENCES", "http://purl.org/asc/1297.0/2008/for/05"]
    result << ["06 - BIOLOGICAL SCIENCES", "http://purl.org/asc/1297.0/2008/for/06"]

    result
  end

  def second_level_codes(top_level_code)
    number = top_level_code[top_level_code.rindex("/")..-1]
    result = []

    (1..9).each do |i|
      result << [top_level_code + "0" + i, "#{number}0#{i} - ITEM #{i}"]
    end
    result
  end

  def third_level_codes(second_level_code)
    number = top_level_code[top_level_code.rindex("/")..-1]
    result = []

    (1..9).each do |i|
      result << [top_level_code + "0" + i, "#{number}0#{i} - ITEM #{i}"]
    end
    result
  end

end