#
# ansiblespec runner 
#
$stderr.sync = true
require 'optparse'
#require 'rake'
#require 'rspec/core/rake_task'
require 'rbconfig'
require 'yaml'
# default options
config = {}
config[:color] = false
config[:format] = "documentation"
config[:default_path] = ""
config[:rspec_path] = ""
config[:require] = ""
version = false

# parse arguments
# ignore -P argument 
file = __FILE__
ARGV.options do |opts|
  opts.on("-c", "--color")              { config[:color] = true }
  opts.on("-f", "--format FORMATTER", String) { |val| config[:format] = val }
  opts.on("", "--default-path PATH", String) { |val| config[:default_path] = val } 
  opts.on("-v", "--version")              { version = true }
  opts.on("", "--rspec-path PATH", String) { |val| config[:rspec_path] = "#{val}/" }
  opts.on("", "--require REQUIRE", String) { |val| config[:require] = val }
  opts.parse!
end

base_path = Dir.pwd
playbook = 'default.yml'
playbook = ENV['PLAYBOOK'] if  ENV['PLAYBOOK']
inventoryfile = 'hosts'
inventoryfile = ENV['INVENTORY'] if  ENV['INVENTORY']
kitchen_path = '/tmp/kitchen'
kitchen_path = ENV['KITCHEN_PATH'] if  ENV['KITCHEN_PATH']
user = 'root'
user = ENV['LOGIN_USER'] if ENV['LOGIN_USER']
sudo = ENV['SUDO'] if ENV['SUDO']
ssh_key = nil
if ENV['SSH_KEY']
  s = ENV['SSH_KEY']
  if s.start_with?('/') || s.start_with?('~')
    ssh_key = s
  else
    # if it was passed in by kitchen-ansible provisioner assume it has been copied to the .ssh directory by the converge
    ssh_key = "#{File.join("/home/#{user}/.ssh", File.basename(s))}"
  end
end
login_password = nil
login_password = ENV['LOGIN_PASSWORD'] if ENV['LOGIN_PASSWORD']

puts "BASE_PATH: #{base_path}, KITCHEN_PATH #{kitchen_path}, PLAYBOOK: #{playbook}, INVENTORY: #{inventoryfile}, LOGIN_USER: #{user}, SSH_KEY: #{ssh_key}, LOGIN_PASSWORD: #{login_password}"

if File.exist?("#{kitchen_path}/#{playbook}") == false
  puts "Error: #{playbook} is not Found at #{kitchen_path}."
  exit 1
elsif File.exist?("#{kitchen_path}/#{inventoryfile}") == false
  puts "Error: #{inventoryfile} is not Found at #{kitchen_path}."
  exit 1
end

playbook_file = YAML.load_file("#{kitchen_path}/#{playbook}")
properties = {}
keys = 0

playbook_file.each do |item|
  ansible_hosts = item['hosts'].split(',')
  ansible_roles = item['roles']
  hostnames = false
  ansible_hosts.each do |h|
    begin
      `ansible #{h} --list-hosts -i #{kitchen_path}/#{inventoryfile}`.lines do |line|
        keys += 1
        properties["host_#{keys}"] = {:host => line.strip, :roles => ansible_roles}
        puts "group: #{h} host: #{line.strip!} roles: #{ansible_roles}"
        hostnames = true
      end
    rescue
    end
    if !hostnames
      keys += 1
      properties["host_#{keys}"] = {:host => h, :roles => ansible_roles}
      puts "no group so using host: #{h} roles: #{ansible_roles}"
    end
  end
end

# Environment variable TARGET_HOST, LOGIN_USER, LOGIN_PASSWORD, SSH_KEY are specified in the spec_helper  
ENV['LOGIN_USER'] = user
ENV['SSH_KEY'] = ssh_key

if sudo == 'true' 
  rspec_cmd = " sudo -E #{config[:rspec_path]}rspec"
else
  rspec_cmd = "#{config[:rspec_path]}rspec"
end 

properties.keys.each do |key|
  #desc "Run serverspec #{key} for #{properties[key][:host]}"
  puts "-----> Run serverspec #{key} for host: #{properties[key][:host]} roles: #{properties[key][:roles]}" 
  # Environment variable TARGET_HOST, LOGIN_USER, LOGIN_PASSWORD, SSH_KEY are specified in the spec_helper 
  ENV['TARGET_HOST'] = properties[key][:host]
  s = "#{kitchen_path}/roles/{" + properties[key][:roles].join(',') + '}/spec/*_spec.rb'
  color = nil 
  color = '-c' if config[:color]
  require = nil
  require = "--require #{config[:require]}" if config[:require]
  puts "-----> Running: #{rspec_cmd} #{color} #{require} -f #{config[:format]} --default-path  #{config[:default_path]} -P #{s}"
  system "#{rspec_cmd} #{color} #{require} -f #{config[:format]} --default-path  #{config[:default_path]} -P #{s}"
end

 
