RSpec.describe Nats::Pain::Connection do
  describe '.new' do
    let(:opts) { {} }
    subject { described_class.new(opts) }

    it 'should create connection' do
      expect { subject }.not_to raise_exception
    end
  end

  describe '.current' do
    subject { described_class.current }
    let(:topic) { 'topic' }
    let(:message) { '{"a": "123"}' }

    it 'should return connection pool' do
      expect(subject).to be_an_instance_of(described_class)
    end

    it 'should publish nats event' do
      expect_any_instance_of(NatsListener::Client).to receive(:publish).with(topic, message).and_return(true)
      subject.nats_pool&.with { |conn| conn.publish(topic, message) }
    end

    describe 'with disabled nats' do
      let(:opts) { { nats_enabled: false } }
      it 'should not fail' do
        expect { subject.nats_pool&.with { |conn| conn.publish(topic, message) } }.not_to raise_exception
      end
    end
  end
end
