# Execute the AutoloadB load in a different file to ensure no shared backtrace information
::RegularLoad = Thread.new do
  puts "Started thread in A to load B"
  AutoloadB
end