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
