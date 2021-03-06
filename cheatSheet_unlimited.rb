#!/usr/bin/ruby
require 'date'
require 'csv'
require '/home/pi/git/DrinkABeerClub/Classes/Checkin.rb'

$startTime = Time.now

USER_CONFIG = "data/Users.csv"
USER_COUNT = `cat #{USER_CONFIG} | wc -l`
STYLE_CONFIG = "data/styles2016.csv"
SET_COUNT = `cat #{STYLE_CONFIG} | wc -l`

STYLES = Array.new
CSV.foreach(STYLE_CONFIG) do |row|
    if row.size() != 2 then
        STYLES.push(row[0].gsub(/\s+/,""))
    end
end

#def getSetIndex(inSet)
#  inStyle = inSet.gsub(/\s+/,""))
#  index = 0
#  CSV.foreach(SET_CONFIG) do |row|
#      style = row[0].gsub(/\s+/,""))
#      if style == inStyle then
#        return index
#      end
#      index = index + 1
#  end
#  return -1
#end

#bids = Array.new(SET_COUNT.to_i) { Hash.new() }
bids = Hash.new()

CSV.foreach(USER_CONFIG) do |user|

    $user_file = "user_data/#{user[0]}_distinct_beers.csv"

    puts "Reading: #{$user_file}..."

    counter = 0
    CSV.foreach($user_file, converters: :numeric) do |row|

        c = Distinct_beer.new(row)

        s = c.beer_style.gsub(/\s+/,"")

        if !STYLES.index(s).nil? then

            if bids[s].nil? then
                bids[s] = Hash.new()
            end

            bids[s][c.beer_bid] = c

        end
        counter += 1
    end

    puts "...#{counter} beers read"
end

output = open("cheatSheet_unlimited.html", "w")

output.write("<html>\n<head>\n<meta charset=\"UTF-8\">\n<style>\n")
output.write("table,th,td\n{border:1px solid black;\nborder-collapse:collapse;}\nth,td\n{padding:5px;}")
output.write("\n</style>\n</head><body>\n<table>\n")


STYLES.each { |set|

        s = set        
        puts "#{set}"

        output.write("  <tr>\n    <th>#{set}</th>\n")
  
        $i = 0

        bids[s].values.sort.reverse.each do |beer|

            if $i >= 10
                break
            end

            puts "--- #{beer.beer_name} - #{beer.brewery_name} :#{beer.beer_rating_score.round(3)}"
  
            img = ""
            if "#{beer.beer_label}" != DEFAULT_PNG then
                img = "#{beer.beer_label}"
            else
                img = "#{beer.brewery_label}"
            end

            search = "https://www.beermenus.com/search?q=#{beer.beer_name}"              
            search = search.gsub(" ", "+")

            str = "<a href=\"#{search}\" target=\"main\"><img src=\"#{img}\"><br></a>"
   
            title = "#{beer.beer_name}<br>#{beer.brewery_name}<br>(#{beer.beer_rating_score.round(3)})"
            output.write("  <td align=\"center\" >#{str}#{title}</td>\n")
  
            $i += 1

        end

        output.write("  </tr>\n")

}

output.write("</table>\n</body>\n</html>")

output.close

$endTime = Time.now

$duration = $endTime - $startTime

puts "Duration: #{$duration}"
