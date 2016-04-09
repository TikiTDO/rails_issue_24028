class AutoloadA
  puts "Loading A"
  Thread.new do
    AutoloadB
  end.join
end