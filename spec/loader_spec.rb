require 'spec_helper'

describe ActiveSetting::Loader do
  it 'should parse a settings file to get settings' do
    ActiveSetting::Loader.load_settings('spec/settings.yml')
    settings = ActiveSetting::Setting.registered_settings
    settings.keys.should include :maximum_percent
  end
end

