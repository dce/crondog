Crondog
=======

Crondog is designed to take the pain out of creating and deploying [cronjobs][cron]. Currently, it's just a simple DSL for describing how often tasks should occur.

Set finite times with 'at', and chain them with 'and':

    at(10).hours.and(0).minutes "sum 1 through 5" do
      (1..5).inject {|sum, i| sum + i }
    end

Repeating tasks use 'every':

    every(5).minutes "ping production server" do
      `ping 127.0.0.1`
    end
    
Set up ranges with 'from' and 'to':

    from(9).to(17).hours "sit at desk" do
      # code goes here
    end

You can use literal day and month names:

    on("Tuesday").at(11).hours "talk to Morrie" do
      # code goes here
    end

If you're ending with a literal, use a comma:

    during "April", "bring an umbrella" do
      # code goes here
    end
    
Some more examples can be found in the tests. The next step is to create [rake][] tasks to generate ruby scripts and set up the cron directives.

  [cron]: http://en.wikipedia.org/wiki/Cron
  [rake]: http://rake.rubyforge.org/

Dependencies
------------

We're using [ParseTree][pst] and [Ruby2Ruby][r2r] to convert procs into strings, and [ActiveSupport][act] for a few utility methods.

  [act]: http://as.rubyonrails.com/
  [pst]: http://www.zenspider.com/ZSS/Products/ParseTree/
  [r2r]: http://seattlerb.rubyforge.org/ruby2ruby/