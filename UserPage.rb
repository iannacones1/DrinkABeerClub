#!/usr/bin/ruby
require 'drink-socially'
require 'csv'
require '/home/pi/git/DrinkABeerClub/tokens/untappdConfigure.rb'

DEFAULT_PNG = "https://d1c8v1qci5en44.cloudfront.net/site/assets/images/temp/badge-beer-default.png"

USER_CONFIG = "data/Users.csv"

oauth = NRB::Untappd::API.new access_token: getToken

$userCount = 0
CSV.foreach(USER_CONFIG) do |user|
    $userCount = $userCount + 1
end

$u = 0 

$currentHour = Time.now.hour % $userCount

CSV.foreach(USER_CONFIG) do |user|

    if $u != $currentHour
        $u = $u + 1
        next
    end 

    output = open("#{user[0]}.html", "w")
    userCor = open("#{user[0]}.cor", "w")
    output.write("<html>\n\t<head>\n\t\t<font size=\"6\" face=\"Verdana\">#{user[0]}</font><br>\n\t</head>\n\t<body>\n")

    userRating = Hash.new(0)
    breweryCount = Hash.new(0)
    breweryInfo = Hash.new
    distinctBeers = Hash.new

    puts "Building User Page: #{user[0]}.html"

    $index = 0

    feed = oauth.user_distinct_beers(username: user[0], offset: $index)
    
    while feed.body.response.beers.items.count > 0 do

        $index = $index + feed.body.response.beers.items.count

        feed.body.response.beers.items.each do |c|

            d = Date.parse(c.first_had)
            t = d.to_time.localtime

            if distinctBeers[t.year].nil?
                distinctBeers[t.year] = Array.new
            end

            distinctBeers[t.year].push(c)

            if c.brewery.location.lng != 0 || c.brewery.location.lat != 0
                userCor.write("#{c.brewery.location.lng} #{c.brewery.location.lat}\n\n")
            else
                puts "#{c.brewery.brewery_name} has no location!!!"
            end

            if c.beer.auth_rating == 0 then
                puts "No user rating for: #{c.brewery.brewery_name}'s #{c.beer.beer_name} using rating_score: #{c.beer.rating_score}"
            end
            userRating[c.brewery.brewery_name] += (c.beer.auth_rating == 0 ? c.beer.rating_score : c.beer.auth_rating)
            breweryInfo[c.brewery.brewery_name] = c.brewery
            breweryCount[c.brewery.brewery_name] += 1
        end

        if feed.body.response.beers.items.count <  25
            feed.body.response.beers.items.clear
        else
            feed = oauth.user_distinct_beers(username: user[0], offset: $index)
        end

   end

    output.write("\t\t<pr><font face=\"Verdana\">Distinct Checkins by Year<br>\n")

    t = Time.new

    distinctBeers.each do |year, checkinArray|
        output.write("#{year}: #{checkinArray.size} ")
        
        if "#{year}" == "#{t.year}"
           output.write("(#{t.yday}) [#{t.yday - checkinArray.size}] ")      
        end

        output.write("<br>\n")

    end

    output.write("\t\t</font></pr>\n")
    output.write("\t\t<pr><font face=\"Verdana\">Favorite Breweries</font><br>\n")

    $i = 0
    $lastRating = 0

    userRating.sort_by { |brewery, rating| rating }.reverse.each do |brewery, rating|
        if $i >= 10 && $lastRating > rating
            break
        end
        puts "#{brewery}, #{breweryCount[brewery]}, #{rating}\n"
        output.write("\t\t\t<img src=\"#{breweryInfo[brewery].brewery_label}\" title=\"#{brewery} - #{breweryCount[brewery]} / #{rating}\">\n")
        $i = $i + 1
        $lastRating = rating
        if $i % 5 == 0
            output.write("\t\t\t<br>\n")
        end
    end

    output.write("\t\t</pr>\n")

    output.write("\t\t<img src=\"#{user[0]}_usa.png\"><br>\n")
    output.write("\t\t<img src=\"#{user[0]}.png\"><br>\n")

    output.write("\n\nLast Updated: #{Time.now.asctime}")
    output.write("\t</body>\n<html>")
    output.close
    userCor.close

    $u = $u + 1

end

puts oauth.rate_limit.inspect

