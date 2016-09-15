require 'bigdecimal'

module ActiveSetting
  class Setting # < ActiveRecord::Base
    attr_accessor :name, :description, :category, :raw_value, :default
    attr_reader :data_type, :subtype, :options

    def self.registered_settings
      @registered_settings ||= {}
    end

    def initialize(attr = {})
      attr.each do |key, value|
        setter = "#{key}="
        send(setter, value) if respond_to?(setter)
      end
    end

    def self.register(name, options)
      new(options.merge(name: name)).register
    end

    def register
      self.class.registered_settings[name.to_sym] = self
      Setting.define_shortcut_method(self)
      self
    end

    def self.define_shortcut_method(setting)
      class_eval <<-TEXT
        def self.#{setting.name}
          self.class.registered_settings[:#{setting.name}].value
        end
        def self.#{setting.name}=(value)
          self.class.registered_settings[:#{setting.name}].raw_value = value
        end
      TEXT
    end

    def setting
      self.class.registered_settings[@name.to_sym]
    end

    def data_type=(data_type)
      @data_type = data_type.to_sym if data_type
    end

    def subtype=(subtype)
      @subtype = subtype.to_sym if subtype
    end

    def options
      @object_options ? calculate_object_options : @options
    end

    def options=(options)
      @options = options.split(' ')
    end

    attr_writer :object_options

    # <b>DEPRECATED:</b> Please use standard options instead.
    def calculate_object_options
      puts '[WARNING] ActiveSetting::Setting#object_options is deprecated'\
        ' as it poses a serious security risk and will be removed in future versions'

      objects, key, value = @object_options.split(' ')
      value = key if value.nil? || value == ''
      # TODO: Remove this method, as it uses eval !!!
      objects_from_collection(eval(objects), key, value)
    end

    def objects_from_collection(collection, key, value)
      collection.map { |o| [o.send(key), o.send(value)] }
    end

    def raw_value=(new)
      @value = nil
      @raw_value = new
    end

    def value
      v = raw_value
      v = default if raw_value.nil?

      # TODO: WHY IS the first line here
      return nil if v.nil?

      @value ||= build_value(v)
    end

    def self.convert_value(val, data_type)
      case data_type
      when :boolean then ![nil, false, 'false', 0, '0'].include?(val)
      when :integer then val.to_i
      when :string then val.to_s
      when :symbol then val.to_sym
      when :decimal then BigDecimal(val)
      else val
      end
    end

    private

    def build_value(v)
      case data_type
      when :hash
        hash_value(v)
      when :csv
        csv_value(v)
      else
        Setting.convert_value(v, data_type)
      end
    end

    def hash_value(v)
      chunks = v.split(',')
      chunks.map.with_object({}) do |val, h|
        key, subval   = val.split(':').map(&:strip)
        h[key.to_sym] = subval
      end
    end

    def csv_value(v)
      return v if v.empty? # e.g. default = []
      v.split(',').map(&:strip).map { |e| Setting.convert_value(e, subtype) }
    end
  end
end
