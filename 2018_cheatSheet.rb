#!/usr/bin/ruby
require 'date'
require 'csv'
require '/home/pi/git/DrinkABeerClub/Classes/Checkin.rb'
require '/home/pi/git/DrinkABeerClub/Classes/2018_RegionMap.rb'
require '/home/pi/git/DrinkABeerClub/Classes/StyleMap.rb'

$startTime = Time.now

STYLE_CONFIG = "data/2018_styles.csv"
REGION_CONFIG = "data/2018_Regions.csv"
ORDER_CONFIG = "data/2018_order.csv"

HEADER="HEADER"
STYLE="STYLE"

REGIONS = RegionMap.new(REGION_CONFIG, ORDER_CONFIG)

STYLES = StyleMap.new(STYLE_CONFIG)

USER_CONFIG = "data/2018_DataUsers.csv"
USER_COUNT = `cat #{USER_CONFIG} | wc -l`

bids = Hash.new()

CSV.foreach(USER_CONFIG) do |user|

    $user_file = "user_data/#{user[0]}_distinct_beers.csv"

    if !File.file?("#{$user_file}") then
        puts "Missing file: #{$user_file}..."
        next
    end

    puts "Reading: #{$user_file}..."

    counter = 0
    CSV.foreach($user_file, converters: :numeric) do |row|

        c = Distinct_beer.new(row)

#next if c.is_homebrew

        s = STYLES.getStyle(c.beer_style)

        if !s.nil? then

            if bids[s].nil? then
                bids[s] = Hash.new()
            end

            r = REGIONS.getRegion(c, s)

            if bids[s][r].nil? then
                bids[s][r] = Hash.new()
            end

            bids[s][r][c.beer_bid] = c

        end
        counter += 1
    end

    puts "...#{counter} beers read"
end

output = open("cheatSheet_unlimited.html", "w")

output.write("<html>\n<head>\n<meta charset=\"UTF-8\">\n<style>\n")
output.write("table,th,td\n{border:1px solid black;\nborder-collapse:collapse;}\nth,td\n{padding:5px;}")
output.write("\n</style>\n</head><body>\n<table>\n")

CSV.foreach(ORDER_CONFIG) do |order|
    aType = "#{order[0]}"

    if aType == HEADER then
        region = "#{order[1]}"
        output.write("<th colspan=\"11\">#{region}<br>")

        i = 2
        while i < order.size()
          output.write("<img src=\"#{order[i]}\"> ")
            i += 1
        end

        output.write("</th>")
    else
        style = "#{order[1]}"
        region = "#{order[2]}"

        aRegion = "#{region} (inside)"
        bRegion = "#{region} (outside)"

        output.write("<tr><th>#{style} from inside Country of Origin</th>\n")

        $i = 0

        if !bids[style][aRegion].nil? then
          
        
        
        bids[style][aRegion].values.sort.reverse.each do |beer|

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

        end 
        output.write("  </tr>\n")

        output.write("<tr><th>#{style} from outside Country of Origin</th>\n")

        $i = 0

        bids[style][bRegion].values.sort.reverse.each do |beer|

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

    end
end

output.write("</table>\n</body>\n</html>")

output.close

$endTime = Time.now

$duration = $endTime - $startTime

puts "Duration: #{$duration}"
