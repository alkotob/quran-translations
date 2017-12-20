#!/usr/bin/env ruby

require 'rubygems'
require 'rubygems/dependency_installer'
require 'json'
require 'fileutils'

def require_gem gem_name
  begin
    gem gem_name
  rescue LoadError
    Gem::DependencyInstaller.new.install gem_name
  end
  require gem_name
end

require_gem 'nokogiri'

# Setup output dir
output_dir = File.expand_path('../data', File.dirname(__FILE__))
FileUtils.mkdir_p output_dir

dir = File.expand_path('../downloads', File.dirname(__FILE__))
Dir.entries(dir).each do |filename|
  next if filename.start_with? '.'
  file = File.join(dir, filename)

  doc = Nokogiri::XML(File.open(file))

  # Parse metadata
  meta      = doc.css('HolyQuran').first
  t_id      = meta['TranslationID']
  iso       = meta['LanguageIsoCode'][0..1]
  direction = meta['Direction']
  original  = t_id.to_i === 1
  code      = "q#{meta['LanguageIsoCode']}#{t_id}"
  code      = "quran" if original
  name      = meta['Writer']
  name      = "القرآن الكريم" if original

  builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
    q_meta = {
      id: code,
      format: :quran,
      name: name,
      bismillah: 'بسم الله الرحمن الرحيم',
      direction: direction,
      language: iso
    }

    xml.collection(q_meta) {
      xml.chapters {
        doc.css('Chapter').each do |chapter|
          xml.chapter(id: chapter['ChapterID'], name: chapter['ChapterName']) {
            xml.verses {
              chapter.children.each do |verse|
                next if verse.blank?

                xml.verse(id: verse['VerseID']) {
                  xml.content {
                    xml.cdata(verse.text)
                  }
                }
              end
            }
          }
        end
      }
    }
  end

  output_file = File.join(output_dir, "#{code}.xml")
  File.open(output_file, "w") do |f|
    f.write(builder.to_xml(indent: 2))
  end

end
