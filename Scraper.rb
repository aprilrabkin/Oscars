#Still must check spreadsheet afterward to make sure there are no other $ currencies like Canadian or Australian dollars

require 'mechanize'
require "rest_client"
require 'pry-nav'
require 'nokogiri'
require 'csv'
require 'nokogiri-styles'

class Scraper 
	attr_reader :rows, :rsvps_page
	def initialize
		
		@budget_array_for_calculating_average = []
	end

	def fetch_page
		agent = Mechanize.new 
		@page = agent.get("http://en.wikipedia.org/wiki/Academy_Award_for_Best_Picture").parser
	end

	def iterate_through_years
		@page.css('.wikitable').each do |year_table|
			link_to_winner = "http://en.wikipedia.org" + year_table.css('td')[0].children[0].children[0].attributes['href'].value
			scrape_winner(link_to_winner)
		end
	end

	def scrape_winner(link_to_movie)
		page = RestClient.get(link_to_movie)
		noko = Nokogiri::HTML(page)
		name= noko.search('.summary')[0].text.gsub("\n","")
		year = noko.search('.bday.dtstart.published.updated')[0].text[0..3]
		original_budget = noko.search('.infobox').text[/Budget\n(.+)\n/,1]
		if original_budget
			original_budget = original_budget.gsub(/\[.*/,"").gsub(" (est.)","")
			standardized_budget = standardize(original_budget, year)
		end
		write_into_CSV_file([year, name, original_budget || "Budget not listed", standardized_budget])
	end

	def standardize(original_budget, year)
		standardized_budget = clean_currency(original_budget, year)
		standardized_budget = clean_denomination(standardized_budget)
		if standardized_budget != "" && standardized_budget != 0 && standardized_budget != "0"
			add_budget_to_array(standardized_budget)
			standardized_budget
		else
			standardized_budget = "Budget not included in average"
		end
	end

	def clean_currency(budget, year)
		if budget.include?("or")|| budget.include?("(")|| budget.include?("-")|| budget.include?("–") || !budget.include?("$") || budget.include?("£")
			print "Budget in #{year} was #{budget}. Please type one number in USD with \"$\" or press return to ignore that movie.\n"
			budget = gets.chomp
		end
		budget = budget.gsub("$", "").gsub("US","")
	end

	def clean_denomination(budget)
		budget = budget.gsub(",","")
		if budget.include?("million")
			budget = (budget.to_f * 1000000).to_i
		end
		budget.to_i
	end

	def add_budget_to_array(budget)
		@budget_array_for_calculating_average.push(budget.to_i)
	end

	def get_average
		sum = @budget_array_for_calculating_average.inject(:+)
		average = sum/@budget_array_for_calculating_average.count
		write_into_CSV_file(["Average budget out of #{@budget_array_for_calculating_average.count} winners: $#{average}"])
	end

	def write_into_CSV_file(row)
		CSV.open("spreadsheet.csv", "a+") do |csv|
			csv << row
		end
	end

end

a = Scraper.new
a.fetch_page
a.iterate_through_years
a.get_average
#a.write_into_CSV_file