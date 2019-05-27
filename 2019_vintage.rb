#!/usr/bin/ruby

require 'drink-socially'
require 'date'
require 'csv'
require '/home/pi/git/DrinkABeerClub/Classes/Checkin.rb'
require '/home/pi/git/DrinkABeerClub/tokens/untappdConfigure.rb'

if ARGV.size() != 3 then
    puts "USAGE ./2019_vintage.rb YEAR INPUT_BID_CSV INPUT_USERS_CSV"
    exit 1
end

def addIgnore(distinctBeer)
  puts "#{distinctBeer.beer_name} IS NOT a vintage"
  aFile = open(IGNORE_FILE, "a")
  aFile.write("#{distinctBeer.beer_bid},\n")
  aFile.close
end

$startTime = Time.now

YEAR = ARGV[0].to_i
BID_CONFIG = "#{ARGV[1]}"
USER_CONFIG = "#{ARGV[2]}"
IGNORE_FILE = "vintages/ignore.csv"

IGNORE = Hash.new()
CSV.foreach(IGNORE_FILE, converters: :numeric) do |aRow|
    if aRow.empty? then
        next
    end
    bid = aRow[0]
    IGNORE[bid] = bid
end

VINTAGE = Hash.new()
CSV.foreach(BID_CONFIG, converters: :numeric) do |aRow|

    if aRow.empty? then
        next
    end

    bid = aRow[1]
    
    $vintage_file = "vintages/#{bid}.csv"

    CSV.foreach($vintage_file, converters: :numeric) do |bRow|
        if bRow.empty? then
            next
        end

        VINTAGE[bRow[0]] = bid
        
    end
end

USERS = Array.new()
CSV.foreach(USER_CONFIG) { |user| USERS.push("#{user[0]}") }

# Jan 1 20XX +5 to GMT
yearStart = DateTime.new(YEAR.to_i,1,1,5,0,0)
# Jan 1 20XX+1 +5 to GMT
yearEnd = DateTime.new(YEAR.to_i + 1,1,1,5,0,0)

puts "Reading distinct beers for all users"

BEERS = Hash.new()

USERS.each do |user|
    $user_file = "user_data/#{user}_distinct_beers.csv"
    CSV.foreach($user_file, converters: :numeric) do |row|

        if row.empty? then
            next
        end
    
        distinctBeer = Distinct_beer.new(row)
        bid = distinctBeer.beer_bid

        if !VINTAGE.has_key?(bid) &&
           DateTime.parse(distinctBeer.recent_created_at) >= yearStart &&
           DateTime.parse(distinctBeer.recent_created_at) <  yearEnd then

            if /(\d{4})/ =~ distinctBeer.beer_name.to_s
                if BEERS[bid].nil? then
                    BEERS[bid] = distinctBeer 
                end
            end

        end
    end
end

USERS.each do |user|
    $user_file = "user_data/#{user}_checkins.csv"
    CSV.foreach($user_file, converters: :numeric) do |row|

        if row.empty?
            next
        end
      
        checkin = Checkin.new(row)
        bid = checkin.beer_bid

        if !VINTAGE.has_key?(bid) &&
           DateTime.parse(checkin.created_at) >= yearStart &&
           DateTime.parse(checkin.created_at) < yearEnd then

            if /(\d{4})/ =~ checkin.beer_name.to_s
                if BEERS[bid].nil? then
                    BEERS[bid] = checkin
                    puts "CHECK #{bid}"
                end
            end
        end
    end
end

oauth = NRB::Untappd::API.new client_id: getClientId, client_secret: getClientSecret

BEERS.each do |bid, distinctBeer|

    CSV.foreach(BID_CONFIG, converters: :numeric) do |aRow|

        if aRow.empty? then
            next
        end

        if IGNORE.has_key?(bid)
            next
        end

        if aRow[3] == distinctBeer.brewery_name &&
           distinctBeer.beer_name.to_s.start_with?("#{aRow[2]}")

            beerInfo = oauth.beer_info(bid: bid, compact: true)
            puts "Limit = #{oauth.rate_limit.remaining}"
            
            if beerInfo.respond_to? :vintage_parent then
                if beerInfo.vintage_parent.beer.bid == aRow[1] then
                    puts "#{distinctBeer.beer_name} IS a vintage of #{aRow[2]}"
                    aFile = open("vintages/#{aRow[1]}.csv", "a")
                    aFile.write("#{bid},\n")
                    aFile.close
                else
                    addIgnore(distinctBeer)
                end
            else
                addIgnore(distinctBeer)
            end
        end
    end
end

$endTime = Time.now

$duration = $endTime - $startTime

puts "Duration: #{$duration}"
