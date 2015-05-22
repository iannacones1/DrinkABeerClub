#!/usr/bin/ruby
require 'csv'
require '/home/pi/git/DrinkABeerClub/Classes/DistinctBeer.rb'
require '/home/pi/git/DrinkABeerClub/Classes/HtmlWriter.rb'

USER_CONFIG = "data/Users.csv"
USERS = Array.new
CSV.foreach(USER_CONFIG) { |user| USERS.push("#{user[0]}") }

BEERS_OF_FAME = "data/BeersOfFame.csv"

distinctBeers = Hash.new()

USERS.each do |user|

    if distinctBeers[user].nil? then
        distinctBeers[user] = Hash.new()
    end

    $user_file = "user_data/#{user}_distinct_beers.csv"
    puts "Building BeersOfFame page for #{user} from file: #{$user_file}"

    CSV.foreach($user_file, converters: :numeric) do |row|

        d = Distinct_beer.new(row)

        distinctBeers[user][d.beer_bid] = d
    end
end

output = HtmlWriter.new("BeersOfFame.html")
output.openTag("body")
output.write("<font size=\"6\" face=\"Verdana\">#{$user}</font><br>\n")
output.write("The following list, thanks to <a href=\"http://www.beeradvocate.com/lists/fame/\" target=\"main\">BeerAdvocate</a>, is comprised of tried and true world class beers.<br>So next time you're buying beer and don't know what beer to get, consult this list.<pr>\n")

$UserCount = Hash.new(0)
$TotalCount = Hash.new(0)

USERS.each do |user|
    CSV.foreach(BEERS_OF_FAME, converters: :numeric) do |row|
        $TotalCount[user] += 1
        if distinctBeers[user].has_key?(row[1])
            $UserCount[user] += 1
        end
    end
end

output.openTag("table")

output.startRow()
 output.writeTableHeader("Rank")
 output.writeTableHeader("Beer")
USERS.each do |user|
  output.writeTableHeader("#{user}<br>#{$UserCount[user]}/#{$TotalCount[user]}")
end
output.endRow()

CSV.foreach(BEERS_OF_FAME, converters: :numeric) do |row|

    output.startRow()

    output.writeTableHeader("<span style=\"font-size:1.5em;font-weight:bold;color:#999999;\">#{row[0]}</span>")

    output.writeTableHeader("#{row[3]}<br/>#{row[5]}")

    USERS.each do |user|
        str = ""
        if distinctBeers[user].has_key?(row[1])
            str = distinctBeers[user][row[1]].getHtmlImg
        end
        output.writeTableData(str)
    end
    output.endRow()
end

output.closeTag("body")
output.closeTag("table")

output.close
