class AutoloadA
  puts "Loaded A"
  Kernel.load('regular_load.rb')
  ::RegularLoad.join
end