#!/usr/bin/ruby

class RegionMap

    def initialize(inRegionCsv)
       @RegionList = Array.new()
       @StateToRegionHash = Hash.new()

        CSV.foreach(inRegionCsv) do |row|
            stateAbr = row[0].upcase
            region = row[2]
            @StateToRegionHash[stateAbr] = region

            if !@RegionList.include?(region) then
                @RegionList.push(region)
            end
        end
    end

    def getRegionList()
        return @RegionList
    end

    def getRegion(inCheckin)

        stateAbr = inCheckin.brewery_state.upcase
        if @StateToRegionHash.has_key?(stateAbr) then
            return @StateToRegionHash[stateAbr]           
        end

        if inCheckin.brewery_country_name == "United States" then
            puts "UNKNOWN region for US beer: #{inCheckin.beer_name} #{inCheckin.brewery_name}"
            return "ERROR"
        end

        return "OCONUS"
    end

end
