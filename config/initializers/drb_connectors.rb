DRB_WORKER = YAML.load_file("#{::Rails.root}/config/converter.yml")[::Rails.env]
DRBScanner.instance.set_uri("druby://#{DRB_WORKER['remote_host']}:#{DRB_WORKER['remote_port_scanner']}")
DRBConverter.instance.set_uri("druby://#{DRB_WORKER['remote_host']}:#{DRB_WORKER['remote_port_converter']}")