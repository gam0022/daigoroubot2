# coding: utf-8

require 'yaml'
require 'twitter'

require_relative '../lib/markov_chain'
require_relative '../lib/gobi'

config = {}

open("config.yaml") do |f|
  config = YAML.load(f)
end

client = Twitter::REST::Client.new do |c|
  c.consumer_key        = config['oauth']['consumer_key']
  c.consumer_secret     = config['oauth']['consumer_secret']
  c.access_token        = config['oauth']['access_token']
  c.access_token_secret = config['oauth']['access_token_secret']
end

keyword = "動物"

summary = Summary.new

client.search("#{keyword} -rt -filter:links ", lang: "ja").take(10).collect do |tweet|
  puts "#{tweet.user.screen_name}: #{tweet.text}"
  summary.learn(tweet.text.filter)
end

result = summary.talk()
puts result
puts Gobi.gobi(result)
