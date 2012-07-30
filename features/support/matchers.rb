RSpec::Matchers.define(:be_same_file_as) do |expected_file_path|
  match do |actual_file_path|
    md5_hash(actual_file_path).should == md5_hash(expected_file_path)
  end

  def md5_hash(file_path)
    contents = File.read(file_path)
    #normalise line endings:
    contents.gsub! /\r\n?/, "\n"
    Digest::MD5.hexdigest(contents)
  end
end

RSpec::Matchers.define(:be_same_metadata_file_as) do |expected_file_path|
  match do |actual_file_path|
    md5_hash(actual_file_path).should == md5_hash(expected_file_path)
  end

  def md5_hash(file_path)
    contents = File.read(file_path)
    #normalise line endings:
    contents.gsub! /\r\n?/, "\n"
    # Remove ids.. and yes, other numbers too
    contents.gsub! /\d+/ , ""
    # Collapse multiple spaces into single one
    contents.gsub! /\ \ +/, " "

    Digest::MD5.hexdigest(contents)
  end
end

