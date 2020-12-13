#!/usr/bin/ruby
require 'date'
require 'csv'
require_relative 'getUntappdData.rb'

if ARGV.empty?
    puts "Pass in BID"
    exit
end

bid = ARGV[0]

beerInfo = getBeerInfo(bid)
    
if feedHasResponse(beerInfo) &&
   !beerInfo["response"]["beer"].nil? &&
   !beerInfo["response"]["beer"]["vintages"].nil? &&
   !beerInfo["response"]["beer"]["vintages"]["count"].nil? &&
    beerInfo["response"]["beer"]["vintages"]["count"].to_i > 0 &&
   !beerInfo["response"]["beer"]["vintages"]["items"].nil? &&
    beerInfo["response"]["beer"]["vintages"]["items"].count > 0 &&

    beerInfo["response"]["beer"]["vintages"]["items"].each do |item|

        if (item["beer"]["is_vintage"] == 1)
            puts "#{item['beer']['bid']},"
        end
    end

end
