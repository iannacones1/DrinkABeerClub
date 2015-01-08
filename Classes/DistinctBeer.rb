#!/usr/bin/ruby
class Distinct_beer
    def initialize(inArray)
        @beer_bid = inArray[0]
        @first_checkin_id = inArray[1]
        @first_created_at = inArray[2]
        @recent_checkin_id = inArray[3]
        @recent_created_at = inArray[4]
        @rating_score = inArray[5]
        @first_had = inArray[6]
        @count = inArray[7]
        @beer_name = inArray[8]
        @beer_label = inArray[9]
        @beer_abv = inArray[10]
        @beer_style = inArray[11]
        @beer_rating_score = inArray[12]
        @beer_rating_count = inArray[13]
        @brewery_id = inArray[14]
        @brewery_name = inArray[15]
        @brewery_label = inArray[16]
        @brewery_country_name = inArray[17]
        @brewery_city = inArray[18]
        @brewery_state = inArray[19]
        @brewery_lat = inArray[20]
        @brewery_lng = inArray[21]
    end

    def beer_bid
        @beer_bid
    end
    def first_checkin_id
        @first_checkin_id
    end
    def first_created_at
        @first_created_at
    end
    def recent_checkin_id
        @recent_checkin_id
    end
    def recent_created_at
        @recent_created_at
    end
    def rating_score
        @rating_score
    end
    def first_had
        @first_had
    end
    def count
        @count
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
    def beer_rating_score
        @beer_rating_score
    end
    def beer_rating_count
        @beer_rating_count
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
