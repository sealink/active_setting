require 'bigdecimal'

module ActiveSetting
  class Setting # < ActiveRecord::Base
    attr_accessor :name, :data_type, :subtype, :options, :description, :exists, :category, :raw_value, :default

    def initialize(attr = {})
      attr.each do |key,value|
        setter = (key.to_s + '=').to_sym
        send(setter, value) if methods.include?(setter)
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

    def options=(options)
      @options = options.split(' ')
    end

    def object_options=(oo)
      objects, key, value = oo.split(' ')
      value = key if value.nil? || value == ''
      objects_from_collection(eval(objects), key, value)
    end

    def objects_from_collection(collection, key, value)
      @options = collection.map{|o| [o.send(key), o.send(value)]}
    end

    def options
      @options || (eval(setting.options) if setting && !setting.options.blank?)
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
      v = raw_value || default

      # TODO: WHY IS the first line here
      return nil if v.nil?

      case data_type
      when :array
        YAML::load(v)
      when :hash
        chunks = v.split(',')
        chunks.inject({}) do |h, val|
          key, subval = val.split(':')
          h[key.strip.to_sym] = subval.strip
          h
        end
      when :csv
        return v if v.empty? # e.g. default = []
        v.split(',').map(&:strip).map{|e| Setting.convert_value(e, subtype) }
      else
        Setting.convert_value(v, data_type)
      end
    end

    #def value=(newval)
    #  newval = newval.join(',') if data_type == 'csv' && newval.is_a?(Array)
    #  self.raw_value = newval
    #end
  end
end
