def create_roles
  Role.delete_all

  Role.create!(:name => "Administrator")
  Role.create!(:name => "Researcher")
  Role.create!(:name => "API Uploader")

end

def create_parameter_categories
  ParameterCategory.delete_all
  ParameterSubCategory.delete_all
  ParameterModification.delete_all
  ParameterUnit.delete_all

  light = ParameterCategory.create!(name: "Light")
  atmosphere = ParameterCategory.create!(name: "Atmosphere")
  temperature = ParameterCategory.create!(name: "Temperature")
  humidity = ParameterCategory.create!(name: "Humidity")
  soil = ParameterCategory.create!(name: "Soil")
  nutrients = ParameterCategory.create!(name: "Nutrients")
  water = ParameterCategory.create!(name: "Water")

  atmosphere.parameter_sub_categories.create!(name: "Carbon Dioxide")
  atmosphere.parameter_sub_categories.create!(name: "Nitrogen")
  atmosphere.parameter_sub_categories.create!(name: "Oxygen")

  light.parameter_sub_categories.create!(name: "Natural")
  light.parameter_sub_categories.create!(name: "Infrared")
  light.parameter_sub_categories.create!(name: "Ultraviolet")

  temperature.parameter_sub_categories.create!(name: "Air temperature")
  temperature.parameter_sub_categories.create!(name: "Soil temperature")

  humidity.parameter_sub_categories.create!(name: "Normal")

  soil.parameter_sub_categories.create!(name: "Entisol")
  soil.parameter_sub_categories.create!(name: "Vertisol")
  soil.parameter_sub_categories.create!(name: "Inceptisol")
  soil.parameter_sub_categories.create!(name: "Aridisol")
  soil.parameter_sub_categories.create!(name: "Mollisol")
  soil.parameter_sub_categories.create!(name: "Spodosol")
  soil.parameter_sub_categories.create!(name: "Alfisol")
  soil.parameter_sub_categories.create!(name: "Ultisol")
  soil.parameter_sub_categories.create!(name: "Oxisol")
  soil.parameter_sub_categories.create!(name: "Histosol")
  soil.parameter_sub_categories.create!(name: "Andisols")
  soil.parameter_sub_categories.create!(name: "Gelisols")

  nutrients.parameter_sub_categories.create!(name: "Calcium")
  nutrients.parameter_sub_categories.create!(name: "Phosphorus")

  water.parameter_sub_categories.create!(name: "Rain water")
  water.parameter_sub_categories.create!(name: "Tap water")
  water.parameter_sub_categories.create!(name: "Distilled water")

  ParameterModification.create!(name: "Above ambient")
  ParameterModification.create!(name: "Below ambient")
  ParameterModification.create!(name: "Absolute target")
  ParameterModification.create!(name: "Excluded")

  ParameterUnit.create!(:name => "L/m2")
  ParameterUnit.create!(:name => "Percentage")
  ParameterUnit.create!(:name => "PPM")
  ParameterUnit.create!(:name => "Degrees C")
  ParameterUnit.create!(:name => "Lumens")
  ParameterUnit.create!(:name => "Litres")
  ParameterUnit.create!(:name => "Millilitres")
  ParameterUnit.create!(:name => "Grams/Cubic Metre")
  ParameterUnit.create!(:name => "Kilograms/Cubic Metre")

end
