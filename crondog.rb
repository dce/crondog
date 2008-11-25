require 'rubygems'
require 'parse_tree'
require 'parse_tree_extensions'
require 'ruby2ruby'
require 'activesupport'

module Crondog
  class JobList
    @@jobs = []
    
    def self.jobs
      @@jobs
    end
  
    def self.method_missing(method, *args, &block)
      job = Job.new
      if job.respond_to? method
        @@jobs << job
        job.send(method, *args, &block)
      else
        @@jobs.send(method, *args, &block)
      end
    end
  end
  
  class Job
    attr_accessor :task

    def initialize
      @directives = ActiveSupport::OrderedHash.new
      [:minute, :hour, :day, :month, :weekday].each do |period|
        @directives[period] = Wildcard.new(self)
      end
    end
    
    def to_s
      @directives.values * " " + " #{filename}"
    end
    
    def every(value = 1)
      Wildcard.new(self, value)
    end

    def from(value)
      Ranged.new(self, value)
    end
    
    def at(*values)
      Fixed.new(self, values)
    end

    alias :on :at
    alias :during :at
    alias :and :at

    def task=(block)
      @task = block.to_ruby[7..-3]
    end

    def filename
      @description.downcase.gsub(' ', '_') + ".rb"
    end

    def to_file
      File.open(filename, "w") do |file|
        file.puts task
      end
    end

    def set_directive(directive, period, description, &block)
      @directives[period.to_s.singularize.to_sym] = directive
      @description = description
      self.task = block if block_given?
      self
    end
  end
  
  class Directive
    def initialize(job, value = 0)
      @job   = job
      @value = value
    end
    
    def method_missing(method, *args, &block)
      @job.set_directive(self, method, args.first, &block)
    end
  end
  
  class Wildcard < Directive
    def to_s
      @value > 1 ? "*/#{@value}" : "*"
    end
  end
  
  class Fixed < Directive
    def to_s
      @value * ","
    end
  end
  
  class Ranged < Directive
    def to_s
      "#{@value}-#{@end_val}"
    end

    def to(end_val)
      @end_val = end_val
      self
    end
  end
end
