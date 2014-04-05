require 'untappd'
require 'date'
require 'csv'

Untappd.configure do |config|
  config.client_id = '276C318EEC6130BEE8028B70217C253A1AD88DB7'
  config.client_secret = '5D40ED388EDA3BE7CAF6BE4C9AB6CA09392FFF45'
  config.gmt_offset = -5
end

output = open("output.csv", "w")

output.write("\"User\",")

CSV.foreach("data/States.csv") do |row|
    output.write("\"#{row[1]}\",")
end

output.write("\n")

yearStart = Date.parse("31st Dec 2013")
yearEnd = Date.parse("1st Jan 2015")

CSV.foreach("data/Users.csv") do |user|

    output.write("\"#{user[0]}\",")

    puts "Loading user #{user[0]}"

    userFeed = Array.new

    $lastId = 0

    puts "loading data"
    feed = Untappd::User.feed(user[0], {max_id: $lastId, limit: 50})

    while Date.parse(feed.checkins.items.first.created_at) > yearStart do
        feed.checkins.items.each do |f|
            if Date.parse(f.created_at) > yearStart && Date.parse(f.created_at) < yearEnd
                userFeed.push(f)
            end
        end

        $lastId = feed.checkins.items.last.checkin_id

        puts "...loading more data"
        feed = Untappd::User.feed(user[0], {max_id: $lastId, limit: 50})
    end

    CSV.foreach("data/States.csv") do |row|

        s = ""

        userFeed.each do |f|
            if f.brewery.location.brewery_state == row[0]
                s = "#{f.beer.beer_name} - #{f.brewery.brewery_name}"
            end
        end

        output.write("\"#{s}\",")
    end

    output.write("\n")

end

output.close
