#!/usr/bin/ruby

if ARGV.size() != 4 then

    puts "USAGE ./styleBased.rb YEAR INPUT_STYLE_CSV INPUT_USERS_CSV INPUT_REGION_CSV"
    exit 1

end

require 'date'
require 'csv'
require '/home/pi/git/DrinkABeerClub/Classes/Checkin.rb'
require '/home/pi/git/DrinkABeerClub/Classes/HtmlWriter.rb'
require '/home/pi/git/DrinkABeerClub/Classes/RegionMap.rb'
require '/home/pi/git/DrinkABeerClub/Classes/StyleMap.rb'

$startTime = Time.now

YEAR = ARGV[0].to_i
STYLE_CONFIG = "#{ARGV[1]}"
USER_CONFIG = "#{ARGV[2]}"
REGION_CONFIG = "#{ARGV[3]}"

REGIONS = RegionMap.new(REGION_CONFIG)
STYLES = StyleMap.new(STYLE_CONFIG)

USERS = Array.new()
CSV.foreach(USER_CONFIG) { |user| USERS.push("#{user[0]}") }

#build a full list of all bid->ratings
puts "Reading distinct beers for all users (need this for ratings)"
ratings = Hash.new()

USERS.each do |user|
    $user_file = "user_data/#{user}_distinct_beers.csv"
    puts "Reading distinct beers for user: #{user}"
    CSV.foreach($user_file, converters: :numeric) do |row|
        bid = row[0]
        rating = row[12]
        ratings[bid] = rating
    end

end

# Jan 1 2015 +5 to GMT
yearStart = DateTime.new(ARGV[0].to_i,1,1,5,0,0)
# Jan 1 2016 +5 to GMT
yearEnd = DateTime.new(ARGV[0].to_i + 1,1,1,5,0,0)

tableHash = Hash.new() # USER STYLE REGION

# find highest rated for each style
USERS.each do |user|

    puts "Reading checkins for user: #{user}"

    if tableHash[user].nil? then
        tableHash[user] = Hash.new()
    end

    $user_file = "user_data/#{user}_checkins.csv"

    CSV.foreach($user_file, converters: :numeric) do |row|

        checkin = Checkin.new(row)

        if DateTime.parse(checkin.created_at) >= yearStart && DateTime.parse(checkin.created_at) < yearEnd then

            style = STYLES.getStyle(checkin.beer_style)

            if !style.nil? then

                if tableHash[user][style].nil? then
                    tableHash[user][style] = Hash.new()
                end

                checkin.setRating(ratings[checkin.beer_bid])

                region = REGIONS.getRegion(checkin)

                if tableHash[user][style][region].nil? or
                   tableHash[user][style][region].beer_rating_score <= checkin.beer_rating_score then
                 # puts "#{user} #{style} #{region} #{checkin.beer_name}"
                    tableHash[user][style][region] = checkin
                end
            end         
        end
    end
end

output = HtmlWriter.new("table.html")

output.openTag("style")
output.write("    table\n")
output.write("    {\n")
output.write("        border-collapse: collapse;\n")
output.write("        padding: 5px;\n")
output.write("    }\n\n")
output.write("    th,td\n")
output.write("    {\n")
output.write("        text-align: center;\n")
output.write("        border: 1px dotted black;\n")
output.write("        padding: 5px;\n")
output.write("    }\n")
output.closeTag("style")

output.closeTag("head")
output.openTag("body")
output.openTag("table")
output.startLine("caption")

time = Time.now.strftime "%b %d %l:%M %p"
output.write("Last Updated: #{time}")
output.endLine("caption")

output.startRow()
output.writeTableHeader("")

USERS.each do |user|
  output.writeTableHeader(output.getLink("/#{user}/#{user}", user))
end

output.endRow()

output.startRow()
output.writeTableHeader("Total:")
 $user_totals = Hash.new(0) 
 $user_score = Hash.new(0)
 USERS.each do |user|
    puts "Counting totals for user: #{user}"
    REGIONS.getRegionList().each do |region|
        STYLES.getStyleList().each do |style|
            if !tableHash[user].nil? and
               !tableHash[user][style].nil? and
               !tableHash[user][style][region].nil? then
                $user_totals[user] += 1
                $user_score[user] += tableHash[user][style][region].beer_rating_score
            end
        end
    end
  output.writeTableData("#{$user_totals[user]}\\#{STYLES.getStyleList.size() * REGIONS.getRegionList().size()}")
end
output.endRow()

output.startRow()

output.writeTableHeader("Score:")

USERS.each do |user|

    puts "Sum scores for user: #{user}"

    if $user_totals[user] != 0 then
        $avg = $user_score[user] / $user_totals[user]
    else
        $avg = 0
    end

    output.writeTableData("#{$user_score[user].round(3)}<br/>(#{$avg.round(3)})")
end

output.endRow()

REGIONS.getRegionList().each do |region|
    output.indent()
    output.write("<th colspan=\"#{USERS.size() + 1}\">")
#    output.write("#{region}<br/><img src=\"#{region}\">")
    output.write("#{region}")
    output.endLine("th")


   STYLES.getStyleList.each do |style|

    output.startRow()

        puts "Writing row for: #{region} #{style}"
        output.writeTableHeader("#{style}")
 
        USERS.each do |user|
            str = ""
            if !tableHash[user].nil? and
               !tableHash[user][style].nil? and
               !tableHash[user][style][region].nil? then
                str = tableHash[user][style][region].getHtmlImg
            end
            output.writeTableData(str)
        end
    end

    output.endRow()
end

output.closeTag("table")
output.closeTag("body")

output.close

$endTime = Time.now

$duration = $endTime - $startTime

puts "Duration: #{$duration}"
