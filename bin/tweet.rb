# coding: utf-8

require 'optparse'

require_relative 'common'
require_relative '../lib/markov_chain'
require_relative '../lib/gobi'

def parse_option
  option = {
    is_dry_run: false,
    text: nil,
  }

  parser = OptionParser.new
  parser.on('-n', '--dry-run') {|v| option[:is_dry_run] = true }
  parser.on('-t VAL', '--text VAL') {|v| option[:text] = v }
  parser.parse!(ARGV)

  option
end

def generate_text(config, client)
  puts "#generate_text"

  # select keyword
  keyword = client.trends(id = config['woeid']).to_a.sample.name
  puts "keyword: #{keyword}"

  # learn
  mc = MarkovChain.new(2)

  query = "#{keyword} -rt -filter:links min_faves:0 min_retweets:0"
  client.search(query, lang: "ja", result_type: "recent").take(20).collect do |tweet|
    puts "@#{tweet.user.screen_name}: #{tweet.text}"
    if tweet.text =~ /@/
      puts "\t>> ignored: include mention text"
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

    # 凍結されそうな発言は控える
    if result =~ /殺す|kill/
      puts "\t>> faild: include violence words"
      next
    end

    # 長すぎる発言は控える
    if result.length >= 80
      puts "\t>> faild: too long text (over 80 chars)"
      next
    end

    # テキストの生成に成功
    return result
  end

  # テキストの生成に失敗
  return nil
end

def main
  puts "#{Time.new}"

  config, client = get_config_and_client()
  option = parse_option()

  text = option[:text] || generate_text(config, client)

  if text
    if option[:is_dry_run]
      puts "update tweet[dry-run]: #{text}"
    else
      puts "update tweet: #{text}"
      client.update(text)
    end
  else
    puts "faild to update tweet..."
  end

  puts
  puts
end

main()
