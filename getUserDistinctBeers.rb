#!/usr/bin/ruby

require 'net/http'
require 'json'

require '/home/pi/git/DrinkABeerClub/tokens/untappdConfigure.rb'

def makeRequest(method_name, *args)

  url_string = "https://api.untappd.com/v4/#{method_name}?"

  for i in 0...args.length
    if i > 0
      url_string += "&"
    end
    url_string += "#{args[i]}"
  end

  uri = URI(url_string)

  json_string = Net::HTTP.get(uri)

  return JSON.parse(json_string)
end

def getUserDistinctBeers(username, offset = 0)
  return makeRequest("user/beers/#{username}", "client_id=#{getClientId}", "client_secret=#{getClientSecret}", "limit=50", "offset=#{offset}")
end

#result = getUserDistinctBeers("iannacones1", 50)
#puts "#{result.inspect}"

