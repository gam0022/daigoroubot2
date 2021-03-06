# coding: utf-8

require 'natto'
require_relative 'text_util'

class Gobi
  def initialize()
    @mecab = Natto::MeCab.new
  end

  # 与えられたNodeが文末なのかを判断する
  def fin?(node)
    node.feature =~ /EOS/ || node.surface =~ /( |　|!|！|\?|？|。)/
  end

  # 語尾を変化させる
  def translate(text)
    nodes = []
    @mecab.parse(text) do |node|
      puts "#{node.surface}\t#{node.feature}"

      nodes << {
        surface: node.surface,
        feature: node.feature,
        fin: fin?(node),
      }
    end

    words = []
    nodes.each_cons(2) do |prev_cur|
      prev, cur = prev_cur

      if cur[:fin] && !prev[:fin]
        if prev[:feature] =~ /基本形/
          words << prev[:surface] + 'のだ！'
        else
          words << prev[:surface] + 'なのだ！'
        end
      else
        words << prev[:surface]
      end
    end

    join_as_words(words)
  end 
end
