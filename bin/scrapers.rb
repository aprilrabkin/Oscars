require './lib/MainScraper'
require './lib/SingleScraper'
require "rest_client"
require 'pry-nav'
require 'nokogiri'
require 'csv'
require 'nokogiri-styles'
require 'mechanize'

a = MainScraper.new("http://en.wikipedia.org/wiki/Academy_Award_for_Best_Picture")
a.scrape_all_movies