#!/usr/bin/ruby
require 'drink-socially'
require 'date'
require 'csv'
require '/home/pi/git/DrinkABeerClub/tokens/untappdConfigure.rb'

DEFAULT_PNG = "https://d1c8v1qci5en44.cloudfront.net/site/assets/images/temp/badge-beer-default.png"

def getStateIndex(inState)
  index = 0
  CSV.foreach("data/States.csv") do |row|
      if row[0] == inState then
        return index
      end
      index = index + 1 
  end
  return -1
end

oauth = NRB::Untappd::API.new access_token: getToken

output = open("table.html", "w")

output.write("<html>\n<head>\n<style>\n")
output.write("table,th,td\n{border:1px solid black;\nborder-collapse:collapse;}\nth,td\n{padding:5px;}")
output.write("\n</style>\n</head><body>\n<table>\n")
output.write("<caption>Last Updated: #{Time.now}</caption>\n<tr>\n")
output.write("  <th></th>\n")

userCount = 0
CSV.foreach("data/Users.csv") do |user|
  output.write("  <th>#{user[0]}</th>\n")
  userCount = userCount + 1
end

output.write("  </tr>\n")

x = Array.new(userCount) { Array.new(50) }

yearStart = Date.parse("31st Dec 2013")
yearEnd = Date.parse("1st Jan 2015")

u = 0

CSV.foreach("data/Users.csv") do |user|

    puts "Loading user #{user[0]}"

    userFeed = Array.new

    $lastId = 0

    feed = oauth.user_feed(username: user[0], max_id: $lastId, limit:50)

    while Date.parse(feed.body.response.checkins.items.first.created_at) > yearStart do

        feed.body.response.checkins.items.each do |f|

            if Date.parse(f.created_at) > yearStart && Date.parse(f.created_at) < yearEnd
              s = getStateIndex(f.brewery.location.brewery_state)
              if s != -1 then

                if x[u][s].nil? or x[u][s].rating_score < f.rating_score then
                    x[u][s] = f
                end

              end         
            end
        end

        $lastId = feed.body.response.checkins.items.last.checkin_id

        feed = oauth.user_feed(username: user[0], max_id: $lastId, limit:50)
    end
    u = u + 1
end

output.write("<tr>\n  <th>Total:</th>\n")

u = 0
CSV.foreach("data/Users.csv") do |user|
  t = 0
  CSV.foreach("data/States.csv") do |state|
    s = getStateIndex(state[0])
    if !x[u][s].nil? then
      t = t + 1
    end
  end
  output.write("  <td align=\"center\">#{t}\\50</td>\n")
  u = u + 1
end

output.write("  </tr>\n")

CSV.foreach("data/States.csv") do |state|

  output.write("<tr>\n  <th>#{state[1]}</th>\n")

  s = getStateIndex(state[0])

  u = 0

  CSV.foreach("data/Users.csv") do |user|

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

output.write("</table>\n</body>\n</html>")

output.close
