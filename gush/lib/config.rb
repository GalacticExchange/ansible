module Config
  class << self

    attr_accessor :conf

    def load_conf(env)
      self.conf = YAML.load_file(self.conf_path(env))
    end


    def conf_path(env)
      File.join(File.dirname(__FILE__), '..', 'config', "#{env}.yml")
    end


    def method_missing(method_sym, *arguments, &block)
      self.conf.fetch(method_sym.to_s)
    end


  end
end

Config.load_conf(ENV.fetch('gex_env'))
