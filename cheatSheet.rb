#!/usr/bin/ruby
require 'date'
require 'csv'
require '/home/pi/git/DrinkABeerClub/Classes/Checkin.rb'

$startTime = Time.now

DEFAULT_PNG = "https://d1c8v1qci5en44.cloudfront.net/site/assets/images/temp/badge-beer-default.png"

USER_CONFIG = "data/Users.csv"
USER_COUNT = `cat #{USER_CONFIG} | wc -l`
SET_CONFIG = "data/styles.csv"
SET_COUNT = `cat #{SET_CONFIG} | wc -l`

def getSetIndex(inSet)
  index = 0
  CSV.foreach(SET_CONFIG) do |row|
      if row[0] == inSet then
        return index
      end
      index = index + 1
  end
  return -1
end

bids = Array.new(SET_COUNT.to_i) { Hash.new() }

CSV.foreach(USER_CONFIG) do |user|

    $user_file = "user_data/#{user[0]}_distinct_beers.csv"

    puts "Reading: #{$user_file}..."

    counter = 0
    CSV.foreach($user_file, converters: :numeric) do |row|

        c = Distinct_beer.new(row)

        s = getSetIndex(c.beer_style.strip)

        if s != -1 then

            bids[s][c.beer_bid] = c

        end
        counter += 1
    end

    puts "...#{counter} beers read"
end

output = open("cheatSheet.html", "w")

output.write("<html>\n<head>\n<style>\n")
output.write("table,th,td\n{border:1px solid black;\nborder-collapse:collapse;}\nth,td\n{padding:5px;}")
output.write("\n</style>\n</head><body>\n<table>\n")


CSV.foreach(SET_CONFIG) do |set|

    if set.size() == 3 then

        s = getSetIndex(set[0])

        puts "#{set[2]}"

        output.write("  <tr>\n    <th>#{set[2]}</th>\n")
  
        $i = 0

        bids[s].values.sort.reverse.each do |beer|

            if $i >= 10
                break
            end

            if beer.beer_rating_count >= 1000 then
                puts "--- #{beer.beer_name} - #{beer.brewery_name} :#{beer.beer_rating_score.round(3)}"
  
                img = ""
                if "#{beer.beer_label}" != DEFAULT_PNG then
                  img = "#{beer.beer_label}"
                else
                  img = "#{beer.brewery_label}"
                end

#                search = "https://www.google.com/search?q=#{beer.beer_name}+#{beer.brewery_name}+site:beermenus.com&btnI"              
                search = "https://www.beermenus.com/search?q=#{beer.beer_name}"              
                search = search.gsub(" ", "+")

                str = "<a href=\"#{search}\" target=\"main\"><img src=\"#{img}\"><br></a>"
   
                title = "#{beer.beer_name}<br>#{beer.brewery_name}<br>(#{beer.beer_rating_score.round(3)})"
                output.write("  <td align=\"center\" >#{str}#{title}</td>\n")
  
                $i += 1
            end
        end

        output.write("  </tr>\n")

    end

end

output.write("</table>\n</body>\n</html>")

output.close

$endTime = Time.now

$duration = $endTime - $startTime

puts "Duration: #{$duration}"
