#!/usr/bin/ruby
require 'csv'
require '/home/pi/git/DrinkABeerClub/Classes/DistinctBeer.rb'
require '/home/pi/git/DrinkABeerClub/Classes/HtmlWriter.rb'

if ARGV[0].nil?
    puts "Please input username"
    exit 1
end

$user = ARGV[0]

$user_file = "user_data/#{$user}_distinct_beers.csv"
BEERS_OF_FAME = "data/BeersOfFame.csv"

puts "Building BeersOfFame page for #{$user} from file: #{$user_file}"

distinctBeers = Hash.new

CSV.foreach($user_file, converters: :numeric) do |row|

    c = Distinct_beer.new(row)

    distinctBeers[c.beer_bid] = c

end

output = HtmlWriter.new("#{$user}_BoF.html")
output.openTag("body")
output.write("<font size=\"6\" face=\"Verdana\">#{$user}</font><br>\n")
output.write("Craft beer culture can often be very trendy, giving attention to new styles and Brewer's newest offerings. Forget the hype. The following list, thanks to <a href=\"http://www.beeradvocate.com/lists/fame/\" target=\"main\">BeerAdvocate</a>, is comprised of tried and true world class beers. So next time you don't know what beer to get, consult this list.<pr>\n")

output.openTag("table")

$count = 0

CSV.foreach(BEERS_OF_FAME, converters: :numeric) do |row|

    output.startRow()

    output.writeTableHeader("<span style=\"font-size:1.5em;font-weight:bold;color:#999999;\">#{row[0]}</span>")

    output.writeTableHeader("#{row[3]}<br/>#{row[5]}")

    str = ""
    if distinctBeers.has_key?(row[1])
        $count += 1
        str = distinctBeers[row[1]].getHtmlImg
    end
    output.writeTableData(str)
    output.endRow()
end

output.closeTag("body")
output.closeTag("table")

puts "#{$count}"

output.close
