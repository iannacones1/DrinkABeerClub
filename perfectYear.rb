#!/usr/bin/ruby
require 'drink-socially'
require 'csv'
require '/home/pi/git/DrinkABeerClub/tokens/untappdConfigure.rb'

DEFAULT_PNG = "https://d1c8v1qci5en44.cloudfront.net/site/assets/images/temp/badge-beer-default.png"

USER_CONFIG = "data/TestUsers.csv"

oauth = NRB::Untappd::API.new access_token: getToken

CSV.foreach(USER_CONFIG) do |user|

    distinctBeers = Hash.new

    puts "Loading user #{user[0]}"

    $index = 0

    feed = oauth.user_distinct_beers(username: user[0], offset: $index)
    
    while feed.body.response.beers.items.count > 0 do

        $index = $index + feed.body.response.beers.items.count

        feed.body.response.beers.items.each do |checkin|

            d = Date.parse(checkin.first_had)
            t = d.to_time.localtime     

            if distinctBeers[t.year].nil?
                distinctBeers[t.year] = Array.new
            end

            distinctBeers[t.year].push(checkin)

        end

        if feed.body.response.beers.items.count <  25
            feed.body.response.beers.items.clear
        else 
            feed = oauth.user_distinct_beers(username: user[0], offset: $index)
        end

   end

    distinctBeers.each do |year, checkinArray|
        puts "#{year} Total: #{checkinArray.size}"
        checkinArray.each do |checkin|
            puts "\"#{checkin.beer.beer_name}\",\"#{checkin.brewery.brewery_name}\",\"#{checkin.beer.auth_rating}\""
        end
    end

end

puts oauth.rate_limit.inspect

