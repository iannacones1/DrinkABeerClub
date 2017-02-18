#!/usr/bin/ruby

if ARGV.size() != 3 then

    puts "USAGE ./styleBased.rb YEAR INPUT_STYLE_CSV INPUT_USERS_CSV"
    exit 1

end

require 'date'
require 'csv'
require '/home/pi/git/DrinkABeerClub/Classes/Checkin.rb'
require '/home/pi/git/DrinkABeerClub/Classes/HtmlWriter.rb'

$startTime = Time.now

USER_CONFIG = "#{ARGV[2]}"
USERS = Array.new
CSV.foreach(USER_CONFIG) { |user| USERS.push("#{user[0]}") }

STYLE_CONFIG = "#{ARGV[1]}"
STYLES = Array.new
CSV.foreach(STYLE_CONFIG) do |row|
    if row.size() != 2 then
        STYLES.push(row[0].gsub(/\s+/,""))
    end
end

x = Hash.new()

# Jan 1 2015 +5 to GMT
yearStart = DateTime.new(ARGV[0].to_i,1,1,5,0,0)
# Jan 1 2016 +5 to GMT
yearEnd = DateTime.new(ARGV[0].to_i + 1,1,1,5,0,0)

#build a full list of all bid->ratings
ratings = Hash.new()

USERS.each do |user|

    puts "Reading distinct beers for user: #{user}"

    $user_file = "user_data/#{user}_distinct_beers.csv"

    CSV.foreach($user_file, converters: :numeric) do |row|
        ratings[row[0]] = row[12]
    end

end

# find highest rated for each style
USERS.each do |user|

    puts "Reading checkins for user: #{user}"

    if x[user].nil? then
        x[user] = Hash.new()
    end

    $user_file = "user_data/#{user}_checkins.csv"

    CSV.foreach($user_file, converters: :numeric) do |row|

        c = Checkin.new(row)

        if DateTime.parse(c.created_at) >= yearStart && DateTime.parse(c.created_at) < yearEnd then

            style = c.beer_style.gsub(/\s+/,"")

            if !STYLES.index(style).nil? then

                c.setRating(ratings[c.beer_bid])

                if x[user][style].nil? or x[user][style].beer_rating_score <= c.beer_rating_score then
                    x[user][style] = c
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

    STYLES.each do |style|

        if !x[user][style].nil? then
            $user_totals[user] += 1
            $user_score[user] += x[user][style].beer_rating_score
        end

    end

  output.writeTableData("#{$user_totals[user]}\\#{STYLES.size()}")
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

CSV.foreach(STYLE_CONFIG) do |set|

    output.startRow()

    if set.size() == 2 then
        output.indent()
        output.write("<th colspan=\"#{USERS.size() + 1}\">")
        output.write("#{set[0]}<br/><img src=\"#{set[1]}\">")
        output.endLine("th")
    else
        puts "Writing row for: #{set[0]}"
        output.writeTableHeader(output.getLink("https://untappd.com/beer/top_rated?type_id=#{set[1]}", set[2]))
 
        style = set[0].gsub(/\s+/,"")

        USERS.each do |user|
            str = ""
            if !x[user][style].nil? then
                str = x[user][style].getHtmlImg
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
