RSpec.shared_examples 'an authenticated SQS query' do
  shared_examples 'a query with invalid credentials' do
    it 'should raise a SqsQueue::AuthenticationError error' do
      allow_any_instance_of(Aws::SQS::Client)
        .to receive(client_method)
        .with(client_method_params)
        .and_raise(sqs_error)

      expect { local_params ? queue.send(local_method, local_params) : queue.send(local_method) }
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
