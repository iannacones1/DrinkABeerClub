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

beerInfo = oauth.beer_info(bid: ARGV[0], compact: true)
    
if beerInfo.respond_to? :vintages
    beerInfo.vintages.items.each do |item|

        if (item.beer.is_vintage == 1)
            puts "#{item.beer.bid},"
        end
    end
end
