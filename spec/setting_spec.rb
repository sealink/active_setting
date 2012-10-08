require 'spec_helper'
require 'bigdecimal'
describe ActiveSetting::Setting do
  it 'should handle basic types and casting' do
    s = ActiveSetting::Setting.new(:data_type => :integer, :raw_value => '6')
    s.value.should == 6

    s = ActiveSetting::Setting.new(:data_type => :decimal, :raw_value => '7.6')
    s.value.should == 7.6

    s = ActiveSetting::Setting.new(:data_type => :symbol, :raw_value => 'hello')
    s.value.should == :hello

    s = ActiveSetting::Setting.new(:raw_value => 'hello')
    s.value.should == 'hello'
  end

  it 'should handle boolean types' do
    s = ActiveSetting::Setting.new(:data_type => :boolean, :raw_value => '0')
    s.value.should be_false

    s = ActiveSetting::Setting.new(:data_type => :boolean, :raw_value => 'false')
    s.value.should be_false

    s = ActiveSetting::Setting.new(:data_type => :boolean, :raw_value => '1')
    s.value.should be_true

    s = ActiveSetting::Setting.new(:data_type => :boolean, :raw_value => 'true')
    s.value.should be_true
  end

  it 'should handle multi value types including subvalue types and handle spacing' do
    s = ActiveSetting::Setting.new(:data_type => :csv, :subtype => :integer, :raw_value => '1,2,3')
    s.value.should == [1, 2, 3]

    s = ActiveSetting::Setting.new(:data_type => :csv, :subtype => :symbol, :raw_value => 'first, second')
    s.value.should == [:first, :second]

    s = ActiveSetting::Setting.new(:data_type => :hash, :raw_value => 'a:1 , b : 2')
    s.value.should == {a: '1', b: '2'}
  end

  it 'should parse a settings file to get settings' do
    ActiveSetting::Setting.config_filename = 'spec/settings.yml'
    hash = ActiveSetting::Setting.settings_hash
    hash.keys.should == [:maximum_percent]
    s = ActiveSetting::Setting.new(hash.values.first)
    puts s.inspect
    s.raw_value = 60
    s.value.should == 60
  end
end
