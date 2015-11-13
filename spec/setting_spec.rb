require 'spec_helper'

describe ActiveSetting::Setting, 'with types/casting' do
  it 'should handle basic types and casting' do
    s = ActiveSetting::Setting.new(data_type: :integer, raw_value: '6')
    s.value.should eq 6

    s = ActiveSetting::Setting.new(data_type: :decimal, raw_value: '7.6')
    s.value.should eq 7.6

    s = ActiveSetting::Setting.new(data_type: :symbol, raw_value: 'hello')
    s.value.should eq :hello

    s = ActiveSetting::Setting.new(raw_value: 'hello')
    s.value.should eq 'hello'
  end

  it 'should handle boolean types' do
    s = ActiveSetting::Setting.new(data_type: :boolean, raw_value: '0')
    s.value.should be false

    s = ActiveSetting::Setting.new(data_type: :boolean, raw_value: 'false')
    s.value.should be false

    s = ActiveSetting::Setting.new(data_type: :boolean, raw_value: '1')
    s.value.should be true

    s = ActiveSetting::Setting.new(data_type: :boolean, raw_value: 'true')
    s.value.should be true
  end

  it 'should handle multi value types including subvalue types and handle spacing' do
    s = ActiveSetting::Setting.new(data_type: :csv, subtype: :integer, raw_value: '1,2,3')
    s.value.should eq [1, 2, 3]

    s = ActiveSetting::Setting.new(data_type: :csv, subtype: :symbol, raw_value: 'first, second')
    s.value.should eq [:first, :second]

    s = ActiveSetting::Setting.new(data_type: :hash, raw_value: 'a:1 , b : 2')
    s.value.should eq(a: '1', b: '2')
  end
end

describe ActiveSetting::Setting, 'when having options' do
  it 'should format the options in the right type' do
    s = ActiveSetting::Setting.new(options: 'easy normal hard')
    s.options.should eq %w(easy normal hard)
  end

  it 'should format the options by key,value when object options' do
    first  = double(id: '1', name: 'First')
    second = double(id: '2', name: 'Second')
    s = ActiveSetting::Setting.new
    s.objects_from_collection([first, second], :name, :id).should eq [%w(First 1), %w(Second 2)]
  end

  it 'should not cache object options' do
    class Model
      attr_accessor :id, :name

      def self.objects
        @objects ||= []
      end

      def self.all
        objects
      end

      class << self
        attr_writer :objects
      end
    end

    s = ActiveSetting::Setting.new(object_options: 'Model.all id name')
    s.options.should eq []
    first = double(id: 1, name: 'First')
    Model.objects = [first]
    s.options.should eq [[1, 'First']]
  end
end
