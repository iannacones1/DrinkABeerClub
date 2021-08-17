#!/usr/bin/ruby
require 'csv'
require_relative 'getUntappdData.rb'
require_relative 'Classes/DistinctBeer.rb'

if ARGV[0].nil?
    puts "Please input username"
    exit 1
end

$user       = ARGV[0]
$temp_file  = "#{$user}_distinct_beers.csv"
$user_file  = "user_data/#{$user}_distinct_beers.csv"
$shouldStop = false
$index      = 0

puts "Loading User: #{$user}"
puts "Updating File: #{$user_file}"

`rm -f #{$temp_file}`
`touch #{$user_file}`

$last_bid

# Find the latest BID logged in $user_file
CSV.foreach($user_file, converters: :numeric) do |row|
    c = Distinct_beer.new(row)
    $last_bid = c.beer_bid
    break
end

puts "Last BID: #{$last_bid}"

temp = CSV.open($temp_file, 'w')

$additions = 0

feed = getUserDistinctBeers("#{$user}", $index)

while feedContainsUserDistinctData(feed) do

    $index = $index + feed["response"]["beers"]["items"].count

    puts "index=#{$index}"

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
            # if this BID matches last_bid
            puts "c[beer][bid] == $last_bid; shouldStop = true; Break"
            $shouldStop = true
            break
        end
 
    end

    if $shouldStop
        puts "shouldStop = true; Break"
        break
    end

    if feed["response"]["beers"]["items"].count < 50
	puts "if feed[response][beers][items].count < 50; break"
        # If the feed has less then 50 entries then we've reached the end
        break
    else
       puts "added: #{feed['response']['beers']['items'].count}"
       feed = getUserDistinctBeers("#{$user}", $index)
    end

end

temp.close

`cat #{$user_file} >> #{$temp_file}`

if $additions == 0
    `rm #{$temp_file}`
end

puts "Additions: #{$additions}"
