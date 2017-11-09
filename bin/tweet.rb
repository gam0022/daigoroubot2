# coding: utf-8

require 'yaml'
require 'twitter'
require 'pp'
require 'optparse'

require_relative '../lib/markov_chain'
require_relative '../lib/gobi'

puts "#{Time.new}"


# parse option
flag = {
  debug: false,
}
opt = OptionParser.new
opt.on('-n') {|v| flag[:debug] = true }
opt.parse!(ARGV)

# parse config
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

# select keyword
keyword = client.trends(id = config['woeid']).to_a.sample.name
puts "keyword: #{keyword}"

# learn
summary = Summary2.new

client.search("#{keyword} -rt -filter:links min_faves:0 min_retweets:0", lang: "ja", result_type: "recent").take(20).collect do |tweet|
  puts "@#{tweet.user.screen_name}: #{tweet.text}"
  if tweet.text =~ /@/
    puts "ignore. reason: include mention text"
  else
    summary.learn(tweet.text.filter)
  end
  puts
end

# talk
10.times do |i|
  puts "try: #{i + 1}"
  result = summary.talk()
  puts "result(raw): #{result}"
  result = Gobi.gobi(result)
  result = "#{result} #{keyword}" if keyword[0] == "#"
  puts "result: #{result} (#{result.length}文字)"
  if result.length < 80
    if flag[:debug]
      puts "update tweet [dry-run]"
    else
      puts "update tweet"
      client.update(result)
    end
    break
  end
end

puts
puts
