#!/usr/bin/ruby
require 'date'
require 'csv'
require_relative 'getUntappdData.rb'
require_relative 'Classes/Checkin.rb'

if ARGV[0].nil?
    puts "Please input username"
    exit 1
end

current_year = Date.today.year

# Jan 1 20XX +5 to GMT
yearStart = DateTime.new(current_year,1,1,5,0,0)

$user       = ARGV[0]
$temp_file  = "#{$user}_checkins.csv"
$user_file  = "user_data/#{$user}_checkins.csv"
$shouldStop = false
$index      = 0

puts "Loading User: #{$user}"
puts "Updating File: #{$user_file}"

`rm -f #{$temp_file}`
`touch #{$user_file}`

$last_bid

# Find the lates BID logged in $user_file
CSV.foreach($user_file, converters: :numeric) do |row|
    c = Checkin.new(row)
    $last_bid = c.beer_bid
    break
end

puts "Last BID: #{$last_bid}"

temp = CSV.open($temp_file, 'w')

$additions = 0

feed = getUserActivityFeed("#{$user}", $index)

while feedContainsActivity(feed, yearStart)

    puts "#{DateTime.parse(feed["response"]["checkins"]["items"].first["created_at"]).asctime}"

    $index = feed["response"]["checkins"]["items"].last["checkin_id"]

    feed["response"]["checkins"]["items"].each do |c|

        if c["beer"]["bid"] != $last_bid
            $additions = $additions + 1
            temp.add_row(["#{c['beer']['bid']}",
                          "#{c['checkin_id']}",
                          "#{c['created_at']}",
                          "#{c['rating_score']}",
                          "#{c['beer']['beer_name']}",
                          "#{c['beer']['beer_label']}",
                          "#{c['beer']['beer_abv']}",
                          "#{c['beer']['beer_style']}",
                          "#{c['brewery']['brewery_id']}",
                          "#{c['brewery']['brewery_name']}",
                          "#{c['brewery']['brewery_label']}",
                          "#{c['brewery']['country_name']}",
                          "#{c['brewery']['location']['brewery_city']}",
                          "#{c['brewery']['location']['brewery_state']}",
                          "#{c['brewery']['location']['lat']}",
                          "#{c['brewery']['location']['lng']}",
                          "#{c['user']['user_name']}"])

        else
            # if this BID matches last_bid
            $shouldStop = true
            break
        end
 
    end

    if $shouldStop
        break
    end

    if feed["response"]["checkins"]["items"].count < 50
        # If the feed has less then 50 entries then we've reached the end
        # (clearing it will cause the do while loop to end)
        feed["response"]["checkins"]["items"].clear
    else
        puts "added: #{feed['response']['checkins']['items'].count}"
        feed = getUserActivityFeed("#{$user}", $index)
    end

end

temp.close

`cat #{$user_file} >> #{$temp_file}`

if $additions == 0
    `rm #{$temp_file}`
end

puts "Additions: #{$additions}"
