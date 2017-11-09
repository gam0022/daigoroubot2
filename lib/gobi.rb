# coding: utf-8

ENV['MECAB_PATH'] = '/usr/lib/libmecab.so.2'
require 'natto'

class Gobi
  #
  # 与えられたNodeが文末なのかを判断する
  #
  def self.fin?(surface, feature)
    return true if feature =~ /EOS/
    return true if surface =~ /( |　|!|！|[.]|。)/
    return false
  end

  #
  # 語尾を変化させる
  #
  def self.gobi(text)

    # mecabで形態素解析して、 参照テーブルを作る
    mecab = Natto::MeCab.new

    buf = ""
    feature = ""
    surface = ""
    prev_feature = ""
    prev_surface = ""
    prev_nanoda = false

    enum = mecab.enum_parse(text)

    nodes = []
    enum.each do |node|
      nodes << node
    end

    nodes.each do |node|
      puts "#{node.surface}\t#{node.feature}"

      prev_feature = feature
      feature = node.feature.scrub("")

      prev_surface = surface
      surface = node.surface.scrub("")

      if !prev_nanoda && prev_feature =~ /基本形/ && fin?(surface, feature)
        buf += prev_surface + 'のだ！'
        prev_nanoda = true
      elsif !prev_nanoda && fin?(surface, feature)
        buf += prev_surface + 'なのだ！'
        prev_nanoda = true
      else
        buf = buf.eappend prev_surface
        prev_nanoda = false
      end
    end

    buf
  end 
end
