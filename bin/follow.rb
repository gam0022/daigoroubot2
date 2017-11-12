# coding: utf-8

require 'optparse'

require_relative 'common'

def parse_option
  option = {
    is_dry_run: false,
  }

  parser = OptionParser.new
  parser.on('-n') {|v| option[:is_dry_run] = true }
  parser.parse!(ARGV)

  option
end

def fetch_follower_ids(client, method = :follower_ids)
  return if ![:friend_ids, :follower_ids, :friendships_incoming, :friendships_outgoing].include?(method)

  ids = []
  cursor = -1
  while cursor != 0
    res = client.send(method, cursor: cursor).to_h
    ids += res[:ids]
    cursor = res[:next_cursor]
  end

  ids
end

def main
  puts "#{Time.new}"

  # init
  config, client = get_config_and_client()
  option = parse_option()
  dry_run_text = option[:is_dry_run] ? " [dry-run]" : ""

  begin
    # fetch follow info
    follower_ids = fetch_follower_ids(client, :follower_ids)
    puts "follower_count: #{follower_ids.size}"

    friend_ids = fetch_follower_ids(client, :friend_ids)
    puts "friend_count: #{friend_ids.size}"

    friendships_outgoing = fetch_follower_ids(client, :friendships_outgoing)
    puts "friendships_outgoing_count: #{friendships_outgoing.size}"
    puts


    # follow users
    new_follow = (config['users']['follow'] | follower_ids) - friend_ids - friendships_outgoing - config['users']['remove']
    new_follow_count = 0
    new_follow.each do |id|
      user = client.user(id, skip_status: true)

      puts "follow: @#{user.screen_name}#{dry_run_text}"
      client.follow(id) if !option[:is_dry_run]
      new_follow_count += 1

      text = ["フォロー返したのだ！", "フォローありがとうなのだ！", "フォローしたのだ！"].sample
      update_text = "@#{user.screen_name} #{user.name}、#{text}"
      client.update(update_text) if !option[:is_dry_run]

      # API制限回避のために、一度にフォローする上限は10人までとする
      if new_follow_count == 10
        exit
      end
    end


    # unfollow users
    new_unfollow = (config['users']['remove'] & friend_ids) | (friend_ids - follower_ids) - config['users']['follow']
    new_unfollow.each do |id|
      puts "unfollow: @#{user.screen_name}#{dry_run_text}"
      client.unfollow(id) if !option[:is_dry_run]
    end

    puts
    puts
  rescue Twitter::Error::TooManyRequests => error
    pp error.rate_limit
    exit
  end
end

main()
