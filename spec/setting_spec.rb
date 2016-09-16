require 'spec_helper'

describe ActiveSetting::Setting, 'with types/casting' do
  subject { ActiveSetting::Setting.new(data_type: data_type, raw_value: raw_value).value }

  context 'when integer 6' do
    let(:data_type) { :integer }
    let(:raw_value) { '6' }
    it { is_expected.to eq 6 }
  end

  context 'when decimal 7.6' do
    let(:data_type) { :decimal }
    let(:raw_value) { '7.6' }
    it { is_expected.to eq 7.6 }
  end

  context 'when symbol hello' do
    let(:data_type) { :symbol }
    let(:raw_value) { 'hello' }
    it { is_expected.to eq :hello }
  end

  context 'when unspecified hello' do
    let(:data_type) { nil }
    let(:raw_value) { 'hello' }
    it { is_expected.to eq 'hello' }
  end

  context 'when boolean' do
    let(:data_type) { :boolean }

    context 'when 0' do
      let(:raw_value) { '0' }
      it { is_expected.to be false }
    end

    context 'when false' do
      let(:raw_value) { 'false' }
      it { is_expected.to be false }
    end

    context 'when boolean false' do
      let(:raw_value) { false }
      it { is_expected.to be false }
    end

    context 'when 1' do
      let(:raw_value) { '1' }
      it { is_expected.to be true }
    end

    context 'when true' do
      let(:raw_value) { 'true' }
      it { is_expected.to be true }
    end

    context 'when boolean true' do
      let(:raw_value) { true }
      it { is_expected.to be true }
    end
  end

  context 'when csv' do
    subject { ActiveSetting::Setting.new(default: [], data_type: data_type, subtype: subtype, raw_value: raw_value).value }
    let(:data_type) { :csv }
    context 'when array of integers' do
      let(:subtype) { :integer }
      let(:raw_value) { '1,2,3' }
      it { is_expected.to eq [1, 2, 3] }

      context 'when no value, so default' do
        let(:raw_value) { nil }
        it { is_expected.to eq [] }
      end
    end

    context 'when array of symbols' do
      let(:subtype) { :symbol }
      let(:raw_value) { 'first, second' } # deliberate spacing
      it { is_expected.to eq [:first, :second] }
    end
  end

  context 'when hash' do
    let(:data_type) { :hash }
    let(:raw_value) { 'a:1 , b : 2' } # deliberate spacing
    it { is_expected.to eq(a: '1', b: '2') }
  end
end

describe ActiveSetting::Setting, 'when having options' do
  context 'with regular options' do
    subject { ActiveSetting::Setting.new(options: 'easy normal hard').options }
    it { is_expected.to eq %w(easy normal hard) }
  end

  context 'calculating objects from collection' do
    let(:first) { double(id: '1', name: 'First') }
    let(:second) { double(id: '2', name: 'Second') }
    subject { ActiveSetting::Setting.new.objects_from_collection([first, second], :name, :id) }
    it { is_expected.to eq [%w(First 1), %w(Second 2)] }
  end

  context 'with object options' do
    before do
      stub_const 'Model', double(all: objects)
    end

    subject { ActiveSetting::Setting.new(object_options: 'Model.all id name').options }
    let(:objects) { [] }
    it { is_expected.to eq [] }

    context 'when objects exist' do
      let(:objects) { [double(id: 1, name: 'First')] }
      it { is_expected.to eq [[1, 'First']] }
    end
  end
end
