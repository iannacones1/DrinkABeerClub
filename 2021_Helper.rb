#!/usr/bin/ruby

require 'date'
require 'csv'
require 'set'
require_relative 'Classes/Checkin.rb'
require_relative 'Classes/html.rb'

HEADER="HEADER"
STYLE="STYLE"
LIMIT = 100          

if ARGV.size() != 3 then
    puts "USAGE ./2021_Helper.rb COUNTY_LIST CITY_TO_COUNTY INPUT_USERS_CSV"
    exit 1
end

$startTime = Time.now

COUNTY_CONFIG = "#{ARGV[0]}"
CITY_CONFIG = "#{ARGV[1]}"
USER_CONFIG = "#{ARGV[2]}"

CITY_LOOKUP = Hash.new()
COUNTY_HASH = Hash.new()

county_brewery_hash = Hash.new()

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

    county_brewery_hash[county_full] = Set.new()

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

USERS.each do |user|
    $user_file = "user_data/#{user}_distinct_beers.csv"
    puts "Reading distinct beers for user: #{user}"
    CSV.foreach($user_file) do |row|

        if row.empty?
            next
        end
      
        distinctBeer = Distinct_beer.new(row)

        if distinctBeer.brewery_city.nil? || distinctBeer.brewery_state.nil? then
            next
        end 

        city_full = "#{distinctBeer.brewery_city.strip}, #{distinctBeer.brewery_state.strip}"

        if CITY_LOOKUP.has_key?(city_full) then

            county_full = CITY_LOOKUP[city_full]

            county_brewery_hash[county_full].add(distinctBeer.brewery_name)
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
    
    headerRow = HtmlElement.new("tr", table)
    HtmlElement.new("th", headerRow, "Counties")
    HtmlElement.new("th", headerRow, "Breweries")

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

    aData = HtmlElement.new("td", aRow)
    aData.addAttribute("width", 500)

    county_brewery_hash[county_full].each do |brewery|
        aData.addContent("#{brewery}<br>")
    end

end

aFile = open("2021_helper.html", "w")
aFile.write("#{html}")
aFile.close

$endTime = Time.now

$duration = $endTime - $startTime

puts "Duration: #{$duration}"
