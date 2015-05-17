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

userCor = open("#{$user}.cor", "w")

userRating = Hash.new(0)
breweryCount = Hash.new(0)
breweryInfo = Hash.new
distinctBeers = Hash.new

CSV.foreach($user_file, converters: :numeric) do |row|

    c = Distinct_beer.new(row)

    d = Date.parse(c.first_had)
    t = d.to_time.localtime

    if distinctBeers[t.year].nil?
            distinctBeers[t.year] = Array.new
    end

    distinctBeers[t.year].push(c)

    if c.brewery_lng != 0 || c.brewery_lat != 0
        userCor.write("#{c.brewery_lng} #{c.brewery_lat}\n\n")
    else
        #puts "#{c.brewery_name} has no location!!!"
    end

    if c.rating_score == 0 then
        #puts "No user rating for: #{c.brewery_name}'s #{c.beer_name} using rating_score: #{c.beer_rating_score}"
    end
    
    userRating[c.brewery_name] += (c.rating_score == 0 ? c.beer_rating_score : c.rating_score)
    breweryInfo[c.brewery_name] = c
    breweryCount[c.brewery_name] += 1

end

output = HtmlWriter.new("#{$user}.html")

output.openTag("body")
output.openTag("pr")
output.indent()
output.write("<font face=\"Verdana\">")
output.write(output.getLink("/#{$user}/#{$user}_BoF", "Beers of Fame"))
output.write("</font>\n")

output.closeTag("pr")
output.indent()
output.write("<br><br>\n")

output.openTag("pr")
output.indent()
output.write("<font face=\"Verdana\">\n")
output.indent()
output.write("    Distinct Checkins by Year<br>\n")

t = Time.new

distinctBeers.each do |year, checkinArray|

    output.indent()
    output.write("    #{year}: #{checkinArray.size} ")
       
    if "#{year}" == "#{t.year}"
        output.write("(#{t.yday}) [#{t.yday - checkinArray.size}]")
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
output.addImg("#{$user}_usa.png", "")
output.indent()
output.write("<br>\n")
output.addImg("#{$user}.png", "")
output.indent()
output.write("<br>\n")
output.indent()
output.write("Last Updated: #{Time.now.asctime}\n")

output.closeTag("body")
output.close

userCor.close
