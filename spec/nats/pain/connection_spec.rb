RSpec.describe Nats::Pain::Connection do
  describe '.new' do
    subject { described_class.new }

    it 'should create connection' do
      expect { subject }.not_to raise_exception
    end
  end

  describe '.current' do
    subject { described_class.current }

    it 'should return connection pool' do
      expect(subject).to be_an_instance_of(ConnectionPool)
    end
  end
end