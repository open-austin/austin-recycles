require 'fileutils'

# Encapsulation for modifying the *.gemspec
# The .gemspec file is split into four sections: @header, @body, @dev_dependencies, and @footer.
# This is to facilitate updating (replacing) the gem.add_development_dependency lines.
class GemspecFile
  def initialize
    @header = []
    @body = []
    @gem_dependencies = []
    @dev_dependencies = []
    @footer = []
  end

  # Load the given .gemspec file
  # @param [#to_s] filename the path to the .gemspec to load
  def load(filename)
    @filename = filename.to_s
    mode = :in_header
    IO.readlines(@filename).each do |line|
      case mode
        when :in_header
          if line =~ %r{^\s*gem\.}
            mode = :in_dev_body
            case line
            when %r{^\s*gem\.add_development_dependency}
              @dev_dependencies << line
            when %r{^\s*gem\.add_dependency}
              @gem_dependencies << line
            else
              @body << line
            end
          else
            @header << line
          end
        when :in_dev_body
          if line =~ %r{^\s*end}
            mode = :in_footer
            @footer << line
          else
            case line
            when %r{^\s*gem\.add_development_dependency}
              @dev_dependencies << line
            when %r{^\s*gem\.add_dependency}
              @gem_dependencies << line
            else
              @body << line
            end
          end
        when :in_footer
          @footer << line
      end
    end
  end

  # replace the "gem.add_development_dependency(...)" lines in the development block
  # @param [Array<String>] gems an array of "gem.add_development_dependency(...)" lines for the development block
  # @return [String] the new @@dev_dependencies
  def dev_gems=(gems)
    @dev_dependencies = gems.map{|gem| "  #{gem}"}
  end

  # replace the "gem.add_dependency(...)" lines in the development block
  # @param [Array<String>] gems an array of "gem.add_dependency(...)" lines for the development block
  # @return [String] the new @@gem_dependencies
  def gems=(gems)
    @gem_dependencies = gems.map{|gem| "  #{gem}"}
  end

  # reassemble the file and save it
  # @param [String] filename the destination .gemspec path
  def save(filename=@filename)
    backup_filename = filename + '~'
    File.delete(backup_filename) if File.exist? backup_filename
    FileUtils.mv(filename, backup_filename)
    File.open(filename, 'w') do |f|
      f.puts @header
      f.puts @body
      f.puts @gem_dependencies
      f.puts @dev_dependencies
      f.puts @footer
    end
  end
end
