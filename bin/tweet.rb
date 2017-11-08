# coding: utf-8

require 'yaml'
require 'twitter'
require 'pp'

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

keyword = client.trends(id = config['woeid']).to_a.sample.name
puts "keyword: #{keyword}"

summary = Summary.new

client.search("#{keyword} -rt -filter:links ", lang: "ja").take(10).collect do |tweet|
  #puts "#{tweet.user.screen_name}: #{tweet.text}"
  summary.learn(tweet.text.filter)
end

10.times do |i|
  puts "try: #{i + 1}"
  result = summary.talk()
  result = Gobi.gobi(result)
  puts "result: #{result} (#{result.length}文字)"
  if result.length < 50
    puts "update tweet"
    client.update(result)
    break
  end
end
