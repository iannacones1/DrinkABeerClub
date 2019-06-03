#!/usr/bin/ruby
require 'drink-socially'
require 'csv'
require '/home/pi/git/DrinkABeerClub/getUserDistinctBeers.rb'
require '/home/pi/git/DrinkABeerClub/Classes/DistinctBeer.rb'

USER_CONFIG = "data/2019_Users.csv"

if ARGV[0].nil?
    puts "Please input username"
    exit 1
end

$user = ARGV[0]

puts "Loading User: #{$user}"

$temp_file = "#{$user}_distinct_beers.csv"
$user_file = "user_data/#{$user}_distinct_beers.csv"

puts "Updating File: #{$user_file}"

$shouldStop = false

$index = 0

`touch #{$temp_file}`
`rm #{$temp_file}`

`touch #{$user_file}`

$last_bid

CSV.foreach($user_file, converters: :numeric) do |row|

    c = Distinct_beer.new(row)

    $last_bid = c.beer_bid

    break
end

puts "Last BID: #{$last_bid}"

feed = getUserDistinctBeers("#{$user}", $index)

temp = CSV.open($temp_file, 'w')

$additions = 0

#puts "#{feed.inspect}"

while !feed.nil? &&
      !feed["response"].nil? &&
      !feed["response"].first.nil? &&
      !feed["response"]["beers"].nil? &&
      !feed["response"]["beers"]["count"].nil? &&
       feed["response"]["beers"]["count"] > 0 &&
      !feed["response"]["beers"]["items"].nil? &&
       feed["response"]["beers"]["items"].count > 0 do

    $index = $index + feed["response"]["beers"]["items"].count

puts "#{$index}"

    feed["response"]["beers"]["items"].each do |c|

        if c["beer"]["bid"] != $last_bid
            $additions = $additions + 1
            temp.add_row(["#{c['beer']['bid']}",
                          "#{c['first_checkin_id']}",
                          "#{c['first_created_at']}",
                          "#{c['recent_checkin_id']}",
                          "#{c['recent_created_at']}",
                          "#{c['rating_score']}",
                          "#{c['first_had']}",
                          "#{c['count']}",
                          "#{c['beer']['beer_name']}",
                          "#{c['beer']['beer_label']}",
                          "#{c['beer']['beer_abv']}",
                          "#{c['beer']['beer_style']}",
                          "#{c['beer']['rating_score']}",
                          "#{c['beer']['rating_count']}",
                          "#{c['brewery']['brewery_id']}",
                          "#{c['brewery']['brewery_name']}",
                          "#{c['brewery']['brewery_label']}",
                          "#{c['brewery']['country_name']}",
                          "#{c['brewery']['location']['brewery_city']}",
                          "#{c['brewery']['location']['brewery_state']}",
                          "#{c['brewery']['location']['lat']}",
                          "#{c['brewery']['location']['lng']}"])
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

    if feed["response"]["beers"]["items"].count < 50
        feed["response"]["beers"]["items"].clear
    else
       puts "added: #{feed['response']['beers']['items'].count}"

#      feed = oauth.user_distinct_beers(username: "#{$user}", offset: $index, limit: $limit)
        feed = getUserDistinctBeers("#{$user}", $index)

 #     puts oauth.rate_limit.inspect
    end

end

temp.close

`cat #{$user_file} >> #{$temp_file}`

if $additions == 0
    `rm #{$temp_file}`
end

#puts oauth.rate_limit.inspect
puts "Additions: #{$additions}"
