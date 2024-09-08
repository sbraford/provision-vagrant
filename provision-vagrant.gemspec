Gem::Specification.new do |s|
  s.name      = 'provision-vagrant'
  s.version   = '1.1.1'
  s.platform  = Gem::Platform::RUBY
  s.summary   = 'Opinionated vagrant box generator and provisioner for Ruby on Rails and beyond'
  s.description = "Easily spin up new Ubuntu/etc vagrant VM development boxes, provisioned to your exact specs"
  s.authors   = ['Shanti Braford']
  s.email     = ['shantibraford@gmail.com']
  s.homepage  = 'https://github.com/sbraford/provision-vagrant'
  s.license   = 'MIT'
  s.required_ruby_version = '>= 2.7.0'
  s.files     = Dir.glob("{lib,bin}/**/*") # This includes all files under the lib directory recursively, so we don't have to add each one individually.
  s.executables = ['provision-vagrant']
  s.require_path = 'lib'
  s.add_dependency 'rake', '~> 13.1'
  s.add_dependency 'paint', '~> 2.3', '>= 2.3'
  s.add_dependency 'optparse', '~> 0.5.0'
end