require 'untappd'
require '/home/pi/git/DrinkABeerClub/untappdConfigure.rb'

configUntappd

token = getToken

puts token

beers = Untappd::User.distinct('iannacones1')

$i = 0

beers.beers.items.each do |beer|
  puts "#$i #{beer.beer.beer_name}"
  $i += 1
end
