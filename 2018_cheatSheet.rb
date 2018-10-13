#!/usr/bin/ruby
require 'date'
require 'csv'
require '/home/pi/git/DrinkABeerClub/Classes/Checkin.rb'
require '/home/pi/git/DrinkABeerClub/Classes/html.rb'
require '/home/pi/git/DrinkABeerClub/Classes/2018_RegionMap.rb'
require '/home/pi/git/DrinkABeerClub/Classes/StyleMap.rb'

$startTime = Time.now

YEAR = 2018
STYLE_CONFIG = "data/2018_styles.csv"
REGION_CONFIG = "data/2018_Regions.csv"
ORDER_CONFIG = "data/2018_order.csv"

HEADER="HEADER"
STYLE="STYLE"

REGIONS = RegionMap.new(REGION_CONFIG, ORDER_CONFIG)

STYLES = StyleMap.new(STYLE_CONFIG)

RUN_USER_CONFIG = "data/2018_Users.csv"
DATA_USER_CONFIG = "data/2018_DataUsers.csv"

RUN_USERS = Array.new()
RUN_USERS.push("everyone")
CSV.foreach(RUN_USER_CONFIG) { |user| RUN_USERS.push("#{user[0]}") }

DATA_USERS = Array.new()
CSV.foreach(DATA_USER_CONFIG) { |user| DATA_USERS.push("#{user[0]}") }

#build a full list of all bid->ratings
puts "Reading distinct beers for all users (need this for ratings)"
ratings = Hash.new()

bids = Hash.new()

DISTINCT = Hash.new()

DATA_USERS.each do |user|
  $user_file = "user_data/#{user}_distinct_beers.csv"

  if !File.file?("#{$user_file}") then
    puts "Missing file: #{$user_file}..."
    next
  end

  puts "Reading distinct beers for user: #{user}"
  CSV.foreach($user_file, converters: :numeric) do |row|

    bid = row[0]
    rating = row[12]
    ratings[bid] = rating

    c = Distinct_beer.new(row)
    s = STYLES.getStyle(c.beer_style)

    if !s.nil? then
      if DISTINCT[user].nil? then
        DISTINCT[user] = Array.new()
      end
      
      DISTINCT[user].push(c.beer_bid)
      
      if bids[s].nil? then
        bids[s] = Hash.new()
      end

      r = REGIONS.getRegion(c, s)

      if bids[s][r].nil? then
        bids[s][r] = Hash.new()
      end

      bids[s][r][c.beer_bid] = c

    end
  end
end

# Jan 1 2015 +5 to GMT
yearStart = DateTime.new(YEAR.to_i,1,1,5,0,0)
# Jan 1 2016 +5 to GMT
yearEnd = DateTime.new(YEAR.to_i + 1,1,1,5,0,0)

tableHash = Hash.new() # USER STYLE REGION

COUNTRYS = Array.new()

# find highest rated for each style
DATA_USERS.each do |user|

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

output = open("cheatSheet_unlimited.html", "w")

