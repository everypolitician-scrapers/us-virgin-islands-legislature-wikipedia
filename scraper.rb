#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'open-uri'

require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(url)
  noko = noko_for(url)
  noko.xpath('//table[.//th[contains(.,"Election results")]]').each do |table|
    area = table.xpath('.//th[contains(.,"Election results")]').text.split(/,\s*/).last.sub(/\.?\s*\[\d+\]\s*$/, '').sub(' District','')
    table.xpath('.//tr[td]').each do |tr|
      tds = tr.css('td')
      break if tds[1].css('b').empty?
      data = { 
        name: tds[1].text,
        party: tds[0].text,
        area: area,
        term: 2014,
      }
      ScraperWiki.save_sqlite([:name, :term], data)
    end
  end
end

scrape_list('https://en.wikipedia.org/wiki/United_States_Virgin_Islands_general_election,_2014')
