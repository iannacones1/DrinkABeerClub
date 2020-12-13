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
   !beerInfo["response"]["beer"]["vintage_parent"].nil?

    parent_bid = beerInfo["response"]["beer"]["vintage_parent"]["beer"]["bid"]

    puts "#{bid} is vintage of #{parent_bid}"
    aFile = open("vintages/#{parent_bid}.csv", "a")
    aFile.write("#{bid},\n")
    aFile.close
end
