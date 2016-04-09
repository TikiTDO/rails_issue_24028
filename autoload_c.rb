class AutoloadC
  puts "Loaded C"
  Thread.current.thread_variable_set(:loaded_c, true)
end