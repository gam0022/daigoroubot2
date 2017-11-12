# coding: utf-8

require 'yaml'
require 'twitter'
require 'pp'

# 単語配列を連結する。英数字同士はスペースで連結する
def join_as_words(words)
  text = words[0]

  words.each_cons(2) do |prev_cur|
    prev, cur = prev_cur

    if prev =~ /[\w\d]+/ && cur =~ /[\w\d]+/
      text += " " + cur
    else
      text += cur
    end
  end

  text
end

def load_config()
  config = {}

  open("config.yaml") do |f|
    config = YAML.load(f)
  end

  config
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
