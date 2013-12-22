DRB_WORKER = YAML.load_file("#{::Rails.root}/config/converter.yml")[::Rails.env]
DRB_SIDEKICK = true