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

output.openTag("style")
output.write("    table\n")
output.write("    {\n")
output.write("        border-collapse: collapse;\n")
output.write("        padding: 5px;\n")
output.write("    }\n\n")
output.write("    th,td\n")
output.write("    {\n")
output.write("        text-align: center;\n")
output.write("        border: 1px dotted black;\n")
output.write("        padding: 5px;\n")
output.write("    }\n")
output.closeTag("style")

output.closeTag("head")
output.openTag("body")
output.write("<font size=\"6\" face=\"Verdana\">#{$user}</font><br>\n")
output.write("The following list, thanks to <a href=\"http://www.beeradvocate.com/lists/fame/\" target=\"main\">BeerAdvocate</a>, is comprised of tried and true world class beers.<br>So next time you're buying beer and don't know what beer to get, consult this list.<pr>\n")

$UserCount = 0
$TotalCount = 0

CSV.foreach(BEERS_OF_FAME, converters: :numeric) do |row|
    $TotalCount += 1
    if distinctBeers.has_key?(row[1])
        $UserCount += 1
    end
end

output.openTag("table")

output.startRow()
 output.writeTableHeader("Rank")
 output.writeTableHeader("Beer")
 output.writeTableHeader("#{$UserCount}/#{$TotalCount}")
output.endRow()

CSV.foreach(BEERS_OF_FAME, converters: :numeric) do |row|

    output.startRow()

    output.writeTableHeader("<span style=\"font-size:1.5em;font-weight:bold;color:#999999;\">#{row[0]}</span>")

    output.writeTableHeader("#{row[3]}<br/>#{row[5]}")

    str = ""
    if distinctBeers.has_key?(row[1])
        str = distinctBeers[row[1]].getHtmlImg
    end
    output.writeTableData(str)
    output.endRow()
end

output.closeTag("body")
output.closeTag("table")

output.close
