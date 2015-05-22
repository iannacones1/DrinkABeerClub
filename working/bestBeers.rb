#!/usr/bin/ruby
require 'drink-socially'
require 'csv'
require '/home/pi/git/DrinkABeerClub/tokens/untappdConfigure.rb'

DEFAULT_PNG = "https://d1c8v1qci5en44.cloudfront.net/site/assets/images/temp/badge-beer-default.png"

USER_CONFIG = "data/TestUsers.csv"

oauth = NRB::Untappd::API.new access_token: getToken

CSV.foreach(USER_CONFIG) do |user|

    puts "Loading user #{user[0]}"

    $index = 0

    feed = oauth.user_distinct_beers(username: user[0], sort: "highest_rated", offset: $index)
    
    while feed.body.response.beers.items.count > 0 do

        $index = $index + feed.body.response.beers.items.count

        feed.body.response.beers.items.each do |f|

            puts "#{f.beer.beer_name} - #{f.brewery.brewery_name}"

        end

        feed = oauth.user_distinct_beers(username: user[0], sort: "highest_rated", offset: $index)

    end
end

puts oauth.rate_limit.inspect
