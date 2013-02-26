require File.expand_path('rakelib/settings.rb', Rake.application.original_dir)

# http://dia-installer.de/
#
# rake dia_to_svg             # convert dia diagrams to SVG files
# rake dia_to_pdf             # convert dia diagrams to PDF files
# rake dia_to_png             # convert dia diagrams to PNG files
#
# requires dia to be installed.
#

desc 'build SVG images from diagrams'
task :dia_to_svg do
  puts 'building svg images from diagrams'
  Dir['**/*.dia'].each do |src|
    filename = File.expand_path(File.basename(src, '.*'), File.dirname(src))
    puts "dia --export=#{filename}.svg #{filename}.dia"
    puts `dia --export=#{filename}.svg #{filename}.dia`
  end
end

desc 'build PDF images from diagrams'
task :dia_to_pdf do
  puts 'building pdf images from diagrams'
  Dir['**/*.dia'].each do |src|
    filename = File.expand_path(File.basename(src, '.*'), File.dirname(src))
    puts "dia --export=#{filename}.pdf #{filename}.dia"
    puts `dia --export=#{filename}.pdf #{filename}.dia`
  end
end

desc 'build PNG images from diagrams'
task :dia_to_png do
  puts 'building png images from diagrams'
  Dir['**/*.dia'].each do |src|
    filename = File.expand_path(File.basename(src, '.*'), File.dirname(src))
    puts "dia --export=#{filename}.png #{filename}.dia"
    puts `dia --export=#{filename}.png #{filename}.dia`
  end
end

task :clean do
  FileUtils.rm_f Dir['*.pdf']
  FileUtils.rm_f Dir['*.png']
  FileUtils.rm_f Dir['*.svg']
end