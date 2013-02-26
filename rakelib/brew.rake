# tasks for installing on mac OSX using brew
#
# Expects brew installation commands to be in the comments of .rake files and
# to be formatted as "# brew install ..."

namespace :brew do
  desc 'Show needed brews for installing on mac OSX'
  task :show do
    brews = []
    Dir["#{Rake.application.original_dir}/rakelib/*.rake"].each do |fn|
      IO.readlines(fn).each do |line|
        if line =~ %r{^#\s+(brew\s+install\s+.*)$}
          brews << $1
        end
      end
    end
    puts brews.join("\n")
  end
end
