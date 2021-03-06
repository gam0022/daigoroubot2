# coding: utf-8

require 'natto'
require_relative 'text_util'

class MarkovChain
  def initialize(n)
    @n = n
    @mecab = Natto::MeCab.new
    @heads = []
    @chains = []
  end

  # 文章を学習する
  def learn(text)
    text = filter(text)

    words = []
    @mecab.parse(text) do |node|
      puts "#{node.surface}\t#{node.feature}"
      words << node.surface
    end

    @heads << words[0...@n]
    @chains += words.each_cons(@n + 1).to_a
  end

  # 文章を生成する
  def talk()
    prefix = @heads.sample
    words = prefix[0...@n]

    while true
      choices = @chains.select {|chain| prefix == chain[0...@n]}
      break if choices.size == 0

      choice = choices.sample
      break if choice[@n] == ""

      words << choice[@n]
      prefix = choice[1..@n]
    end

    join_as_words(words)
  end
end
