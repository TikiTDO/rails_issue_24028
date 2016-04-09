class AutoloadB
  puts "Loaded B"

  puts "Sleeping in Loader B to ensure Loader C is definitely defined"
  sleep(0.2)

  puts "Busy loop in Loader B to load C without any sort of join in the Loader B backtrace"
  while !AutoloadA::LoaderC.thread_variable_get(:loaded_c)
    sleep(0.1)
  end
end