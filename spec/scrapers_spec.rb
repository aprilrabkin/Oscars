require 'spec_helper'
require './lib/MainScraper'
require './lib/SingleScraper'
require 'Mechanize'
require 'CSV'
require 'pry-nav'

describe MainScraper do 

	a = MainScraper.new("http://en.wikipedia.org/wiki/Academy_Award_for_Best_Picture")
	b = SingleScraper.new("http://en.wikipedia.org/wiki/All_Quiet_on_the_Western_Front_(1930_film)")
	b.scrape_and_print
	c = SingleScraper.new("http://en.wikipedia.org/wiki/The_Broadway_Melody")
	c.scrape_and_print
	a.add_to_array_for_average(b.budget)
	a.add_to_array_for_average(c.budget)

	it 'when iterating through list, it prints out a movie budget listed in millions of USD' do 
		CSV.read("./spreadsheet.csv").flatten.should include("$1.2 million")
	end

	it 'prints \'unknown\' for unlisted movie budgets' do
		CSV.read("./spreadsheet.csv").flatten.should include("unknown")
	end

	it 'adds standardized budgets to the array of budgets' do
		CSV.read("./array_of_budgets.csv").flatten.should include("1200000")
	end

	it 'does not add unstandardized budgets to the array of budgets' do 
		CSV.read("./array_of_budgets.csv").flatten.should_not include("unknown")
	end

	it 'should calculate the average based on number of standardizes budgets' do
		a.calculate_average
		CSV.read("./spreadsheet.csv").flatten.should include("Average budget out of 1 winners: $1200000")
	end

end
