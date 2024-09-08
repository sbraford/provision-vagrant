require 'yaml'

module ProvisionVagrant

  class Generator

    def initialize(opts = {})
      @opts = opts
      @project_name = opts[:project_name]
      @initializer = PvInitializer.new(opts)
      @config_opts = read_config_opts(opts[:config])
    end

    def generate
      puts "\nNew box name: #{project_name}"
      create_new_project_dir

      if !File.exist?(dev_box_dir_path)
        ProvisionVagrant.help("Error: there was a problem creating target project directory: #{dev_box_dir_path}")
      end

      copy_vagrantfile
      puts "\nNext, cd into your new project directory: #{dev_box_dir_path}"
      puts "\nAnd start/provision your new vagrant box:\n\n  vagrant up\n"
      puts "\nOnce your vagrant vm is running, ssh in as usual:\n\n  vagrant ssh\n"
      puts "\nThe first time you login, run the post hooks installation script:\n\n  ./#{POST_HOOK_FILE_NAME}\n"
      puts "\nSuccess! Exiting.\n"
    end

    def delete
      [default_config_path,
       default_vagrantilfe_path,
       default_post_hook_path].each do |file_name|
        if File.exist?(file_name)
          puts "Removing: #{file_name}"
          FileUtils.rm_f(file_name)
        end
      end
    end

    def project_path
      @_project_path ||= File.join(initializer.user_directory, project_name)
    end

    def dev_box_dir_path
      @_dev_box_dir_path ||= File.join(initializer.user_directory, project_name, "dev-box/")
    end

    def create_new_project_dir
      puts "Creating #{project_name} directory: #{dev_box_dir_path}"
      FileUtils.mkdir_p(dev_box_dir_path)
    end

    def copy_vagrantfile
      vars = config_opts.merge({ project_name: project_name })
      interpolator = Interpolator.new( { vars: vars, input: vagrantfile_string })
      interpolated = interpolator.interpolate

      ProvisionVagrant.write_string_to_File(interpolated, target_vagrantfile_path)
      if File.exist?(target_vagrantfile_path)
        puts "Copied #{vagrantfile_path} (and inerpolated its vars) to: #{target_vagrantfile_path}"
      else
        ProvisionVagrant.help("Error: there was a problem copying over your Vagrantilfe.template (dfeault) from #{vagrantfile_path} to #{target_vagrantfile_path}")
      end
    end

    def default_config_path
      @_default_config_path ||= File.join(initializer.user_directory, PROVISION_VAGRANT_CONFIG_FILE_NAME)
    end

    def default_vagrantilfe_path
      @_default_vagrantfile_path ||= File.join(initializer.user_directory, VAGRANTFILE_NAME)
    end

    def default_post_hook_path
      @_default_post_hook_path ||= File.join(initializer.user_directory, POST_HOOK_FILE_NAME)
    end

    def vagrantfile_path
     @_vagrantfile_path ||= (opts[:template] || default_vagrantilfe_path)
    end

    def target_vagrantfile_path
      @_target_vagrantfile_path ||= File.join(dev_box_dir_path, VAGRANTFILE_TARGET_NAME)
    end

    def vagrantfile_string
      File.read(vagrantfile_path)
    end

    private

    attr_accessor :opts, :config_opts, :initializer, :project_name

    def read_config_opts(config_path = nil)
      config_path ||= default_config_path
      return {} unless File.exist?(config_path)

      yaml_hash = YAML.load_file(config_path)
      return {} unless yaml_hash && yaml_hash["configuration"]

      yaml_hash["configuration"]
    end
  end

end