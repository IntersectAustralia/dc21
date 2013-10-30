APP_CONFIG = YAML.load_file("#{Rails.root.to_s}/config/dc21app_config.yml")[Rails.env]

if Rack::Utils.respond_to?("key_space_limit=")
  Rack::Utils.key_space_limit = 262144 # 4 times the default size
end
