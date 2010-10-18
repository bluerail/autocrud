module Autocrud
  autoload :Controller, 'autocrud/controller'
  autoload :Helper, 'autocrud/helper'
  
  class Engine < Rails::Engine
    initializer 'autocrud.extend_rails_classes' do |app|
      ActiveSupport.on_load(:action_controller) do
        extend Autocrud::Controller::ClassMethods
      end

      ActiveSupport.on_load(:action_view) do
        include Autocrud::Helper::InstanceMethods
      end
    end    
  end
  
  class Railtie < Rails::Railtie
    rake_tasks do
      namespace :autocrud do
        desc "Install or update Autocrud assets in public directory"
        task :install do
          puts ""
          puts "LICO Innovations Autocrud installation"
          puts ""
          source_path = File.join(File.dirname(__FILE__), '..', 'assets')
          target_path = File.join(Rails.public_path, "autocrud") 
          begin            
            unless File.exists?(target_path)
              puts "Creating public/autocrud directory..."
              Dir.mkdir(target_path)
            end
            puts "Copying files to public/autocrud..."
            Dir[File.join(source_path,'*')].each do |mod|
              FileUtils.cp_r(mod, target_path, :verbose => true)
            end
            puts "Done!"
          rescue StandardError => e
            puts "Installation failed: #{e}. Please copy assets from #{source_path} to public/autocrud"
          end
          puts ""
          puts "Usage:"
          puts ""
          puts "* Place init_autocrud in <head /> to include appropriate javascript"          
          puts "* Use example.css for basic application css"
          puts ""          
        end
      end
    end    
  end

end