# coding: utf-8

require 'yaml'
require 'twitter'
require 'pp'

def load_config()
  YAML.load_file("config.yaml")
end

def get_client(config)
  Twitter::REST::Client.new do |c|
    c.consumer_key        = config['oauth']['consumer_key']
    c.consumer_secret     = config['oauth']['consumer_secret']
    c.access_token        = config['oauth']['access_token']
    c.access_token_secret = config['oauth']['access_token_secret']
  end
end

def get_config_and_client()
  # config
  config = load_config()

  # client
  client = get_client(config)

  return config, client
end
