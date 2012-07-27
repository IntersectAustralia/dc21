APP_CONFIG = YAML.load_file("#{Rails.root.to_s}/config/dc21app_config.yml")[Rails.env]
extra_config = YAML.load_file(APP_CONFIG['extra_config_file'])[Rails.env]
APP_CONFIG.merge!(extra_config)
