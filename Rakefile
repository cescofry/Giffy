
module Plist
  def plist_get(plist, key)
    `/usr/libexec/PlistBuddy #{plist} -c \"Print :#{key}\"`.chomp
  end

  def info_plist
    Dir.glob("*/Info.plist").first
  end

end

include Plist

module Constants
  NAME = "Giffy"
  ARCHIVE_FOLDER = "Archive/#{plist_get(info_plist, 'CFBundleVersion')}/"
  ARCHIVE_PATH = "./#{ARCHIVE_FOLDER}/#{NAME}.xcarchive"
  EXPORT_PATH = "./#{ARCHIVE_FOLDER}/#{NAME}"
end



include Constants

desc 'Archive Application'
task :archive do
  sh "xcodebuild archive -scheme \"#{NAME}\" -archivePath \"#{ARCHIVE_PATH}\""
end

desc 'Export Application'
task :export do
  sh "xcodebuild archive -scheme \"#{NAME}\" -archivePath \"#{ARCHIVE_PATH}\""
  sh "xcodebuild -exportArchive -archivePath \"#{ARCHIVE_PATH}\"  -exportPath \"#{EXPORT_PATH}\""
end

desc 'Deploy process'
task :deploy do
  Rake::Task["archive"].invoke
  Rake::Task["export"].invoke
end
