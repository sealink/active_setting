require 'yaml'

module ActiveSetting
  class Loader
    def self.load_settings(filename = config_filename)
      settings_config(filename).each do |category_name, settings|
        settings.each do |setting_name, values|
          attrs = values.merge(
            data_type: values['type'],
            category:  category_name,
            name:      setting_name
          )
          Setting.register(setting_name.to_sym, attrs)
        end
      end
    end

    def self.build_hash(filename = config_filename)
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
      @config_filename || 'settings.yml'
    end

    class << self
      attr_writer :config_filename
    end

    def self.settings_config(config_filename)
      unless File.exist? config_filename
        fail FileNotFound, "#{config_filename} is required for settings"
      end
      yaml = YAML.load(File.read(config_filename))
      yaml['settings'].merge(external_settings)
    end

    def self.external_settings
      @external_settings ||= {}
    end

    def self.register_external_setting(name, attrs)
      category ||= external_settings[attrs.fetch(:category, 'External')] ||= {}
      category[name] = attrs.stringify_keys
    end
  end
end
