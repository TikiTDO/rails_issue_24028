::RegularLoad = Thread.new do
  puts "Started thread in A to load B"
  AutoloadB
end