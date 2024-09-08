require 'fileutils'

module ProvisionVagrant

  class PvInitializer

    def initialize(opts = {})
      @opts = opts
      @opts.merge!(read_default_config_opts)
    end

    def init
      puts "\nUsing home directory: #{user_directory}"

      if !opts[:force] && (File.exist?(target_vagrantfile_path) || File.exist?(target_post_hook_path))
        help("Aborting. One of the target output files already exists: #{target_file_list}")
        exit(false)
      end

      copy_vagrantfile_template
      copy_interpolated_post_hook
      copy_provision_vagrant_config

      if File.exist?(target_vagrantfile_path) &&
           File.exist?(target_post_hook_path) &&
           File.exist?(target_provision_vagrant_config_path)
        puts "\nSuccess! You should now be ready to use provision-vagrant. Usage:\n\n"
        puts "  provision-vagrant new-box-name\n\n"
        exit(1)
      else
        msg = "Error: There was a probelm initializing provision-vagrant. One of the following files did not get created: #{target_file_list}"
        help(msg)
        exit(0)
      end
    end

    def copy_vagrantfile_template
      puts "Copying example Vagrantfile template to: #{target_vagrantfile_path}"
      FileUtils.cp(source_vagrantfile_path, target_vagrantfile_path)
    end

    def copy_interpolated_post_hook
      complete_opts = opts.merge(fetch_github_vars)
      interpolator = Interpolator.new( { vars: complete_opts, input: post_hook_source_string })
      interpolated = interpolator.interpolate
      copy_post_hook_script(interpolated)
    end

    def copy_post_hook_script(interpolated)
      puts "Copying example post hook bash script to: #{target_post_hook_path}"
      ProvisionVagrant.write_string_to_File(interpolated, target_post_hook_path)
    end

    def copy_provision_vagrant_config
      puts "Copying provision-vagrant config yml file to: #{target_provision_vagrant_config_path}"
      FileUtils.cp(source_provision_vagrant_config_path, target_provision_vagrant_config_path)
    end

    def user_directory
      @_user_directory ||= set_userdir
    end

    private

    attr_accessor :opts

    def gem_template_dir
      @_gem_dir ||= File.join(File.dirname(__FILE__), "templates")
    end

    def source_vagrantfile_path
      @_source_vagrantfile_path ||= File.join(gem_template_dir, VAGRANTFILE_NAME)
    end

    def target_vagrantfile_path
      @_target_vagrantfile_path ||= File.join(set_userdir, VAGRANTFILE_NAME)
    end

    def source_post_hook_path
      @_source_post_hook_path ||= File.join(gem_template_dir, POST_HOOK_FILE_NAME)
    end

    def target_post_hook_path
      @_target_post_hook_path ||= File.join(set_userdir, POST_HOOK_FILE_NAME)
    end

    def source_provision_vagrant_config_path
      @_source_provision_vagrant_config_path ||= File.join(gem_template_dir, PROVISION_VAGRANT_CONFIG_FILE_NAME)
    end

    def target_provision_vagrant_config_path
      @_target_provision_vagrant_config_path ||= File.join(set_userdir, PROVISION_VAGRANT_CONFIG_FILE_NAME)
    end

    def post_hook_source_string
      @_post_hook_source_string ||= File.read(source_post_hook_path)
    end

    def options_klass_obj
      @_options_klass_obj ||= Options.new
    end

    def set_userdir
      # default to HOME environment variable
      return ENV['HOME'] if ENV['HOME']

      # fallback to use the first two dir paths ("/home/username")
      current_dir = Dir.pwd
      parts = current_dir.split("/")
      base_path = File.join("/", parts[1], parts[2])

      base_path
    end

    def fetch_github_vars
      git_config = `git config --list`
      unless git_config
        msg = "There was a problem parsing your git config (\"git config --list\". Please ensure git is installed and configured."
        help(msg)
        exit(false)
      end

      github_vars = {}

      lines = git_config.split("\n")
      lines.each do |line|
        next unless line && line.size > 0

        var, value = *line.split('=')
        if var == 'user.name'
          github_vars[:github_name] = value
        end

        if var == 'user.email'
          github_vars[:github_email] = value
        end
      end

      github_vars
    end

    def help(msg = nil)
      options_klass_obj.help(msg)
    end

    def target_file_list
      target_paths = [
        target_vagrantfile_path,
        target_vagrantfile_path,
        target_post_hook_path
      ]
      joined = target_paths.join("\n")

      "\n#{joined}"
    end

    def read_default_config_opts
      yaml_hash = YAML.load_file(source_provision_vagrant_config_path)
      return {} unless yaml_hash && yaml_hash["configuration"]

      yaml_hash["configuration"]
    end
  end
end