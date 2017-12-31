#!/usr/bin/ruby
require 'drink-socially'
require 'date'
require 'csv'
require '/home/pi/git/DrinkABeerClub/tokens/untappdConfigure.rb'


if ARGV.empty?
    puts "Pass in BID"
    exit
end

oauth = NRB::Untappd::API.new access_token: getToken

beerInfo = oauth.beer_info(bid: ARGV[0], compact: true)
    
puts beerInfo.inspect


puts "============ BEER INFO ============"
puts "            Name: #{beerInfo.beer_name}"
puts "              ID: #{beerInfo.bid}"
puts "           Style: #{beerInfo.beer_style}"
puts "             ABV: #{beerInfo.beer_abv}%"
puts "    Rating Count: #{beerInfo.rating_count}"
puts "    Rating Score: #{beerInfo.rating_score}"
puts "     Total Count: #{beerInfo.stats.total_count}"
puts "Total User Count: #{beerInfo.stats.total_user_count}"
puts "============= BREWERY ============="
puts "            Name: #{beerInfo.brewery.brewery_name}"
puts "              ID: #{beerInfo.brewery.brewery_id}"
puts "        Location: #{beerInfo.brewery.location.brewery_city}, #{beerInfo.brewery.location.brewery_state} #{beerInfo.brewery.country_name}"

if beerInfo.respond_to? :vintage_parent
puts "=========== VINTAGE OF ==========="
puts "            Name: #{beerInfo.vintage_parent.beer.beer_name}"
puts "              ID: #{beerInfo.vintage_parent.beer.bid}"
puts "             ABV: #{beerInfo.vintage_parent.beer.beer_abv}%"
end

if beerInfo.respond_to? :vintages

puts "====== VINTAGES AND VARIANTS ======"
puts "           Count: #{beerInfo.vintages.count}"

i = 1
beerInfo.vintages.items.each do |item|
str = "?"

var = (item.beer.is_variant == 1)
vin = (item.beer.is_vintage == 1)

if var && vin
str = "Both"
elsif var
str = "Variant"
elsif vin
str = "Vintage"
end
puts str + " ##{i}: #{item.beer.beer_name} [#{item.beer.bid}]"

i +=1
end
end

puts "Limit = #{oauth.rate_limit.remaining}"
