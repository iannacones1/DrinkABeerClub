#!/usr/bin/ruby
require 'drink-socially'
require 'date'
require 'csv'
require '/home/pi/git/DrinkABeerClub/tokens/untappdConfigure.rb'

DEFAULT_PNG = "https://d1c8v1qci5en44.cloudfront.net/site/assets/images/temp/badge-beer-default.png"

USER_CONFIG = "data/Users.csv"
SET_CONFIG = "data/styles.csv"
SET_COUNT = `wc #{SET_CONFIG} -l | cut -d \' \' -f 1`

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

oauth = NRB::Untappd::API.new access_token: getToken

output = open("beta.html", "w")

output.write("<html>\n<head>\n<style>\n")
output.write("table,th,td\n{border:1px solid black;\nborder-collapse:collapse;}\nth,td\n{padding:5px;}")
output.write("\n</style>\n</head><body>\n<table>\n")
output.write("<caption>Last Updated: #{Time.now.asctime}</caption>\n<tr>\n")
output.write("  <th></th>\n")

userCount = 0
CSV.foreach(USER_CONFIG) do |user|
  output.write("  <th><a href=\"http://www.DrinkABeerClub.com/#{user[0]}\">#{user[0]}</a></th>\n")
  userCount = userCount + 1
end

output.write("  </tr>\n")

x = Array.new(userCount) { Array.new(SET_COUNT.to_i) }

# Jan 1 2014 +5 to GMT
yearStart = DateTime.new(2014,1,1,5,0,0)
# Jan 1 2015 +5 to GMT
yearEnd = DateTime.new(2015,1,1,5,0,0)

u = 0

CSV.foreach(USER_CONFIG) do |user|

    puts "Building Styles for user: #{user[0]}"

    $lastId = 0

    feed = oauth.user_feed(username: user[0], max_id: $lastId, limit:50)

    while feed.body.response.checkins.items.size > 0 && DateTime.parse(feed.body.response.checkins.items.first.created_at) >= yearStart do

        feed.body.response.checkins.items.each do |f|

            if DateTime.parse(f.created_at) >= yearStart && DateTime.parse(f.created_at) < yearEnd
                s = getSetIndex(f.beer.beer_style)
                if s != -1 then
                    if x[u][s].nil? or x[u][s].rating_score <= f.rating_score then
                        x[u][s] = f
                    end
              end         
            end
        end

        $lastId = feed.body.response.checkins.items.last.checkin_id

        feed = oauth.user_feed(username: user[0], max_id: $lastId, limit:50)

        puts oauth.rate_limit.inspect

    end
    u = u + 1
end

output.write("<tr>\n  <th>Total:</th>\n")

u = 0
CSV.foreach(USER_CONFIG) do |user|
  t = 0
  CSV.foreach(SET_CONFIG) do |state|
    s = getSetIndex(state[0])
    if !x[u][s].nil? then
      t = t + 1
    end
  end
  output.write("  <td align=\"center\">#{t}\\50</td>\n")
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

        title = "#{x[u][s].created_at}\n#{x[u][s].beer.beer_name}\n#{x[u][s].brewery.brewery_name}"
    
        if "#{x[u][s].beer.beer_label}" != DEFAULT_PNG then
          str = "<img src=\"#{x[u][s].beer.beer_label}\">"
        else
          str = "#{x[u][s].beer.beer_name}<br>#{x[u][s].brewery.brewery_name}"
        end

      end

      output.write("  <td align=\"center\" title=\"#{title}\">#{str}</td>\n")

      u = u + 1

    end

    output.write("  </tr>\n")

  end

end

puts oauth.rate_limit.inspect

output.write("</table>\n</body>\n</html>")

output.close
