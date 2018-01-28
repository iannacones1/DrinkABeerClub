#!/usr/bin/ruby

class RegionMap

    def initialize(inRegionCsv, inOrderCsv)
        @RegionList = Array.new()
        @CountryToRegionHash = Hash.new()
        @StyleToRegionHash = Hash.new()

        @STYLE="STYLE"

        CSV.foreach(ORDER_CONFIG) do |order|

            aType = "#{order[0]}"

            if aType == @STYLE then
                @StyleToRegionHash["#{order[1]}"] = "#{order[2]}"
            end
        end

        CSV.foreach(inRegionCsv) do |row|
            countryName = row[0]
            region = row[1]

            @CountryToRegionHash[countryName] = region

            if !@RegionList.include?(region) then
                @RegionList.push(region)
            end
        end

    #   @RegionList.push("UNKNOWN")

    end

    def getRegionList()
        return @RegionList
    end

    def getRegion(inCheckin, inStyle)

        aRegion = @StyleToRegionHash[inStyle]

        countryName = inCheckin.brewery_country_name
        if @CountryToRegionHash.has_key?(countryName) then
            if @CountryToRegionHash[countryName] == aRegion then
              return "#{aRegion} (inside)"
            end
        end

        return "#{aRegion} (outside)"
    end

end
