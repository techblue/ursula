require 'spec_helper'

describe user('mysql') do
  it { should exist }
end

describe process('mysqld_safe') do
  it { should be_running }
end

describe process('mysqld') do
  it { should be_running }
  its(:user) { should eq "mysql" }
end

files = Dir['/var/lib/mysql/*/'].map { |a| File.basename(a) }
files.each do |file|
  describe file("/var/lib/mysql/#{file}") do
    it { should be_mode 700 }
    it { should be_owned_by 'mysql' }
    it { should be_grouped_into 'mysql' }
  end
end

files = Dir['/var/lib/mysql/*.{log,cnf,dat,pid,flag}'].map { |a| File.basename(a) }
files.each do |file|
  describe file("/var/lib/mysql/#{file}") do
    it { should be_mode '[6][0-6][0-4]' }
  end
end


files = ['bind-inaddr-any.cnf', 'replication.cnf', 'tuning.cnf' , 'utf8.cnf']
files.each do |file|
  describe file("/etc/mysql/conf.d/#{file}") do
    it { should be_mode 644 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
  end
end 

files = {'conf.d' => 755, 'debian.cnf' => 600, 'my.cnf' => 644 }
files.each do |file, mode|
  describe file("/etc/mysql/#{file}") do
    it { should be_mode mode }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
  end
end

files = ['mysql.err', 'mysql.log' ]
files.each do |file, mode|
  has_file = file("/var/log/mysql/#{file}").exists?
  describe file("/var/log/mysql/#{file}"), :if => has_file do
    it { should be_mode 644 }
    it { should be_owned_by 'mysql' }
    it { should be_grouped_into 'adm' }
   end  
end

describe file('/etc/logrotate.d/mysql') do
  it { should exist }
  file_contents = [
                    '# Generated by Ansible.',
                    '# Local modifications will be overwritten.',
                    '',
                    '/var/log/mysql/*.err',
                    '{',
                    '  daily',
                    '  missingok',
                    '  rotate 7',
                    '  compress',
                    '  postrotate',
                    '  test -x /usr/bin/mysqladmin && /usr/bin/mysqladmin ping > /dev/null && /usr/bin/mysqladmin flush-logs > /dev/null',
                    '  endscript',
                    '  minsize 100k',
                    '}'
                  ]
  file_contents.each do |file_line|
    it { should contain file_line }
  end
end

