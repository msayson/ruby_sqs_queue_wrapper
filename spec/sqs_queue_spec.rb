RSpec.describe SqsQueue do
  let(:queue_url) { 'https://sqs.us-west-2.amazonaws.com/123456789012/QueueName' }
  let(:aws_region) { 'us-west-2' }

  let(:queue) do
    access_id_var = 'AccessIdEnvVar'
    secret_key_var = 'SecretKeyEnvVar'

    allow(ENV).to receive(:fetch).with(access_id_var).and_return('AccessId')
    allow(ENV).to receive(:fetch).with(secret_key_var).and_return('SecretKey')

    SqsQueue.new(
      queue_url: queue_url,
      aws_region: aws_region,
      access_id_var: access_id_var,
      secret_key_var: secret_key_var
    )
  end

  describe '#queue_url' do
    it 'should be read-only after initialization' do
      expect(queue.queue_url).to eq(queue_url)

      expect { queue.queue_url = 'NewValue' }.to raise_error(NoMethodError)
    end
  end

  describe '#send_message' do
    let(:message) { { MessageId: '1234', MessageBody: 'Hello' }.to_s }

    context 'when queue metadata and credentials are valid' do
      let(:sqs_message_id) { SecureRandom.uuid }

      let!(:stub_sqs) do
        allow_any_instance_of(Aws::SQS::Client)
          .to receive(:send_message)
          .with(queue_url: queue_url, message_body: message)
          .and_return(double(Seahorse::Client::Response))
      end

      it 'should return a non-nil response' do
        response = queue.send_message(message)
        expect(response).to_not be_nil
      end
    end

    shared_examples 'a query with invalid credentials' do
      it 'should raise a SqsQueue::AuthenticationError error' do
        allow_any_instance_of(Aws::SQS::Client)
          .to receive(:send_message)
          .with(queue_url: queue_url, message_body: message)
          .and_raise(sqs_error)

        expect { queue.send_message(message) }
          .to raise_error(SqsQueue::AuthenticationError)
      end
    end

    context 'when SQS raises an Aws::SQS::Errors::InvalidClientTokenId error' do
      it_behaves_like 'a query with invalid credentials' do
        let(:sqs_error) do
          Aws::SQS::Errors::InvalidClientTokenId.new(
            'RequestContext',
            'The security token included in the request is invalid.'
          )
        end
      end
    end

    context 'when SQS raises an Aws::SQS::Errors::SignatureDoesNotMatch error' do
      it_behaves_like 'a query with invalid credentials' do
        let(:sqs_error) do
          Aws::SQS::Errors::SignatureDoesNotMatch.new(
            'RequestContext',
            'ErrorMessage'
          )
        end
      end
    end
  end
end
