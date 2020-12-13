#!/usr/bin/ruby

require 'date'
require 'csv'
require 'set'
require_relative 'Classes/Checkin.rb'
require_relative 'Classes/html.rb'

HEADER="HEADER"
STYLE="STYLE"
LIMIT = 100          

if ARGV.size() != 4 then
    puts "USAGE ./2021_DaBC.rb YEAR COUNTY_LIST CITY_TO_COUNTY INPUT_USERS_CSV"
    exit 1
end

$startTime = Time.now

YEAR = ARGV[0].to_i
COUNTY_CONFIG = "#{ARGV[1]}"
CITY_CONFIG = "#{ARGV[2]}"
USER_CONFIG = "#{ARGV[3]}"

CITY_LOOKUP = Hash.new()
COUNTY_HASH = Hash.new()

CSV.foreach(COUNTY_CONFIG) do |aRow|

    if aRow.empty? then
        next
    end

    state = aRow[0].strip
    county = aRow[1].strip
    #population = aRow[2]
    seal = aRow[3]
    #map = aRow[4]

    county_full = "#{county}, #{state}"

    COUNTY_HASH[county_full] = seal        

end

CSV.foreach(CITY_CONFIG) do |aRow|

    if aRow.empty? then
        next
    end

    state = aRow[0].strip
    county = aRow[1].strip
    city = aRow[2].strip

    county_full = "#{county}, #{state}"
    city_full = "#{city}, #{state}"

    CITY_LOOKUP[city_full] = county_full        
 
end

USERS = Array.new()
CSV.foreach(USER_CONFIG) { |user| USERS.push("#{user[0]}") }

# Jan 1 20XX +5 to GMT
yearStart = DateTime.new(YEAR.to_i,1,1,5,0,0)
# Jan 1 20XX+1 +5 to GMT
yearEnd = DateTime.new(YEAR.to_i + 1,1,1,5,0,0)

user_county_hash = Hash.new()

USERS.each do |user|
    if user_county_hash[user].nil? then
        user_county_hash[user] = Hash.new()
    end
    $user_file = "user_data/#{user}_checkins.csv"
    puts "Reading checkins for user: #{user}"
    CSV.foreach($user_file) do |row|

        if row.empty?
            next
        end
      
        checkin = Checkin.new(row)

        if checkin.brewery_city.nil? || checkin.brewery_state.nil? then
            next
        end

        city_full = "#{checkin.brewery_city.strip}, #{checkin.brewery_state.strip}"

        if DateTime.parse(checkin.created_at) >= yearStart &&
           DateTime.parse(checkin.created_at) < yearEnd && 
           CITY_LOOKUP.has_key?(city_full) then

            county_full = CITY_LOOKUP[city_full]

            if user_county_hash[user][county_full].nil? then
                user_county_hash[user][county_full] = checkin
            elsif user_county_hash[user][county_full].rating_score >= checkin.rating_score
                user_county_hash[user][county_full] = checkin
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
    style.addContent("img { max-width: 100px; }")

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

end

scoreRow = HtmlElement.new("tr", table)

HtmlElement.new("th", scoreRow, "Score:")

USERS.each do |user|
    aScore = HtmlElement.new("th", scoreRow, "#{user_county_hash[user].count}")
end

COUNTY_HASH.each do |county_full, seal|

    aRow = HtmlElement.new("tr", table)
    aHeader = HtmlElement.new("th", aRow)
    aHeader.addAttribute("width", 250)

    if !seal.nil? then 
        aImg = HtmlElement.new("img", aHeader)
        aImg.addAttribute("src", seal)
        aHeader.addContent("<br>")
    end

    aHeader.addContent("#{county_full}")

    USERS.each do |user|
        str = ""
        if user_county_hash[user].has_key?(county_full) && !user_county_hash[user][county_full].nil?
            str = user_county_hash[user][county_full].getHtmlImg
        end
        aData = HtmlElement.new("td", aRow, "#{str}")
        aData.addAttribute("width", 100)

    end
end

aFile = open("table.html", "w")
aFile.write("#{html}")
aFile.close

$endTime = Time.now

$duration = $endTime - $startTime

puts "Duration: #{$duration}"
