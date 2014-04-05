#!/usr/bin/ruby
require 'untappd'

def configUntappd
  Untappd.configure do |config|
    config.client_id = '276C318EEC6130BEE8028B70217C253A1AD88DB7'
    #config.client_id = File.read('.id')
    config.client_secret = '5D40ED388EDA3BE7CAF6BE4C9AB6CA09392FFF45'
    #config.client_secret = File.read('.secret')
    config.gmt_offset = -5
  end
end

def getToken
  return 'E50B0C091A5F71832D218313B604BD6E83B64178'
  #return File.read('.access')
end
