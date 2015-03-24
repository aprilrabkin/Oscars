class MainScraper
	attr_reader :array_of_budgets

	def initialize(url)
		@url = url
		@array_of_budgets = []
	end

	def fetch_page(url)
		agent = Mechanize.new 
		agent.get(url).parser
	end

	def iterate_through_years(noko)
		noko.css('.wikitable').each do |year_table|
			link_to_winner = "http://en.wikipedia.org" + year_table.css('td')[0].children[0].children[0].attributes['href'].value
			winner = SingleScraper.new(link_to_winner) 
			winner.scrape_and_print
			add_to_array_for_average(winner.budget)
		end
	end

	def add_to_array_for_average(budget)
		if budget != "" && budget != 0 && budget != "0" && budget != "unknown"
			@array_of_budgets.push(budget)
			CSV.open("array_of_budgets.csv", "a+") do |csv|
				csv << [budget]
			end
		end
	end

	def write_into_CSV_file(row)
		CSV.open("spreadsheet.csv", "a+") do |csv|
			csv << row
		end
	end

	def calculate_average
		sum = @array_of_budgets.inject(:+)
		average = sum/@array_of_budgets.count
		write_into_CSV_file(["Average budget out of #{@array_of_budgets.count} winners: $#{average}"])
	end

	def scrape_all_movies
		noko = fetch_page(@url)
		iterate_through_years(noko)
		calculate_average
	end

end
