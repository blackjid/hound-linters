$:.unshift(".", "lib")
Dir.glob("jobs/**/*.rb").each { |file| require file }
Dir.glob("lib/**/*.rb").each { |file| require file }

ENV["RACK_ENV"] ||= "development"
Dir.glob("lib/tasks/**/*.rake").each { |file| load file }
