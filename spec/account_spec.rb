require './auto_load.rb'

RSpec.describe Account do
  OVERRIDABLE_FILENAME = 'spec/fixtures/account.yml'.freeze
  let(:console) { instance_double('Console', login: 'dima', password: 'qwerty', name: 'Dima', age: 25) }
  let(:current_subject) { described_class.new }
  before do
    stub_const("Account::FILE_PATH", OVERRIDABLE_FILENAME)
  end

  describe '#create' do
    after do
      File.delete(OVERRIDABLE_FILENAME) if File.exist?(OVERRIDABLE_FILENAME)
    end

    it 'create account set instance variables' do
      current_subject.create(current_subject)

    end

    it 'write to file Account instance' do
      current_subject.create(current_subject)
      expect(File.exist?(OVERRIDABLE_FILENAME)).to be true
      accounts = YAML.load_file(OVERRIDABLE_FILENAME)
      expect(accounts).to be_a Array
      expect(accounts.size).to be 1
      accounts.map { |account| expect(account).to be_a described_class }
    end
  end

  describe '#load' do

  end
end
