require "rubygems"
gem "geoutm"
require "geoutm"

# Requires a dataset in csv form of columns lon,lat in a given input file (arg 1)
converted = []
file = File.open(ARGV[0], "r")
lines = file.readlines
file.close
lines.each do |line|
  lon = line.split.first.to_f
  lat = line.split.last.to_f
  lonlat = GeoUtm::LatLon.new(lat, lon)
  utm = lonlat.to_utm
  # All given data is assumed to be in the same zone, if not, we assume that search queries only target locations in the same utm zone
  converted << "#{utm.e},#{utm.n},#{utm.zone}"
end

# Prints out a csv file of form e,n,zone, a UTM equivalent of the given lon,lat coordinate pair to given output file (arg 2)
file = File.new(ARGV[1], "w")
converted.each do |line|
  file.write line + "\n"
end
file.close