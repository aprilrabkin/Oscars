class SingleScraper < MainScraper

	attr_reader :budget

	def initialize(url)
		@url = url
		@budget = 0
	end

	def scrape_and_print
		noko = fetch_page(@url)
		name = noko.search('.summary')[0].text.gsub("\n","")
		year = noko.search('.bday.dtstart.published.updated')[0].text[0..3]
		original_budget = noko.search('.infobox').text[/Budget\n(.+)\n/,1]
		if original_budget
			original_budget = original_budget.gsub(/\[.*/,"").gsub(" (est.)","")
			@standardized_budget = standardize(name, original_budget, year)
		end
		write_into_CSV_file([year, name, original_budget || "unknown"])
	end

	def standardize(name, original_budget, year)
		budget = clean_currency(name, original_budget, year)
		@budget = clean_denomination(budget)
	end

	def clean_currency(name, budget, year)
		if budget.include?("or")|| budget.include?("(")|| budget.include?("-")|| budget.include?("–") || !budget.include?("$") || budget.include?("£")
			print "#{name} cost #{budget} in #{year}. Please type one number in USD with \"$\" or press return to ignore that movie.\n"
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

end