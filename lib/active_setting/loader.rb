require 'yaml'

module ActiveSetting
  class Loader

    class << self
      def load_settings(filename = nil)
        new(filename).load_settings
      end

      def build_hash(filename = nil)
        new(filename).build_hash
      end

      def config_filename
        @config_filename || 'settings.yml'
      end

      attr_writer :config_filename

      def external_settings
        @external_settings ||= {}
      end

      def register_external_setting(name, attrs)
        category ||= external_settings[attrs.fetch(:category, 'External')] ||= {}
        category[name] = attrs.map.with_object({}) { |(k,v), hash| hash[k.to_s] = v }
      end
    end

    def initialize(config_filename = nil)
      @config_filename = config_filename
    end

    def config_filename
      @config_filename || self.class.config_filename
    end

    def load_settings
      settings_config.each do |category_name, settings|
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

    def build_hash
      settings_config.map.with_object({}) do |(category_name, settings), hash|
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

    private

    def settings_config
      @settings_config ||= settings_from_file.merge(external_settings)
    end

    def external_settings
      self.class.external_settings
    end

    def settings_from_file
      return @settings_from_file unless @settings_from_file.nil?

      unless File.exist? config_filename
        fail ArgumentError, "#{config_filename} is required for settings"
      end
      yaml = YAML.load(File.read(config_filename))
      @settings_from_file = yaml.fetch('settings')
    end
  end
end
