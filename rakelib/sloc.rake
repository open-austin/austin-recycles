# Source Lines Of Code Count (sloccount).
# Requires that sloccount be installed on your system.
# mac:
#   brew install sloccount
#
# rake sloc                # generate sloccount metric reports used by Jenkins

unless `which sloccount`.strip.empty?
  desc 'generate sloccount metric reports used by Jenkins'
  task :sloc do
    FileUtils.mkdir_p File.dirname(Settings[:sloc_report])
    FileUtils.mkdir_p File.dirname(Settings[:sloc_report_raw])
    File.delete Settings[:sloc_report_raw] if File.exist? Settings[:sloc_report_raw]

    `sloccount --wide --details #{Settings[:source_dirs].join(' ')} >#{Settings[:sloc_report_raw]} 2>/dev/null`

    PATH_EXCLUDES = %w{save not_used old .git .svn}

    REGEX_EXCLUDES = [
        %r(~$)
    ]

    report = IO.readlines(Settings[:sloc_report_raw]).select{|line| line =~ /^\d+\s+/}

    File.delete Settings[:sloc_report] if File.exist? Settings[:sloc_report]
    File.open(Settings[:sloc_report], 'w') do |f|
      report.each do |line|
        line = line.strip
        next if line.empty?
        if line =~ /^(\d+)\s+(\S+)\s+(\S+)\s+(\S.*)/
          filespec = $4
          next if excluded_path(filespec, PATH_EXCLUDES)
          next if excluded_regex(filespec, REGEX_EXCLUDES)
          f.puts line
        end
      end
    end

  end

  def excluded_regex(filespec, regex_excludes)
    result = false
    regex_excludes.each do |regex|
      result = true if filespec =~ regex
    end
    result
  end

  def excluded_path(filespec, path_excludes)
    result = false
    filespec.split('/').each do |path_component|
      result = true if path_excludes.include?(path_component)
    end
    result
  end
end
