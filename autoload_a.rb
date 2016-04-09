class AutoloadA
  puts "Loaded A"
  
  puts "Starting backtrace_munge to ensure Loader B does not share any common backtraces with Loader C"
  Kernel.load('backtrace_munge.rb')

  LoaderC = Thread.new do 
    puts "Started Loader C to load C"

    puts "Sleeping in Loader C to ensure Loader B runs first"
    sleep(0.1)

    AutoloadC
  end
end