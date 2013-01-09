require "rubygems"
require "geoutm"

converted = []
File.open(ARGV[0], "r").do |line|
  lon = line.split.first.to_i
  lat = line.split.last.to_i
  lonlat = GeoUtm::LonLat.new(lon, lat)
  utm = lonlat.to_utm
  # All given data is assumed to be in the same zone, if not, we assume that serach queries only target locations in the same utm zone
  converted << "#{utm.e} #{utm.n}"
end.close

file = File.new(ARGV[1], "w")
converted.each do |line|
  file.write line + "\n"
end
file.close