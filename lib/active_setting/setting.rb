module ActiveSetting
  class Setting # < ActiveRecord::Base
    attr_accessor :name, :data_type, :subtype, :options, :description, :exists, :category, :raw_value

    def initialize(attr = {})
      attr.each do |key,value|
        setter = (key.to_s + '=').to_sym
        send(setter, value) if methods.include?(setter)
      end
    end

    def self.config_filename
      @@config_filename || "settings.yml"
    end

    def self.config_filename=(filename)
      @@config_filename = filename
    end

    def self.settings_config
      raise FileNotFound, "#{config_filename} is required for settings" unless File.exists? config_filename
      yaml = YAML::load(File.read(config_filename))
      yaml['settings']
    end

    def self.settings_hash
      @@settings_hash ||= begin
        isettings = {}
        settings_config.each do |category_name, settings|
          settings.each do |setting_name, values|
            isettings[setting_name.to_sym] = values.merge(
              :data_type => values['type'],
              :category => category_name,
              :name => setting_name
            )
          end
        end
        isettings
      end
    end

    def setting
      self.class.settings_hash[@name.to_sym]
    end

    def data_type
      @data_type.to_sym if @data_type
    end

    def subtype
      @subtype.to_sym if @subtype
    end

    def description
      @description
    end

    def category
      @category
    end

    def options
      @options || (eval(setting[:options]) if !setting[:options].blank?)
    end

    def self.convert_value(val, data_type)
      case data_type
      when :boolean
        true if ![nil, false, 'false', 0, '0'].include?(val)
      when :integer then val.to_i
      when :string then val.to_s
      when :symbol then val.to_sym
      when :decimal then BigDecimal(val)
      else val
      end
    end

    def value
      # TODO: WHY IS the first line here
      return nil if raw_value.nil?

      case data_type
      when :array
        YAML::load(raw_value)
      when :hash
        chunks = raw_value.split(',')
        chunks.inject({}) do |h, v|
          key, subval = v.split(':')
          h[key.strip.to_sym] = subval.strip
          h
        end
      when :csv
        return raw_value if raw_value.empty? # e.g. default = []
        raw_value.split(',').map(&:strip).map{|e| Setting.convert_value(e, subtype) }
      else
        Setting.convert_value(raw_value, data_type)
      end
    end

    def value=(newval)
      newval = newval.join(',') if data_type == 'csv' && newval.is_a?(Array)
      self.raw_value = newval
    end
  end
end
