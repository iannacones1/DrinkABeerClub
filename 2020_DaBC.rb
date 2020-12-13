#!/usr/bin/ruby

require 'date'
require 'csv'
require '/home/pi/git/DrinkABeerClub/Classes/Checkin.rb'
require '/home/pi/git/DrinkABeerClub/Classes/html.rb'

HEADER="HEADER"
STYLE="STYLE"
LIMIT = 100          

if ARGV.size() != 3 then
    puts "USAGE ./2019_DaBC.rb YEAR INPUT_BID_CSV INPUT_USERS_CSV"
    exit 1
end

$startTime = Time.now

YEAR = ARGV[0].to_i
BID_CONFIG = "#{ARGV[1]}"
USER_CONFIG = "#{ARGV[2]}"

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

user_bid_hash = Hash.new() # USER BID

puts "Reading distinct beers for all users"

USERS.each do |user|
    if user_bid_hash[user].nil? then
        user_bid_hash[user] = Hash.new()
    end

    $user_file = "user_data/#{user}_distinct_beers.csv"
    puts "Reading distinct beers for user: #{user}"
    CSV.foreach($user_file, converters: :numeric) do |row|

        if row.empty? then
            next
        end
    
        distinctBeer = Distinct_beer.new(row)
        bid = distinctBeer.beer_bid

        if VINTAGE.has_key?(bid)
            bid = VINTAGE[bid]
        end
        
        if DateTime.parse(distinctBeer.recent_created_at) >= yearStart &&
           DateTime.parse(distinctBeer.recent_created_at) <  yearEnd then
            user_bid_hash[user][bid] = distinctBeer
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

end

totalRow = HtmlElement.new("tr", table)

HtmlElement.new("th", totalRow, "Count:")

$user_totals = Hash.new(0) 
$user_score = Hash.new(0)
$user_last = Hash.new(0)
USERS.each do |user|
    puts "Counting totals for user: #{user}"
    CSV.foreach(BID_CONFIG, converters: :numeric) do |row|
        bid = row[1]

        if user_bid_hash[user].has_key?(bid) && !user_bid_hash[user][bid].nil?
          $user_totals[user] += 1

          if $user_totals[user] <= LIMIT
              $user_score[user] += 251 - row[0]
          end
          if $user_totals[user] == LIMIT
              $user_last[user] = row[0]
          end
        end
    end
    aTotal = HtmlElement.new("th", totalRow, "#{$user_totals[user]}")        
end

scoreRow = HtmlElement.new("tr", table)

HtmlElement.new("th", scoreRow, "Score (Top #{LIMIT}):")

USERS.each do |user|
    aScore = HtmlElement.new("th", scoreRow, "#{$user_score[user]}")
end

avgRow = HtmlElement.new("tr", table)

HtmlElement.new("th", avgRow, "Average Rank (Top #{LIMIT}):")

USERS.each do |user|
  avg = 251
  if $user_totals[user] > 0 then
    div = $user_totals[user]
    if div > LIMIT
      div = LIMIT
    end
    avg = $user_score[user] / div
  end
  aAvg = HtmlElement.new("th", avgRow, "(#{251 - avg})")
end

lastRow = HtmlElement.new("tr", table)

HtmlElement.new("th", lastRow, "Number #{LIMIT} Rank:")

USERS.each do |user|
  usrLastTxt = ""

  if $user_last.has_key?(user) then
    usrLastTxt = $user_last[user]
  end

  aLast = HtmlElement.new("th", lastRow, "#{usrLastTxt}")

  if $user_last.has_key?(user)
      #aLast.addAttribute("bgcolor", "#00FF00")
  end

end

index = 1
CSV.foreach(BID_CONFIG, converters: :numeric) do |row|
    bid = row[1]
  
    aRow = HtmlElement.new("tr", table)
    aHeader = HtmlElement.new("th", aRow, "#{row[0]}<br/><img src=\"#{row[5]}\"><br/>#{row[2]}<br/>#{row[3]}")

    USERS.each do |user|
        str = ""
        if user_bid_hash[user].has_key?(bid) && !user_bid_hash[user][bid].nil?
            str = user_bid_hash[user][bid].getHtmlImg
        end
        aData = HtmlElement.new("td", aRow, "#{str}")
        aData.addAttribute("width", 100)

        if $user_last.has_key?(user) && index == $user_last[user]
            #aData.addAttribute("bgcolor", "#00FF00")
        end
    end
    index += 1
end

aFile = open("table.html", "w")
aFile.write("#{html}")
aFile.close

$endTime = Time.now

$duration = $endTime - $startTime

puts "Duration: #{$duration}"
