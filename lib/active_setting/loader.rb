require 'yaml'

module ActiveSetting
  class Loader
    def self.load_settings(filename = self.config_filename)
      settings_config(filename).each do |category_name, settings|
        settings.each do |setting_name, values|
          Setting.register(setting_name.to_sym, values.merge(
            data_type: values['type'],
            category:  category_name,
            name:      setting_name
          ))
        end
      end
    end

    def self.build_hash(filename = self.config_filename)
      settings_config(filename).map.with_object({}) do |(category_name, settings), hash|
        settings.each do |setting_name, values|
          attrs = values.merge(
            data_type: values['type'],
            category:  category_name,
            name:      setting_name.to_sym
          )
          hash[setting_name.to_sym] = Setting.new(attrs)
        end
      end
    end

    def self.config_filename
      @@config_filename || "settings.yml"
    end

    def self.config_filename=(filename)
      @@config_filename = filename
    end

    def self.settings_config(config_filename)
      raise FileNotFound, "#{config_filename} is required for settings" unless File.exists? config_filename
      yaml = YAML::load(File.read(config_filename))
      yaml['settings']
    end
  end
end
