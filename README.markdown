Crondog
=======

Crondog is designed to take the pain out of creating and deploying [cronjobs][cron]. Currently, it's just a simple DSL for describing how often tasks should occur:

    every(5).minutes "ping production server" do
      `ping 127.0.0.1`
    end
    
    at(10).hours.and(0).minutes "sum 1 through 5" do
      (1..5).inject {|sum, i| sum + i }
    end
    
Some more examples can be found in the tests. The next step is to create [rake][] tasks to generate ruby scripts and set up the cron directives.

  [cron]: http://en.wikipedia.org/wiki/Cron
  [rake]: http://rake.rubyforge.org/

Dependencies
------------

We're using [Ruby2Ruby][r2r] to convert procs into strings.

  [r2r]: http://seattlerb.rubyforge.org/ruby2ruby/