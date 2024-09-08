require_relative './lib/provision_vagrant'

GEM_NAME = "provision-vagrant"
GEM_VERSION = ProvisionVagrant.version

task :default => :build

task :build do
  system "gem build " + GEM_NAME + ".gemspec"
end

task :install => :build do
  system "gem install --local " + GEM_NAME + "-" + GEM_VERSION + ".gem"
end

task :uninstall => :build do
  system "gem uninstall " + GEM_NAME
end

task :publish => :build do
  system 'gem push ' + GEM_NAME + "-" + GEM_VERSION + ".gem"
end

task :clean do
  system "rm *.gem"
end