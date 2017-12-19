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

require_gem 'terminal-table'

dir = File.expand_path('../', File.dirname(__FILE__))
file = File.read(File.join(dir, 'metadata.json'))
data = JSON.parse(file)['data']

rows = [['ID', 'Name', 'Original', 'Direction', 'Language', 'File'], :separator]
data.each do |t|
  id = "[#{t['id']}](https://alkotob.org/#{t['id']})"
  file_link = "[#{t['file']}](https://github.com/alkotob/quran-translations/raw/master/data/#{t['file']})"
  rows << [id, t['name'], t['original'], t['direction'], t['language'], file_link]
end

# Format markdown table
table = (Terminal::Table.new rows: rows)
  .to_s
  .split(/\n/)[1..-2]
  .join("\n")
  .gsub('+', '|')

# Update readme
readme_file = File.join(dir, 'README.md')
text = File.read(readme_file)

contents = []
text.each_line do |line|
  break if line.include? '| ID'
  contents << line
end

contents << table

File.open(readme_file, 'w') {|f| f.write(contents.join("\n")) }
