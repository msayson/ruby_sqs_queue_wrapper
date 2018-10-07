RSpec.describe SqsQueue do
  let(:queue_url_env_var) { 'SqsQueueIntegTests_QueueUrl' }
  let(:queue_region_env_var) { 'SqsQueueIntegTests_QueueRegion' }
  let(:access_id_env_var) { 'SqsQueueIntegTests_AccessId' }
  let(:secret_key_env_var) { 'SqsQueueIntegTests_SecretKey' }

  let(:queue_url) { ENV.fetch(queue_url_env_var) }
  let(:aws_region) { ENV.fetch(queue_region_env_var) }

  let(:queue) do
    SqsQueue.new(
      queue_url: queue_url,
      aws_region: aws_region,
      access_id_var: access_id_env_var,
      secret_key_var: secret_key_env_var
    )
  end

  describe '#send_message' do
    let(:message) { { MessageId: '1234', MessageBody: 'Hello' }.to_s }

    context 'when valid SQS metadata and credentials are provided' do
      it 'should succeed without errors' do
        response = queue.send_message(message)
        expect(response.message_id).to_not be_nil
      end
    end

    shared_examples 'a query with metadata from invalid ENV values' do
      it 'should raise an error' do
        ENV[env_var] = 'InvalidValue'

        expect { queue.send_message(message) }
          .to raise_error(expected_error)
      end
    end

    context 'when the access id is invalid' do
      it_behaves_like 'a query with metadata from invalid ENV values' do
        let(:env_var) { access_id_env_var }
        let(:expected_error) { SqsQueue::AuthenticationError }
      end
    end

    context 'when the secret key is invalid' do
      it_behaves_like 'a query with metadata from invalid ENV values' do
        let(:env_var) { secret_key_env_var }
        let(:expected_error) { SqsQueue::AuthenticationError }
      end
    end

    context 'when the queue does not exist' do
      it_behaves_like 'a query with metadata from invalid ENV values' do
        let(:env_var) { queue_url_env_var }
        let(:expected_error) { ArgumentError }
      end
    end
  end
end
