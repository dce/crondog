require 'rubygems'
require 'ruby2ruby'

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
    attr_accessor :minute, :hour, :day, :month, :weekday, :description, :task
    
    def initialize
      [:minute, :hour, :day, :month, :weekday].each do |field|
        self.send "#{field}=", Wildcard.new(self)
      end
    end
    
    def to_s
      [:minute, :hour, :day, :month, :weekday].map { |field|
        self.send(field).to_s
      } * " " + " " + description.downcase.gsub(' ', '_') + ".rb"
    end
    
    def every(value = 1)
      Wildcard.new(self, value)
    end
    
    def at(value)
      Fixed.new(self, value)
    end
    
    alias :on :at
    alias :during :at
    alias :and :at

    def task=(block)
      klass = Class.new
      klass.class_eval do
        define_method :task, &block
      end
      @task = Ruby2Ruby.translate(klass, :task)[11..-5]
      { /\n  / => "\n", /\n\n/ => "\n" }.each do |pattern, sub|
        @task.gsub!(pattern, sub)
      end
    end
  end
  
  class Directive
    def initialize(job, value = 0)
      @job   = job
      @value = value
    end
    
    def method_missing(method, *args, &block)
      @job.send(method.to_s.gsub(/s$/, '') + '=', self)
      @job.description ||= args.first
      @job.task ||= block if block_given?
      @job
    end
  end
  
  class Wildcard < Directive
    def to_s
      @value > 1 ? "*/#{@value}" : "*"
    end
  end
  
  class Fixed < Directive
    def to_s
      "#{@value}"
    end
    
    def through(end_value)
      Ranged.new(@job, @value, end_value)
    end
  end
  
  class Ranged < Directive
    def initialize(job, start_val, end_val)
      @job       = job
      @start_val = start_val
      @end_val   = end_val
    end
    
    def to_s
      "#{@start_val}-#{@end_val}"
    end
  end
end

# every.day.at(13) "send daily emails" do
# 
# end
# 
# on(:thursday).through(:saturday).at(13) "send weekly emails" do
# 
# end
# 
# on.day(1).at(12) "pay rent" do
#   
# end
# 
# every.day.in.month(2) "celebrate black history" do
#   
# end

