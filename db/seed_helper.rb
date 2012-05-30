def create_roles
  Role.delete_all

  Role.create!(:name => "Administrator")
  Role.create!(:name => "Researcher")
  Role.create!(:name => "API Uploader")
end

def create_tags
  Tag.delete_all

  config_file = File.expand_path('../../config/tags.yml', __FILE__)
  config = YAML::load_file(config_file)
  config['tags'].each do |hash|
    Tag.create!(hash)
  end
end


def create_parameter_categories
  ParameterCategory.delete_all
  ParameterSubCategory.delete_all
  ParameterModification.delete_all
  ParameterUnit.delete_all

  config_file = File.expand_path('../../config/experiment_parameters.yml', __FILE__)
  config = YAML::load_file(config_file)

  config['parameter_categories'].each do |hash|
    sub_categories = hash.delete('sub_categories')
    pc = ParameterCategory.create!(hash)
    sub_categories.each do |psc|
      pc.parameter_sub_categories.create!(psc)
    end
  end

  config['parameter_units'].each do |hash|
    ParameterUnit.create!(hash)
  end

  config['parameter_modifications'].each do |hash|
    ParameterModification.create!(hash)
  end
end
