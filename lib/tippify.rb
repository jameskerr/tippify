require 'nokogiri'

class Tippify

	def initialize(html)
		@starting_html = html.force_encoding('utf-8')
		@footnotes     = {}
		@ending_html   = @starting_html
	end

	def replace!
		article = Nokogiri::HTML(@starting_html)
		parse_table(article)
		remove_table
		@ending_html
	end

	private

	def parse_table(article)
		article.css('table tbody').each do |table|
			next unless table.content =~ /footnotes/i
			parse_rows(table)
			table.parent.remove
		end
	end

	def parse_rows(table)
		table.css('tr').each do |row|
			next if row.content.empty?
			parse_cells(row)
		end
	end

	def parse_cells(row)
		cells         = row.css('td')
		return unless cells.count == 2
		id             = cells[0].css('a').attribute('href').to_s.split('_')[2]
		number 				 = cells[0].content.strip
		content        = cells[1].content.strip
		replace_footnote(id, number, content)
	end

	def replace_footnote(id, number, content)
		tooltip = "<sup>[tippy title=\"#{number}\" header=\"off\"]#{content}[/tippy]</sup>"
		@ending_html.gsub!(/<a .*href=".*_#{Regexp.quote(id)}.*".*<\/a>/, tooltip)
	end

	def remove_table
		@ending_html.gsub!(/<table.*Footnotes.*<\/table>/im, '')
	end
end
