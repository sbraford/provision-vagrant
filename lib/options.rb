
require 'optparse'
require 'paint'

module ProvisionVagrant

  class Options

    def initialize
    end

    def parse_options
      options = { verbose: false }
      OptionParser.new do |parser|
        @parser = parser

        parser.on("-c", "--config", "Specify the yml config file to use") do |c|
          options[:config] = c
        end

        parser.on("-d", "--delete", "Delete files copied over from init command") do |d|
          options[:delete] = true
        end

        parser.on("-f", "--force", "Force initialization even if target files already exist") do |f|
          options[:force] = true
        end

        parser.on("-t", "--template", "Specify the path the to the Vagrantfile template") do |t|
          options[:template] = t
        end

        parser.on("-v", "--version", "Shows the version number") do |v|
          options[:version] = true
        end

        parser.on("-h", "--help", "Show this help message") do |h|
          options[:help] = true
        end

        parser.on("-i", "--init", "Initialize provision-vagrant with files it needs to operate") do |i|
          options[:init] = true
        end
      end.parse!

      if options[:version]
        help(ProvisionVagrant.version)
      end

      if options[:help]
        help
      end

      if options[:delete]
        Generator.new.delete
        exit(true)
      end

      if options[:config] && !File.exist?(options[:config])
        help "Error: Invalid config file specified (not found): #{CONFIG}"
      end

      if options[:temlpate] && !File.exist(options[:template])
        help "Error: Invalid template file specified (not found): #{TEMPLATE}"
      end

      if options[:init]
        initiliazer = PvInitializer.new(options)
        initiliazer.init
        exit(true)
      end

      options
    end

    def help(msg = nil)
      if msg
        puts(Paint["\n#{msg}\n", :yellow])
        exit(false)
      end

      msg = <<~END_HELP
        provision-vagrant: Generates and provisions a new vagrant vm box using template files

        Syntax: provision-vagrant NEW_BOX_NAME

        Options:
          -c Specify a path to the config yml file to use (default: ~/provision-vagrant.yml)
          -d Delete files copied over from init command
          -h Show this help message
          -t Specify a path to the Vagrantfile template to use (default: ~/Vagrantfile.template)
          -v Show version number

        Example:

          provision-vagrant foo-bar-app

        This will do the following:

          - Create a new directory "foo-bar-app" under your home directory
          - Create a "dev-box" directory within that directory (~/foo-bar-app/dev-box/)
          - Copy over ~/Vagrantfile.template and replace the {{vars}} with project/config vars

        See:
          https://github.com/sbraford/provision-vagrant
      END_HELP

      puts(Paint[msg, :magenta])
      exit(true)
    end

  end
end