output.write("<html>\n<head>\n<meta charset=\"UTF-8\">\n<style>\n")
output.write("table,th,td\n")
output.write("{border:1px solid black;\nborder-collapse:collapse;}\n")
output.write("th,td\n{padding:5px;}")
output.write("
           /* Style the tab */
           .tab {
               overflow: hidden;
               border: 1px solid #ccc;
               background-color: #f1f1f1; }
           /* Style the buttons inside the tab */ 
           .tab button {
               background-color: inherit;
               float: left;
               border: none;
               outline: none;
               cursor: pointer;
               padding: 14px 16px;
               transition: 0.3s;
               font-size: 17px; }
           /* Change background color of buttons on hover */
           .tab button:hover {
               background-color: #ddd; }
           /* Create an active/current tablink class */
           .tab button.active {
               background-color: #ccc; }
           /* Style the tab content */
           .tabcontent {
              display: none;
              padding: 6px 12px;
              border: 1px solid #ccc;
              border-top: none; }")
output.write("\n</style>\n</head><body>\n")

output.write("<div class=\"tab\">\n")

#output.write("<button class=\"tablinks\" onclick=\"openUser(event,everyone)\">everyone</button>\n")

RUN_USERS.each do |user|
  output.write("<button class=\"tablinks\" onclick=\"openUser(event, '#{user}')\" id=\"#{user}_button\" >#{user}</button>\n")
end

output.write("</div>\n\n")

RUN_USERS.each do |user|

  output.write("<div id=\"#{user}\" class=\"tabcontent\">\n")
#  output.write("<h3>#{user}</h3>\n")
  output.write("<table>\n")

  CSV.foreach(ORDER_CONFIG) do |order|
    aType = "#{order[0]}"

    if aType == HEADER then
      region = "#{order[1]}"
      output.write("<th colspan=\"11\">#{region}<br>")

      i = 2
      while i < order.size()
        output.write("<img src=\"#{order[i]}\"> ")
        i += 1
      end

      output.write("</th>")
    else
      style = "#{order[1]}"
      baseRegion = "#{order[2]}"

      regionArray = ["#{baseRegion} (inside)", "#{baseRegion} (outside)"]
    
      regionArray.each do |region|

        currScore = 0.0
        scoreTxt = ""
        bgColor = "#FF0000"
        if tableHash[user].nil? then
          bgColor   = "#FFFFFF"
        elsif !tableHash[user][style].nil? && !tableHash[user][style][region].nil? then
          currScore = tableHash[user][style][region].beer_rating_score
          scoreTxt  = " (#{tableHash[user][style][region].beer_rating_score})"
          bgColor   = "#FFFFFF"
        end
        output.write("<tr><th bgcolor=\"#{bgColor}\" >#{style} from #{region}#{scoreTxt}</th>\n")

        $i = 0

        if !bids[style][region].nil? then
        
          bids[style][region].values.sort.reverse.each do |beer|

            if currScore >= beer.beer_rating_score then
              break
            end
          
            if $i >= 10
              break
            end

            puts "--- #{beer.beer_name} - #{beer.brewery_name} :#{beer.beer_rating_score.round(3)}"

            img = "#{beer.beer_label}"
            if img == DEFAULT_PNG then
              img = "#{beer.brewery_label}"
            end

            search = "https://www.beermenus.com/search?q=#{beer.beer_name}"
            search = search.gsub(" ", "+")

            str = "<a href=\"#{search}\" target=\"main\"><img src=\"#{img}\"><br></a>"

            title = "#{beer.beer_name}<br>#{beer.brewery_name}<br>(#{beer.beer_rating_score.round(3)})"

            color="#FFFFFF"
          
            if !DISTINCT[user].nil? && DISTINCT[user].count(beer.beer_bid) > 0 then
              color = "#cccccc"
            end
          
            output.write("  <td bgcolor=\"#{color}\" align=\"center\" >#{str}#{title}</td>\n")

            $i += 1

          end

        end 
        output.write("  </tr>\n")
      end
    end
  end
  output.write("</table>\n")
  output.write("</div>\n\n")

end

output.write("<script>
function openUser(evt, userName) {
    var i, tabcontent, tablinks;
    tabcontent = document.getElementsByClassName(\"tabcontent\");
    for (i = 0; i < tabcontent.length; i++) {
        tabcontent[i].style.display = \"none\";
    }
    tablinks = document.getElementsByClassName(\"tablinks\");
    for (i = 0; i < tablinks.length; i++) {
        tablinks[i].className = tablinks[i].className.replace(\" active\", \"\");
    }
    document.getElementById(userName).style.display = \"block\";
    evt.currentTarget.className += \" active\";}

    document.getElementById(\"everyone_button\").click();
</script>")


output.write("</body>\n</html>")
output.close
  
$endTime = Time.now

$duration = $endTime - $startTime

puts "Duration: #{$duration}"
