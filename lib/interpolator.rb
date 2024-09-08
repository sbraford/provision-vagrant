module ProvisionVagrant

  class Interpolator

    DEFAULT_VAGRANTFILE_NAME = "Vagrantfile.template"
    DEFAULT_POST_HOOK_FILE_NAME = "provision-vagrant.post-hook.sh"

    def initialize(opts = {})
      @vars = opts[:vars]
      @input = opts[:input]
    end

    # Loops through a Hash (@vars) and replaces any of its keys found in
    # the @input string with the corresponding hash values
    def interpolate
      @vars.each do |k, v|
        var_wrapped = "{{#{k.to_s}}}"
        @input.gsub!(var_wrapped, v.to_s)
      end

      @input
    end
  end

end