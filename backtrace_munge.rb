# Execute the AutoloadB load in a different file to ensure no shared backtrace information
AutoloadA::LoaderB = Thread.new do
  puts "Started Loader B to load B"
  AutoloadB
end