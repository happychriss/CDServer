class Converter


    require 'ServiceConnector'

    extend ServiceConnector ##provides methods to connect to remote drb services

  def self.service_name
    "Converter"
  end

  end