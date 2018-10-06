RSpec.describe SqsQueue do
  let(:queue_url) { 'https://sqs.us-west-2.amazonaws.com/123456789012/QueueName' }
  let(:queue) { SqsQueue.new(queue_url: queue_url) }

  describe '#queue_url' do
    it 'should be read-only after initialization' do
      expect(queue.queue_url).to eq(queue_url)

      expect { queue.queue_url = 'NewValue' }.to raise_error(NoMethodError)
    end
  end
end
