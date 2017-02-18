#!/usr/bin/ruby

class StyleMap

    def initialize(inStyleCsv)
       @StyleList = Array.new()
       @StyleHash = Hash.new()

        CSV.foreach(inStyleCsv) do |row|
            untappdStyle = row[0].gsub(/\s+/,"")
            genericStyle = row[1]
            @StyleHash[untappdStyle] = genericStyle

            if !@StyleList.include?(genericStyle) then
                @StyleList.push(genericStyle)
            end
        end
    end

    def getStyleList()
        return @StyleList
    end

    def getStyle(inUntappdStyle)
        return @StyleHash[inUntappdStyle.gsub(/\s+/,"")]           
    end

end
