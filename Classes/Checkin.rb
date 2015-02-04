#!/usr/bin/ruby
require 'csv'
require '/home/pi/git/DrinkABeerClub/Classes/DistinctBeer.rb'

class Checkin
    def initialize(inArray)
        @beer_bid = inArray[0]
        @checkin_id = inArray[1]
        @created_at = inArray[2]
        @rating_score = inArray[3]
        @beer_name = inArray[4]
        @beer_label = inArray[5]
        @beer_abv = inArray[6]
        @beer_style = inArray[7]
        @brewery_id = inArray[8]
        @brewery_name = inArray[9]
        @brewery_label = inArray[10]
        @brewery_country_name = inArray[11]
        @brewery_city = inArray[12]
        @brewery_state = inArray[13]
        @brewery_lat = inArray[14]
        @brewery_lng = inArray[15]
        @user_name = inArray[16]
    end

    def setRating(inRating)
        @beer_rating_score = inRating
    end

    def beer_rating_score
        @beer_rating_score
    end

    def beer_bid
        @beer_bid
    end

    def checkin_id
        @checkin_id
    end

    def created_at
        @created_at
    end

    def rating_score
        @rating_score
    end

    def beer_name
        @beer_name
    end

    def beer_label
        @beer_label
    end

    def beer_abv
        @beer_abv
    end

    def beer_style
        @beer_style
    end

    def brewery_id
        @brewery_id
    end

    def brewery_name
        @brewery_name
    end

    def brewery_label
        @brewery_label
    end

    def brewery_country_name
        @brewery_country_name
    end

    def brewery_city
        @brewery_city
    end

    def brewery_state
        @brewery_state
    end

    def brewery_lat
        @brewery_lat
    end

    def brewery_lng
        @brewery_lng
    end
end
