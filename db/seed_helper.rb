def create_roles
  Role.delete_all

  Role.create!(:name => "Administrator")
  Role.create!(:name => "Researcher")
  Role.create!(:name => "API Uploader")
end

def create_tags
  Tag.delete_all

  APP_CONFIG['tags'].each do |hash|
    Tag.create!(hash)
  end
end


def create_parameter_categories
  ParameterCategory.delete_all
  ParameterSubCategory.delete_all
  ParameterModification.delete_all
  ParameterUnit.delete_all

  APP_CONFIG['parameter_categories'].each do |hash|
    sub_categories = hash.delete('sub_categories')
    pc = ParameterCategory.create!(hash)
    sub_categories.each do |psc|
      pc.parameter_sub_categories.create!(psc)
    end
  end

  APP_CONFIG['parameter_units'].each do |hash|
    ParameterUnit.create!(hash)
  end

  APP_CONFIG['parameter_modifications'].each do |hash|
    ParameterModification.create!(hash)
  end
end

def create_sequences
  ActiveRecord::Base.establish_connection(Rails.env.to_sym)
  result = ActiveRecord::Base.connection.execute "SELECT * FROM information_schema.sequences WHERE sequence_schema = 'public' AND sequence_name = 'package_id_seq';"
  ActiveRecord::Base.connection.execute "CREATE SEQUENCE package_id_seq;" if result.count == 0
end
