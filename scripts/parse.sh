#!/usr/bin/env ruby

require 'rubygems'
require 'rubygems/dependency_installer'
require 'json'

def require_gem gem_name
  begin
    gem gem_name
  rescue LoadError
    Gem::DependencyInstaller.new.install gem_name
  end
  require gem_name
end

require_gem 'nokogiri'

output = { data: [] }

dir = File.expand_path('../data', File.dirname(__FILE__))
Dir.entries(dir).each do |filename|
  next if filename.start_with? '.'
  file = File.join(dir, filename)

  doc = Nokogiri::XML(File.open(file))

  # Parse metadata
  meta      = doc.css('collection').first
  code      = meta['id']
  iso       = meta['language']
  direction = meta['direction']
  original  = code === 'quran'
  name      = meta['name']

  output[:data] << {
    id: code,
    original: original,
    name: name,
    direction: direction,
    language: iso,
    file: filename
  }
end

# Sort by translation ID
output[:data] = output[:data].sort_by{|e| e[:id]}

metadata_file = File.expand_path('../metadata.json', File.dirname(__FILE__))
File.open(metadata_file, 'w') do |f|
  f.write(JSON.pretty_generate(output))
end
