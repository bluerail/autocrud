#require 'ftools'
require 'pp'
require 'yaml'

namespace :i18n do
  desc "Verify i18n translations"
  task :verify do
    locale_file_path = File.join(Rails.root.to_s, "config", "locales")

    locales = []
    locale_files = Hash.new
    Dir[File.join(locale_file_path,"*")].each do |entry|
      locale = File.basename(entry).gsub(/^.*_/,"").gsub(/.*\.([^\.]*\.[^\.]*)$/,"\\1").gsub(/\..*$/,"")
      locales.push locale unless locales.include?(locale)
      locale_files[locale] = [] unless locale_files.include?(locale)
      locale_files[locale].push entry
    end
  
    puts "#"
    puts "# Locales: " + locales.join(" ")
    puts "#"
  
    locale_entries = Hash.new
    locales.each do |locale|
      locale_entries[locale] = []
      locale_files[locale].each do |file|
        if /.yml$/ =~ file
          File.open(file) do |yf|
            generate_yaml_i18n_strings(YAML::load(yf)).each do |str|
              locale_entries[locale].push str.gsub(/^[^\.]*\./,"")
            end
          end
        else
          puts "Unknown file #{file} ignored..."
        end
      end
    end

    locale_entries.each do |locale, entries|
      entries.each do |entry|
        locale_entries.each do |other_locale, other_entries|
          puts "missing #{other_locale}.#{entry}" unless other_entries.include?(entry)
        end
      end
    end
  end

  task :generate_js do
    locale_file_path = File.join(Rails.root.to_s, "config", "locales")

    locales = []
    locale_files = Hash.new
    Dir[File.join(locale_file_path,"*")].each do |entry|
      locale = File.basename(entry).gsub(/^.*_/,"").gsub(/.*\.([^\.]*\.[^\.]*)$/,"\\1").gsub(/\..*$/,"")
      locales.push locale unless locales.include?(locale)
      locale_files[locale] = [] unless locale_files.include?(locale)
      locale_files[locale].push entry
    end
    
    target = File.join(RAILS_ROOT,"public","javascripts","i18n");
    File.makedirs(target) unless File.exists?(target)

    locale_entries = Hash.new
    locales.each do |locale|
      locale_entries[locale] = Hash.new
      locale_files[locale].each do |file|
        if /.yml$/ =~ file
          File.open(file) do |yf|
            generate_yaml_i18n_objects(YAML::load(yf)).each do |obj|
              locale_entries[locale][obj[0]] = obj[1]
            end
          end
        else
          puts "Unknown file #{file} ignored..."
        end
      end
    end
    
    locale_entries.each do |locale, entries|
      File.open(File.join(target,locale+".js"), "w") do |f|
        f.write "i18n_strings = " + entries.to_json + ";"
        puts "Written #{File.join(target,locale+".js")}"
      end
    end
  end
end
def generate_yaml_i18n_strings(hash, prepend = "")
  strs = []
  hash.each do |entry|
    if entry[1].is_a?(Hash)
      generate_yaml_i18n_strings(entry[1], prepend + entry[0] + ".").each do |str|
        strs.push str
      end
    else
      strs.push prepend + entry[0].to_s
    end
  end
  strs
end

def generate_yaml_i18n_objects(hash, prepend = "")
  strs = Hash.new
  hash.each do |entry|
    if entry[1].is_a?(Hash)
      generate_yaml_i18n_objects(entry[1], prepend + entry[0] + ".").each do |object|
        strs[object[0]] = object[1]
      end
    else
      interpolations = entry[1].to_s.split(/(\{\{.*?\}\})/).collect{|interpolation| interpolation.gsub(/\{\{(.*?)\}\}/,"\\1") if /\{\{.*?\}\}/ =~ interpolation}.compact
      if interpolations.length > 0
        strs[(prepend + entry[0].to_s).gsub(/^[^\.]*\./,"")] = [entry[1], interpolations]
      else
        strs[(prepend + entry[0].to_s).gsub(/^[^\.]*\./,"")] = entry[1]
      end
    end
  end
  strs
end