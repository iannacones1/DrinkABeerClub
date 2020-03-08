#!/usr/bin/ruby
require 'drink-socially'
require 'date'
require 'csv'
require '/home/pi/git/DrinkABeerClub/tokens/untappdConfigure.rb'

INPUT_FILE = "data/2020List.csv"
OUTPUT_FILE = "data/2020.csv"

if File.exist?(OUTPUT_FILE)
    File.delete(OUTPUT_FILE)
end

oauth = NRB::Untappd::API.new client_id: getClientId, client_secret: getClientSecret

$index = 1

CSV.foreach(INPUT_FILE) do |line|

    sleep(1)

    $beerId = "#{line[0]}"

    beerInfo = oauth.beer_info(bid: $beerId, compact: true)

    #puts "#{beerInfo.inspect}"

    puts "#{$index},#{$beerId}"

    # open csv with read/write append
    CSV.open(OUTPUT_FILE, "a+") do |csv|
        csv << ["#{$index}",
                "#{$beerId}",
                "#{beerInfo.beer_name}",
                "#{beerInfo.brewery.brewery_name}",
                "#{beerInfo.beer_label}",
                "#{beerInfo.brewery.brewery_label}" ]
    end

    vintageFile = "vintages/#{$beerId}.csv"

    # save all vintage information
    CSV.open(vintageFile, "w+") do |csv|
        if beerInfo.respond_to? :vintages
            beerInfo.vintages.items.each do |item|
                if (item.beer.is_vintage == 1)
                    csv << [ "#{item.beer.bid}" ]
                end
            end
        end
    end

    $index = $index + 1

    puts "Limit = #{oauth.rate_limit.remaining}"

    if oauth.rate_limit.remaining.to_i < 1
        puts "sleeping..."
        sleep(3600)
    end

end

