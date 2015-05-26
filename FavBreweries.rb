#!/usr/bin/ruby
require 'csv'
require '/home/pi/git/DrinkABeerClub/Classes/DistinctBeer.rb'

if ARGV[0].nil?
    puts "Please input username"
    exit 1
end

$user = ARGV[0]

$user_file = "user_data/#{$user}_distinct_beers.csv"

userRating = Hash.new(0)
breweryCount = Hash.new(0)
breweryInfo = Hash.new

CSV.foreach($user_file, converters: :numeric) do |row|

    c = Distinct_beer.new(row)

    userRating[c.brewery_name] += (c.rating_score == 0 ? c.beer_rating_score : c.rating_score)
    breweryInfo[c.brewery_name] = c
    breweryCount[c.brewery_name] += 1

end

$i = 1
$lastRating = 0
$tie = 0

$Header = "+" + "-" * 5 + "+" + "-" * 7 + "+" + "-" * 52 + "+" + "-" * 5 + "+"

puts $user + "'s Favorite Breweries"
puts $Header
puts "| RNK | SCORE | " + "BREWERY".ljust(50) + " | CNT |"

userRating.sort_by { |brewery, rating| rating }.reverse.each do |brewery, rating|

    $rate = rating.round(2).to_s
    $z = $i.to_s
    if $lastRating == rating
        $tie += 1
        $z = ""
        $rate = ""
    else
        $tie = 0
        puts $Header
    end

  puts "| #{$z.ljust(3)} | #{$rate.ljust(5)[0..4]} | " + brewery.encode(Encoding::ISO_8859_1, {:invalid => :replace, :undef => :replace, :replace => "?"}).ljust(50)+ " | #{breweryCount[brewery].to_s.ljust(3)} |"

    $i += 1
    $lastRating = rating

end

puts $Header

