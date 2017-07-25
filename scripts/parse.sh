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
  meta = doc.css('HolyQuran').first
  t_id = meta['TranslationID']
  iso = meta['LanguageIsoCode'][0..1]
  direction = meta['Direction']
  original = t_id.to_i === 1
  code = "q#{meta['LanguageIsoCode']}#{t_id}"
  code = "quran" if original
  name = meta['Writer']
  name = "القرآن الكريم" if original

  output[:data] << {
    id: t_id.to_i,
    code: code,
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
