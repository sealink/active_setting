require 'spec_helper'

describe ActiveSetting::Loader do
  let(:config_filename) { 'spec/settings.yml' }

  it 'should parse a settings file to get settings' do
    ActiveSetting::Loader.load_settings(config_filename)
    settings = ActiveSetting::Setting.registered_settings
    settings.keys.should include :maximum_percent
  end

  context 'when building a settings hash from the settings file' do
    let(:hash) { ActiveSetting::Loader.build_hash(config_filename) }
    let(:source) { YAML.load(File.read(config_filename))['settings'] }

    context 'maximum percent setting' do
      let(:setting) { hash[:maximum_percent] }
      specify do expect(setting).to be_a ActiveSetting::Setting end
      specify do expect(setting.name).to eq :maximum_percent end
      specify do expect(setting.category).to eq 'general_category' end
      specify do expect(setting.data_type).to eq :integer end
      specify do expect(setting.default).to eq 50 end
      specify do expect(setting.description).to eq 'The minimum percentage to pass' end
      specify do expect(setting.options).to be_nil end
      specify { expect(setting.value).to eq 50 }
    end

    context 'difficulty setting' do
      let(:setting) { hash[:difficulty] }
      specify do expect(setting).to be_a ActiveSetting::Setting end
      specify do expect(setting.name).to eq :difficulty end
      specify do expect(setting.category).to eq 'general_category' end
      specify do expect(setting.options).to eq %w(easy normal hard) end
      specify { expect(setting.value).to be_nil }
    end

    context 'product ids setting' do
      let(:setting) { hash[:product_ids] }
      specify do expect(setting).to be_a ActiveSetting::Setting end
      specify do expect(setting.name).to eq :product_ids end
      specify do expect(setting.category).to eq 'general_category' end
      specify do expect(setting.data_type).to eq :csv end
      specify do expect(setting.subtype).to eq :integer end
      specify { expect(setting.value).to eq [1, 2, 3] }
    end

    context 'testing setting' do
      let(:setting) { hash[:testing] }
      specify do expect(setting).to be_a ActiveSetting::Setting end
      specify do expect(setting.name).to eq :testing end
      specify do expect(setting.category).to eq 'general_category' end
      specify do expect(setting.data_type).to eq :boolean end
      specify { expect(setting.value).to eq true }
    end
  end
end
