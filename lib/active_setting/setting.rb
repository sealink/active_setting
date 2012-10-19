require 'bigdecimal'

module ActiveSetting
  class Setting # < ActiveRecord::Base
    attr_accessor :name, :description, :category, :raw_value, :default
    attr_reader :data_type, :subtype, :options

    def initialize(attr = {})
      attr.each do |key,value|
        setter = "#{key}="
        send(setter, value) if respond_to?(setter)
      end
    end

    def self.register(name, options)
      self.new(options.merge(:name => name)).register
    end

    def register
      @@registered_settings ||= {}
      @@registered_settings[name.to_sym] = self
      Setting.define_shortcut_method(self)
      self
    end

    def self.define_shortcut_method(setting)
      class_eval <<-TEXT 
        def self.#{setting.name}
          @@registered_settings[:#{setting.name}].value
        end
        def self.#{setting.name}=(value)
          @@registered_settings[:#{setting.name}].raw_value = value
        end
      TEXT
    end

    def self.registered_settings
      @@registered_settings
    end

    def setting
      @@registered_settings[@name.to_sym]
    end

    def data_type=(data_type)
      @data_type = data_type.to_sym if data_type
    end

    def subtype=(subtype)
      @subtype = subtype.to_sym if subtype
    end

    def options=(options)
      @options = options.split(' ')
    end

    def object_options=(oo)
      objects, key, value = oo.split(' ')
      value = key if value.nil? || value == ''
      @options = objects_from_collection(eval(objects), key, value)
    end

    def objects_from_collection(collection, key, value)
      collection.map{|o| [o.send(key), o.send(value)]}
    end

    def raw_value=(new)
      @value = nil
      @raw_value = new
    end

    def value
      v = raw_value || default

      # TODO: WHY IS the first line here
      return nil if v.nil?

      @value ||= case data_type
      when :hash
        chunks = v.split(',')
        chunks.inject({}) do |h, val|
          key, subval = val.split(':').map(&:strip)
          h[key.to_sym] = subval
          h
        end
      when :csv
        return v if v.empty? # e.g. default = []
        v.split(',').map(&:strip).map{|e| Setting.convert_value(e, subtype) }
      else
        Setting.convert_value(v, data_type)
      end
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
  end
end
