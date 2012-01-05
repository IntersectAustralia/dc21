RSpec::Matchers.define(:be_same_file_as) do |expected_file_path|
  match do |actual_file_path|
    md5_hash(actual_file_path).should == md5_hash(expected_file_path)
  end

  def md5_hash(file_path)
    Digest::MD5.hexdigest(File.read(file_path))
  end
end
