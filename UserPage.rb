#!/usr/bin/ruby
require 'csv'
require '/home/pi/git/DrinkABeerClub/Classes/DistinctBeer.rb'
require '/home/pi/git/DrinkABeerClub/Classes/HtmlWriter.rb'


if ARGV[0].nil?
    puts "Please input username"
    exit 1
end

$user = ARGV[0]

$user_file = "user_data/#{$user}_distinct_beers.csv"

puts "Building user page for #{$user} from file: #{$user_file}"


Brewery = Struct.new(:name, :lat, :lon, :dis)

userRating = Hash.new(0)
breweryCount = Hash.new(0)
breweryInfo = Hash.new
breweryLoc = Hash.new
distinctBeers = Hash.new

CSV.foreach($user_file, converters: :numeric) do |row|

    if row.empty?
      next;
    end
  
    c = Distinct_beer.new(row)

    d = Date.parse(c.first_had)
    t = d.to_time.localtime

    if distinctBeers[t.year].nil?
            distinctBeers[t.year] = Array.new
    end

    distinctBeers[t.year].push(c)

    if c.brewery_lng != 0 || c.brewery_lat != 0
      if breweryLoc[c.brewery_name].nil?
          breweryLoc[c.brewery_name] = Brewery.new(c.brewery_name, c.brewery_lat, c.brewery_lng, c)
      end
    end

    if c.rating_score == 0 then
        #puts "No user rating for: #{c.brewery_name}'s #{c.beer_name} using rating_score: #{c.beer_rating_score}"
    end
    
    userRating[c.brewery_name] += (c.rating_score == 0 ? c.beer_rating_score : c.rating_score)
    breweryInfo[c.brewery_name] = c
    breweryCount[c.brewery_name] += 1

end

output = HtmlWriter.new("#{$user}.html")

output.write("    <style type=\"text/css\">\n")
output.write("      html, body, #map-canvas { height: 100%; margin: 0; padding: 0;}\n")
output.write("    </style>\n")
output.write("\n")
output.write("    <script type=\"text/javascript\"\n")
output.write("      src=\"https://maps.googleapis.com/maps/api/js?key=AIzaSyDFVtCXPWg-x-Ryzw6z2cR8ewl0o9UUkgE\">\n")
output.write("    </script>\n")
output.write("\n")
output.write("    <script type=\"text/javascript\"\n")
output.write("      src=\"http://DrinkABeerClub.com/MapPoints.js\">\n")
output.write("    </script>\n")
output.write("\n")
output.write("    <script type=\"text/javascript\">\n")
output.write("    var breweries = [\n")

breweryLoc.each do |key, value|

  img = value.dis.brewery_label.gsub("https://d1c8v1qci5en44.cloudfront.net/site/brewery_logos/", "")
  str = "#{value.dis.brewery_city}, #{value.dis.brewery_state} #{value.dis.brewery_country_name}".gsub("'", "")

  output.write("    [ '" + key.gsub("'", "") +"', #{value.lat}, #{value.lon}, '#{img}', '#{str}'],\n")

end

output.write("                    ];\n")
output.write("\n")
output.write("    function init()\n")
output.write("    {\n")
output.write("        makeMap(breweries);\n")
output.write("    }\n")
output.write("\n")
output.write("    google.maps.event.addDomListener(window, 'load', init);\n")
output.write("    </script>\n")
output.write("\n")
output.write("    <font size=\"6\" face=\"Verdana\">#{$user}</font><br>\n")
output.closeTag("head")
output.openTag("body")
output.openTag("pr")
output.indent()
output.write("<font face=\"Verdana\">")
output.write(output.getLink("/BeersOfFame.html", "Beers of Fame"))
output.write("</font>\n")

output.closeTag("pr")
output.indent()
output.write("<br><br>\n")

output.openTag("pr")
output.indent()
output.write("<font face=\"Verdana\">\n")
output.indent()
output.write("    Distinct Checkins by Year<br>\n")

t = Time.now

distinctBeers.each do |year, checkinArray|

    output.indent()
    output.write("    #{year}: #{checkinArray.size} ")
       
    if "#{year}" == "#{t.year}"
      output.write("(#{t.yday}) [#{t.yday - checkinArray.size}]  -- Rate: #{(Float(checkinArray.size) / Float(t.yday)).round(3)}  Projected: #{(Float(checkinArray.size) / Float(t.yday) * Float(Date.new(t.year,12,31).yday)).to_i}")
    end

    output.write("<br>\n")

end
output.indent()
output.write("</font>\n")
output.closeTag("pr")
output.indent()
output.write("<br><br>\n")

output.openTag("pr")
output.indent()
output.write("<font face=\"Verdana\">\n")
output.indent()
output.write("    " + output.getLink("/#{$user}/FavoriteBreweries.txt", "Favorite Breweries") + "\n")
output.indent()
output.write("</font>\n")
output.indent()
output.write("<br>\n")

$i = 0
$lastRating = 0

    #puts "brewery, breweryCount, rating"

userRating.sort_by { |brewery, rating| rating }.reverse.each do |brewery, rating|

    if $i >= 20 && $lastRating > rating
        break
    end

    #puts "#{brewery}, #{breweryCount[brewery]}, #{rating}"

    output.addImg("#{breweryInfo[brewery].brewery_label}", "#{brewery} - #{breweryCount[brewery]} / #{rating}")

    $i += 1
    $lastRating = rating
    if $i % 5 == 0
        output.indent()
        output.write("<br>\n")
    end
end

output.closeTag("pr")
output.indent()
output.write("<br>\n")
output.write("<div id=\"map-canvas\" style=\"width: 900px; height: 600px;\"></div>\n")
output.write("<br>\n")
output.indent()

t = Time.now.strftime "%b %d%l:%M %p"
output.write("Last Updated: #{t}\n")

output.closeTag("body")
output.close
