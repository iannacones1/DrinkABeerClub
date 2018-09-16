#!/usr/bin/ruby
require 'drink-socially'
require 'date'
require 'csv'
require '/home/pi/git/DrinkABeerClub/tokens/untappdConfigure.rb'
require '/home/pi/git/DrinkABeerClub/Classes/Checkin.rb'
require '/home/pi/git/DrinkABeerClub/Classes/DistinctBeer.rb'

if ARGV[0].nil?
    puts "Please input username"
    exit 1
end

# Jan 1 2018 +5 to GMT
yearStart = DateTime.new(2018,1,1,5,0,0)

oauth = NRB::Untappd::API.new access_token: getToken

$user = ARGV[0]

puts "Loading User: #{$user}"

$temp_file = "#{$user}_checkins.csv"
$user_file = "user_data/#{$user}_checkins.csv"
$distinct_file = "user_data/#{$user}_distinct_beers.csv"

puts "Updating File: #{$user_file}"

$shouldStop = false

$index = 0

`touch #{$temp_file}`
`rm #{$temp_file}`

if !File.exist?("#{$user_file}")
    `touch #{$user_file}`
end

$last_bid

CSV.foreach($user_file, converters: :numeric) do |row|

    c = Checkin.new(row)

    $last_bid = c.beer_bid

    break
end

puts "Last BID: #{$last_bid}"

feed = oauth.user_feed(username: "#{$user}", max_id: $index, limit:50)

temp = CSV.open($temp_file, 'w')

$additions = 0

while feed.body.response.size > 0 &&
      feed.body.response.checkins.size > 0 &&
      feed.body.response.checkins.items.count > 0 &&
      DateTime.parse(feed.body.response.checkins.items.first.created_at) >= yearStart do

    puts "#{DateTime.parse(feed.body.response.checkins.items.first.created_at).asctime}"

    $index = feed.body.response.checkins.items.last.checkin_id

    feed.body.response.checkins.items.each do |c|

        if c.beer.bid != $last_bid

            $additions = $additions + 1

            temp.add_row([c.beer.bid,
                          c.checkin_id,
                          c.created_at,
                          c.rating_score,
                          c.beer.beer_name,
                          c.beer.beer_label,
                          c.beer.beer_abv,
                          c.beer.beer_style,
                          c.brewery.brewery_id,
                          c.brewery.brewery_name,
                          c.brewery.brewery_label,
                          c.brewery.country_name,
                          c.brewery.location.brewery_city,
                          c.brewery.location.brewery_state,
                          c.brewery.location.lat,
                          c.brewery.location.lng,
                          c.user.user_name])
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

    if feed.body.response.checkins.items.count < 50
        feed.body.response.checkins.items.clear
    else
      feed = oauth.user_feed(username: "#{$user}", max_id: $index, limit:50)
      puts oauth.rate_limit.inspect
    end

end

temp.close

`cat #{$user_file} >> #{$temp_file}`

if $additions == 0
    puts "removing file no additions"
    `rm #{$temp_file}`
end

puts oauth.rate_limit.inspect
puts "Additions: #{$additions}"
