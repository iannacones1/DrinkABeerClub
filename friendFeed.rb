require 'untappd'
require 'date'
require 'csv'
require '/home/pi/git/DrinkABeerClub/tokens/untappdConfigure.rb'

configUntappd

#token = getToken
token = 'E50B0C091A5F71832D218313B604BD6E83B64178'

output = open("friendFeed.csv", "w")

output.write("User,")

CSV.foreach("data/States.csv") do |row|
    output.write("#{row[1]},")
end

output.write("\n")

yearStart = Date.parse("31st Dec 2013")
yearEnd = Date.parse("1st Jan 2015")

userFeed = Array.new

$lastId = 0

feed = Untappd::User.friend_feed(token, {max_id: $lastId, limit: 50})

while Date.parse(feed.checkins.items.first.created_at) > yearStart do

    feed.checkins.items.each do |f|
        if Date.parse(f.created_at) > yearStart && Date.parse(f.created_at) < yearEnd
            userFeed.push(f)
        end
    end

    $lastId = feed.checkins.items.last.checkin_id
    feed = Untappd::User.friend_feed(token, {max_id: $lastId, limit: 50})

end

userFeed.each do |f|
    puts f
end

output.close
