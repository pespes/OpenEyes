require 'json/pure'
require 'net/http'

class Coucher
  
  #include Processing::Proxy

  def initialize(x, y, z, path)
    
  end
  
  def get_couch_locs
    url = URI.parse('http://localhost:5984/flights/_design/all_latlong/_view/allgeo')
    req = Net::HTTP::Get.new(url.path)
    res = Net::HTTP.start(url.host, url.port) {|http|
    http.request(req)
    }
    json = JSON.parse(res.body)
    json["rows"].each do |row|
      loc = PVector.new(row["value"]["lat"].to_f, row["value"]["long"].to_f, 0)
      @markers.push(loc)
    end
  end
  
end