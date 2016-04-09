class AutoloadA
  puts "Loaded A"
  Kernel.load('backtrace_munge.rb')
  ::RegularLoad.join
end