#!/usr/bin/ruby

require 'net/http'
require 'json'

require_relative 'tokens/untappdConfigure.rb'

def makeRequest(method_name, *args)

  url_string = "https://api.untappd.com/v4/#{method_name}?"

  for i in 0...args.length
    if i > 0
      url_string += "&"
    end
    url_string += "#{args[i]}"
  end

  uri = URI(url_string)

  #puts "#{url_string}"

  json_string = Net::HTTP.get(uri)

  return JSON.parse(json_string)
end

def getUserDistinctBeers(username, offset = 0)
  feed = makeRequest("user/beers/#{username}", "client_id=#{getClientId}", "client_secret=#{getClientSecret}", "limit=50", "offset=#{offset}")
  puts "#{feed['meta']}"
  return feed
end

def getUserActivityFeed(username, offset = 0)
  feed = makeRequest("user/checkins/#{username}", "client_id=#{getClientId}", "client_secret=#{getClientSecret}", "limit=50", "max_id=#{offset}")
  puts "#{feed['meta']}"
  return feed

end

def getBeerInfo(bid)
  feed = makeRequest("beer/info/#{bid}", "client_id=#{getClientId}", "client_secret=#{getClientSecret}")
  #puts "#{feed['meta']}"
  return feed
end

def feedHasResponse(feed)
  begin
    val = !feed.nil? &&
          !feed["meta"].nil? &&
           feed["meta"]["code"].to_i == 200 &&
          !feed["response"].nil?

    return val
  rescue
    puts "ERROR: #{feed.inspect}"
    return false
  end

end

def feedContainsUserDistinctData(feed)
  begin
    val = feedHasResponse(feed) &&
          !feed["response"].first.nil?
          !feed["response"]["beers"].nil? &&
          !feed["response"]["beers"]["count"].nil? &&
           feed["response"]["beers"]["count"].to_i > 0 &&
          !feed["response"]["beers"]["items"].nil? &&
           feed["response"]["beers"]["items"].count > 0

    return val
  rescue
    puts "ERROR: #{feed.inspect}"
    return false
  end

end

def feedContainsActivity(feed, yearStart)
  begin
    val = feedHasResponse(feed) &&
          !feed["response"]["checkins"].nil? &&
          !feed["response"]["checkins"]["count"].nil? &&
           feed["response"]["checkins"]["count"].to_i > 0 &&
          !feed["response"]["checkins"]["items"].nil? &&
           feed["response"]["checkins"]["items"].count > 0 &&
          !feed["response"]["checkins"]["items"].first["created_at"].nil? &&
          (DateTime.parse(feed["response"]["checkins"]["items"].first["created_at"]) >= yearStart)

    return val
  rescue
    puts "ERROR: #{feed.inspect}"
    return false
  end
end

#result = getUserDistinctBeers("iannacones1")
#result = getUserActivityFeed("iannacones1")
#puts "#{result.inspect}"

