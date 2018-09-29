#!/usr/bin/ruby

if ARGV.size() != 4 then

    puts "USAGE ./styleBased.rb YEAR INPUT_STYLE_CSV INPUT_USERS_CSV INPUT_REGION_CSV"
    exit 1

end

require 'date'
require 'csv'
require '/home/pi/git/DrinkABeerClub/Classes/Checkin.rb'
require '/home/pi/git/DrinkABeerClub/Classes/html.rb'
require '/home/pi/git/DrinkABeerClub/Classes/2018_RegionMap.rb'
require '/home/pi/git/DrinkABeerClub/Classes/StyleMap.rb'

$startTime = Time.now

YEAR = ARGV[0].to_i
STYLE_CONFIG = "#{ARGV[1]}"
USER_CONFIG = "#{ARGV[2]}"
REGION_CONFIG = "#{ARGV[3]}"
ORDER_CONFIG = "data/2018_order.csv"

HEADER="HEADER"
STYLE="STYLE"

REGIONS = RegionMap.new(REGION_CONFIG, ORDER_CONFIG)
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

COUNTRYS = Array.new()

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

                region = REGIONS.getRegion(checkin, style)

                if tableHash[user][style][region].nil? ||
                   tableHash[user][style][region].beer_rating_score <= checkin.beer_rating_score then
                    #puts "#{user} #{style} #{region} #{checkin.beer_name}"
                    tableHash[user][style][region] = checkin
                end
            end         
        end
    end
end

html = HtmlElement.new("html")
  head = HtmlElement.new("head", html)
    noRobots = HtmlElement.new("meta", head)
    noRobots.addAttribute("name", "robots")
    noRobots.addAttribute("content", "noindex, nofollow")

    charset = HtmlElement.new("meta", head)
    charset.addAttribute("charset", "UTF-8")

    style = HtmlElement.new("style", head)
    style.addContent("table { border-collapse: collapse; padding: 5px; } ")
    style.addContent("th,td { text-align: center; border: 1px dotted black; padding: 5px; }")

  body = HtmlElement.new("body", html)
  
    table = HtmlElement.new("table", body)
    
    caption = HtmlElement.new("caption", table)
    time = Time.now.strftime "%b %d %l:%M %p"
    caption.addContent("Last Updated: #{time}")
    
    headerRow = HtmlElement.new("tr", table, HtmlElement.new("th"))
    
USERS.each do |user|
  aUserLink = HtmlElement.new("a")
  aUserLink.addContent("#{user}")
  aUserLink.addAttribute("href", "/#{user}/#{user}.html")
  
  aHeader = HtmlElement.new("th", headerRow, aUserLink.to_s)
  aHeader.addAttribute("colspan", 2)
end

totalRow = HtmlElement.new("tr", table)

HtmlElement.new("th", totalRow, "Total:")

$user_totals = Hash.new(0) 
$user_score = Hash.new(0)
USERS.each do |user|
    puts "Counting totals for user: #{user}"
    CSV.foreach(ORDER_CONFIG) do |order|
        aType = "#{order[0]}"

        if aType == STYLE then
            style = "#{order[1]}"
            region = "#{order[2]}"

            if !tableHash[user].nil? and
               !tableHash[user][style].nil? and
               !tableHash[user][style]["#{region} (inside)"].nil? then

                $user_totals[user] += 1
                $user_score[user] += tableHash[user][style]["#{region} (inside)"].beer_rating_score

             end

             if !tableHash[user].nil? and
                !tableHash[user][style].nil? and
                !tableHash[user][style]["#{region} (outside)"].nil? then
                    
                $user_totals[user] += 1
                $user_score[user] += tableHash[user][style]["#{region} (outside)"].beer_rating_score

             end
        end
    end

    aTotal = HtmlElement.new("th", totalRow, "#{$user_totals[user]}\\#{STYLES.getStyleList.size() * 2}")
    aTotal.addAttribute("colspan", 2)
   
end
   
scoreRow = HtmlElement.new("tr", table)

HtmlElement.new("th", scoreRow, "Score:")

USERS.each do |user|

    puts "Sum scores for user: #{user}"

    if $user_totals[user] != 0 then
        $avg = $user_score[user] / $user_totals[user]
    else
        $avg = 0
    end

    aScore = HtmlElement.new("th", scoreRow, "#{$user_score[user].round(3)}<br/>(#{$avg.round(3)})")
    aScore.addAttribute("colspan", 2)
end

CSV.foreach(ORDER_CONFIG) do |order|

    aType = "#{order[0]}"

    aRow = HtmlElement.new("tr", table)
    
    if aType == HEADER then
        region = "#{order[1]}"

        img="#{region}<br>"
      
        i = 2
        while i < order.size()
            img+="<img src=\"#{order[i]}\">"
            i += 1
        end
        
        aStyle = HtmlElement.new("th", aRow, img)
        aStyle.addAttribute("colspan", USERS.size() * 2 + 1)
    
    else
        style = "#{order[1]}"
        region = "#{order[2]}"

        aHeader = HtmlElement.new("th", aRow, "#{style}")
        aHeader.addAttribute("height", 100)
        aHeader.addAttribute("width", 100)

        USERS.each do |user|
            str = ""
            if !tableHash[user].nil? and
               !tableHash[user][style].nil? and
               !tableHash[user][style]["#{region} (inside)"].nil? then
                 str = tableHash[user][style]["#{region} (inside)"].getHtmlImg
            end

            aData = HtmlElement.new("td", aRow, "#{str}")
            aData.addAttribute("width", 100)
        
            str = ""
            if !tableHash[user].nil? and
               !tableHash[user][style].nil? and
               !tableHash[user][style]["#{region} (outside)"].nil? then
                 str = tableHash[user][style]["#{region} (outside)"].getHtmlImg
            end

            bData = HtmlElement.new("td", aRow, "#{str}")
            bData.addAttribute("width", 100)

        end
    end
end

#puts "#{html}"
aFile = open("table.html", "w")
aFile.write("#{html}")
aFile.close

$endTime = Time.now

$duration = $endTime - $startTime

puts "Duration: #{$duration}"
