require './MainScraper'
require './SingleScraper'
require "rest_client"
require 'pry-nav'
require 'nokogiri'
require 'csv'
require 'nokogiri-styles'

a = MainScraper.new("http://en.wikipedia.org/wiki/Academy_Award_for_Best_Picture")
a.scrape_all_movies