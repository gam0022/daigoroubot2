# coding: utf-8

require 'optparse'

require_relative '../lib/common'
require_relative '../lib/markov_chain'
require_relative '../lib/gobi'

def parse_option
  option = {
    debug: false,
  }

  parser = OptionParser.new
  parser.on('-n') {|v| option[:debug] = true }
  parser.parse!(ARGV)

  option
end

def main
  puts "#{Time.new}"

  # init
  config, client = get_config_and_client()
  option = parse_option()

  # select keyword
  keyword = client.trends(id = config['woeid']).to_a.sample.name
  puts "keyword: #{keyword}"

  # learn
  mc = MarkovChain.new(2)

  query = "#{keyword} -rt -filter:links min_faves:0 min_retweets:0"
  client.search(query, lang: "ja", result_type: "recent").take(20).collect do |tweet|
    puts "@#{tweet.user.screen_name}: #{tweet.text}"
    if tweet.text =~ /@/
      puts "[ignore] include mention text"
    else
      mc.learn(tweet.text)
    end
    puts
  end

  # talk
  gobi = Gobi.new

  10.times do |i|
    puts "try: #{i + 1}"
    result = mc.talk()
    puts "result(raw): #{result}"
    result = gobi.translate(result)
    result = "#{result} #{keyword}" if keyword[0] == "#"
    puts "result: #{result} (#{result.length}文字)"
    if result.length < 80
      if option[:debug]
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
end

main()
