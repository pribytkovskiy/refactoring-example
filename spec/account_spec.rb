RSpec.describe Storage do
  it 'write to file Account instance' do
    current_subject.send(:create)
    expect(File.exist?(OVERRIDABLE_FILENAME)).to be true
    accounts = YAML.load_file(OVERRIDABLE_FILENAME)
    expect(accounts).to be_a Array
    expect(accounts.size).to be 1
    accounts.map { |account| expect(account).to be_a described_class }
  end
end