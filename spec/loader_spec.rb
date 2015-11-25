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
      specify { expect(setting).to be_a ActiveSetting::Setting }
      specify { expect(setting.name).to eq :maximum_percent }
      specify { expect(setting.category).to eq 'general_category' }
      specify { expect(setting.data_type).to eq :integer }
      specify { expect(setting.default).to eq 50 }
      specify { expect(setting.description).to eq 'The minimum percentage to pass' }
      specify { expect(setting.options).to be_nil }
      specify { expect(setting.value).to eq 50 }
    end

    context 'difficulty setting' do
      let(:setting) { hash[:difficulty] }
      specify { expect(setting).to be_a ActiveSetting::Setting }
      specify { expect(setting.name).to eq :difficulty }
      specify { expect(setting.category).to eq 'general_category' }
      specify { expect(setting.options).to eq %w(easy normal hard) }
      specify { expect(setting.value).to be_nil }
    end

    context 'product ids setting' do
      let(:setting) { hash[:product_ids] }
      specify { expect(setting).to be_a ActiveSetting::Setting }
      specify { expect(setting.name).to eq :product_ids }
      specify { expect(setting.category).to eq 'general_category' }
      specify { expect(setting.data_type).to eq :csv }
      specify { expect(setting.subtype).to eq :integer }
      specify { expect(setting.value).to eq [1, 2, 3] }
    end

    context 'testing setting' do
      let(:setting) { hash[:testing] }
      specify { expect(setting).to be_a ActiveSetting::Setting }
      specify { expect(setting.name).to eq :testing }
      specify { expect(setting.category).to eq 'general_category' }
      specify { expect(setting.data_type).to eq :boolean }
      specify { expect(setting.value).to eq true }
    end

    context 'when external settings are defined' do
      before do
        ActiveSetting::Loader.register_external_setting(
          :externally_defined,
          type:    'string',
          default: 'external setting'
        )
      end

      let(:setting) { hash[:externally_defined] }
      specify { expect(setting).to be_a ActiveSetting::Setting }
      specify { expect(setting.name).to eq :externally_defined }
      specify { expect(setting.category).to eq 'External' }
      specify { expect(setting.data_type).to eq :string }
      specify { expect(setting.value).to eq 'external setting' }
    end
  end
end
