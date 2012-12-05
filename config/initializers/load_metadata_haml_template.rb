# load the HAML template once to avoid performance hit of reloading each time
template_path = File.join(Rails.root, "app/templates/file_set_metadata.html.haml")
template = File.read(template_path)
HTML_METADATA_HAML_ENGINE = Haml::Engine.new(template)
