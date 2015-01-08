#!/usr/bin/ruby
require 'drink-socially'
require 'csv'
require '/home/pi/git/DrinkABeerClub/tokens/untappdConfigure.rb'

DEFAULT_PNG = "https://d1c8v1qci5en44.cloudfront.net/site/assets/images/temp/badge-beer-default.png"

USER_CONFIG = "data/TestUsers.csv"

if ARGV[0].nil?
    puts "Please input username"
    exit 1
end

oauth = NRB::Untappd::API.new access_token: getToken

$user = ARGV[0]

puts "Loading User: #{$user}"

user_file = "user_data/#{$user}_distinct_beers.csv"

puts "Updating File:#{user_file}"

$shouldStop = false

$index = 0

`touch temp.out`
`rm temp.out`

`touch #{user_file}`

last_line = `head -1 #{user_file} | cut -d "," -f 1`
lastId = last_line.strip

feed = oauth.user_distinct_beers(username: "#{$user}", offset: $index)

temp = CSV.open('temp.out', 'w')

while feed.body.response.beers.items.count > 0 do

    $index = $index + feed.body.response.beers.items.count

    feed.body.response.beers.items.each do |c|

        currentId = "#{c.beer.bid}"

        if currentId != lastId
            puts "adding Id: #{currentId}"
#            temp.add_row([c.first_checkin_id, c.beer.bid, c.beer.beer_name])
            temp.add_row([c.beer.bid,
                          c.first_checkin_id,
                          c.first_created_at,
                          c.recent_checkin_id,
                          c.recent_created_at,
                          c.rating_score,
                          c.first_had,
                          c.count,
                          c.beer.beer_name,
                          c.beer.beer_label,
                          c.beer.beer_abv,
                          c.beer.beer_style,
                          c.beer.rating_score,
                          c.beer.rating_count,
                          c.brewery.brewery_id,
                          c.brewery.brewery_name,
                          c.brewery.brewery_label,
                          c.brewery.country_name,
                          c.brewery.location.brewery_city,
                          c.brewery.location.brewery_state,
                          c.brewery.location.lat,
                          c.brewery.location.lng])
        else
            $shouldStop = true
            break
        end
 
        if $shouldStop
            break
        end
    end

    if $shouldStop
        break
    end

    if feed.body.response.beers.items.count < 25
        feed.body.response.beers.items.clear
    else
      feed = oauth.user_distinct_beers(username: "#{$user}", offset: $index)
      puts oauth.rate_limit.inspect
    end

end

temp.close

`cat #{user_file} >> temp.out && mv temp.out #{user_file}`

puts oauth.rate_limit.inspect
