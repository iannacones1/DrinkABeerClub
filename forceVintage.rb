#!/usr/bin/ruby
require 'drink-socially'
require 'date'
require 'csv'
require '/home/pi/git/DrinkABeerClub/tokens/untappdConfigure.rb'

if ARGV.empty?
    puts "Pass in BID"
    exit
end

oauth = NRB::Untappd::API.new client_id: getClientId, client_secret: getClientSecret

bid = ARGV[0]

beerInfo = oauth.beer_info(bid: bid, compact: true)
            
if beerInfo.respond_to? :vintage_parent then
    puts "#{bid} is vintage of #{beerInfo.vintage_parent.beer.bid}"
    aFile = open("vintages/#{beerInfo.vintage_parent.beer.bid}.csv", "a")
    aFile.write("#{bid},\n")
    aFile.close
end
