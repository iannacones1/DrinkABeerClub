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

x = Array.new(USER_COUNT.to_i) { Array.new(SET_COUNT.to_i) }

# Jan 1 2015 +5 to GMT
yearStart = DateTime.new(2015,1,1,5,0,0)
# Jan 1 2016 +5 to GMT
yearEnd = DateTime.new(2016,1,1,5,0,0)

#load Distinct beer ratings
puts "Loading Ratings..."

ratings = Hash.new()

CSV.foreach(USER_CONFIG) do |user|
    $user_file = "user_data/#{user[0]}_distinct_beers.csv"
    CSV.foreach($user_file, converters: :numeric) do |row|
        ratings[row[0]] = row[12]
    end
end

# find highest rated for each style
u = 0

CSV.foreach(USER_CONFIG) do |user|

    puts "Building Styles for user: #{user[0]}"

    $user_file = "user_data/#{user[0]}_checkins.csv"

    CSV.foreach($user_file, converters: :numeric) do |row|

        f = Checkin.new(row)

        if DateTime.parse(f.created_at) >= yearStart && DateTime.parse(f.created_at) < yearEnd
            s = getSetIndex(f.beer_style.strip)
            if s != -1 then

                f.setRating(ratings[f.beer_bid])

                if x[u][s].nil? or x[u][s].beer_rating_score <= f.beer_rating_score then
                    x[u][s] = f
                end
            end         
        end
    end

    u = u + 1
end

output = open("table.html", "w")

output.write("<html>\n<head>\n<style>\n")
output.write("table,th,td\n{border:1px solid black;\nborder-collapse:collapse;}\nth,td\n{padding:5px;}")
output.write("\n</style>\n</head><body>\n<table>\n")
output.write("<caption>Last Updated: #{Time.now.asctime}</caption>\n<tr>\n")
output.write("  <th></th>\n")

CSV.foreach(USER_CONFIG) do |user|
  output.write("  <th><a href=\"http://www.DrinkABeerClub.com/#{user[0]}\">#{user[0]}</a></th>\n")
end

output.write("  </tr>\n")

output.write("<tr>\n  <th>Total:</th>\n")

$user_totals = Array.new(USER_COUNT.to_i, 0) 

u = 0
CSV.foreach(USER_CONFIG) do |user|
    CSV.foreach(SET_CONFIG) do |state|
        s = getSetIndex(state[0])
        if !x[u][s].nil? then
          $user_totals[u] += 1
        end
    end
    output.write("  <td align=\"center\">#{$user_totals[u]}\\51</td>\n")
    u = u + 1
end

output.write("<tr>\n  <th>Score:</th>\n")

u = 0
CSV.foreach(USER_CONFIG) do |user|
    $score = 0
    CSV.foreach(SET_CONFIG) do |state|
        s = getSetIndex(state[0])
        if !x[u][s].nil? then
            $score += x[u][s].beer_rating_score
        end
    end
    $avg = $score / $user_totals[u]
    output.write("  <td align=\"center\">#{$score.round(3)}<br />(#{$avg.round(3)})</td>\n")
    u = u + 1
end

output.write("  </tr>\n")

CSV.foreach(SET_CONFIG) do |set|
    if set.size() == 2 then
        output.write("  <tr>\n    <th>#{set[0]}<br/>\n      <img src=\"#{set[1]}\">\n    </th>\n  </tr>\n")
    else
        output.write("<tr>\n  <th><a href=\"https://untappd.com/beer/top_rated?type_id=#{set[1]}\">#{set[2]}</a></th>\n")
        s = getSetIndex(set[0])
        u = 0
        CSV.foreach(USER_CONFIG) do |user|
          title = ""
          str = ""
          if !x[u][s].nil? then
            title = "#{x[u][s].created_at}\n#{x[u][s].beer_name}\n#{x[u][s].brewery_name}\n#{x[u][s].beer_rating_score}"
            if "#{x[u][s].beer_label}" != DEFAULT_PNG then
                str = "<img src=\"#{x[u][s].beer_label}\" title=\"#{title}\">"
            else
                str = "#{x[u][s].beer_name}<br>#{x[u][s].brewery_name}"
            end
        end
        output.write("  <td align=\"center\" >#{str}</td>\n")
        u = u + 1
    end
    output.write("  </tr>\n")
  end
end

output.write("</table>\n</body>\n</html>")

output.close

$endTime = Time.now

$duration = $endTime - $startTime

puts "Duration: #{$duration}"
