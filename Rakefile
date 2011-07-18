require "rake"

begin
  require "jeweler"
  Jeweler::Tasks.new do |gem|
    gem.name = "autocrud"
    gem.summary = "Rails plugin for the automation of CRUD tasks"
    gem.description = "Rails plugin for the automation of CRUD tasks"
    gem.email = "info@lico.nl"
    gem.homepage = "http://lico.nl/"
    gem.authors = ["LICO Innovations"]
    gem.files = Dir["*", "{lib}/**/*", "{app}/**/*", "{assets}/**/*"]
    # TODO: Shouldn't our Gemfile take care of this?
    gem.add_dependency("haml", "~> 3.1.2")
  end
  
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end