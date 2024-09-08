module ProvisionVagrant

  VAGRANTFILE_NAME = "Vagrantfile.template"
  POST_HOOK_FILE_NAME = "provision-vagrant.post-hook.sh"
  PROVISION_VAGRANT_CONFIG_FILE_NAME = "provision-vagrant.yml"
  VAGRANTFILE_TARGET_NAME = "Vagrantfile"

  def self.version
    "1.1.1"
  end

  def self.write_string_to_File(string, file_path)
    File.open(file_path, "w") {|file| file.puts string }
  end

  def self.help(msg)
    puts(Paint["\n#{msg}\n", :yellow])
    exit(false)
  end

end
