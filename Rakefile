require 'fileutils'

task :default do
  FileUtils.cd 'ruby1.8' do
    return false unless sh('rake')
  end
  
  FileUtils.cd 'ruby1.9' do
    return false unless sh('rake')
  end
end

task :int => :default do
  sh 'svn commit --message development'
  sh 'svn update --quiet'
end