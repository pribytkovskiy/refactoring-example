require './auto_load.rb'

RSpec.describe Account do
  OVERRIDABLE_FILENAME = 'spec/fixtures/account.yml'.freeze
  let(:console) { instance_double('Console', login: 'dima', password: 'qwerty', name: 'Dima', age: 25) }
  let(:current_subject) { described_class.new (console) }

  describe '#create' do
    after do
      File.delete(OVERRIDABLE_FILENAME) if File.exist?(OVERRIDABLE_FILENAME)
    end

    context 'create file' do
      it 'write to file Account instance' do
        stub_const("Account::FILE_PATH", OVERRIDABLE_FILENAME)
        current_subject.save
        expect(File.exist?(OVERRIDABLE_FILENAME)).to be true
        accounts = YAML.load_file(OVERRIDABLE_FILENAME)
        expect(accounts).to be_a Array
        expect(accounts.size).to be 1
        accounts.map { |account| expect(account).to be_a described_class }
      end

      it 'create account if input is create' do

      end

      it 'load account if input is load' do
   
      end

      it 'leave app if input is exit or some another word' do
 
      end
    end

    context 'with correct outout' do
      it do

      end
    end
  end
end