# coding: utf-8

ENV['MECAB_PATH'] = '/usr/lib/libmecab.so.2'
require 'natto'

require_relative 'common'

class Gobi
  def initialize()
    @mecab = Natto::MeCab.new
  end

  #
  # 与えられたNodeが文末なのかを判断する
  #
  def fin?(node)
    return true if node.feature =~ /EOS/
    return true if node.surface =~ /( |　|!|！|。)/
    return false
  end

  #
  # 語尾を変化させる
  #
  def translate(text)
    enum = @mecab.enum_parse(text)

    nodes = []
    enum.each do |node|
      puts "#{node.surface}\t#{node.feature}"

      nodes << {
        surface: node.surface,
        feature: node.feature,
        fin: fin?(node),
      }
    end

    words = []

    prev = {
      surface: "",
      feature: "",
      fin: false,
    }

    nodes.each do |node|
      if node[:fin] && !prev[:fin]
        if prev[:feature] =~ /基本形/
          words << prev[:surface] + 'のだ！'
        else
          words << prev[:surface] + 'なのだ！'
        end
      else
        words << prev[:surface]
      end

      prev = node
    end

    join_as_words(words)
  end 
end
