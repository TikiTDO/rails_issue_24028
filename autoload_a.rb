class AutoloadA
  puts "Loaded A"
  Thread.new do
    puts "Started thread in A to load B"
    AutoloadB
  end.join
end