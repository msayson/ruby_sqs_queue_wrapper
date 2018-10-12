require 'shared_examples/authenticated_sqs_query'

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

    it_behaves_like 'an authenticated SQS query' do
      let(:client_method) { :send_message }
      let(:client_method_params) { { queue_url: queue_url, message_body: message } }
      let(:local_method) { :send_message }
      let(:local_params) { message }
    end
  end

  describe '#receive_single_message' do
    context 'when the SQS queue is empty' do
      let!(:stub_sqs) do
        allow_any_instance_of(Aws::SQS::Client)
          .to receive(:receive_message)
          .with(queue_url: queue_url, max_number_of_messages: 1)
          .and_return(double('SQS response', messages: Aws::Xml::DefaultList.new))
      end

      it 'should return nil' do
        expect(queue.receive_single_message).to be_nil
      end
    end

    context 'when there are messages in the SQS queue' do
      let(:messages) do
        (1..2).map { Aws::SQS::Types::Message.new(message_id: SecureRandom.uuid) }
      end

      let!(:stub_sqs) do
        allow_any_instance_of(Aws::SQS::Client)
          .to receive(:receive_message)
          .with(queue_url: queue_url, max_number_of_messages: 1)
          .and_return(double('SQS response', messages: Aws::Xml::DefaultList.new(messages)))
      end

      it 'should return a SQS message' do
        expect(queue.receive_single_message).to be_a(Aws::SQS::Types::Message)
      end
    end

    it_behaves_like 'an authenticated SQS query' do
      let(:client_method) { :receive_message }
      let(:client_method_params) { { queue_url: queue_url, max_number_of_messages: 1 } }
      let(:local_method) { :receive_single_message }
      let(:local_params) { nil }
    end
  end

  describe '#receive_messages' do
    let(:valid_max_count) { 2 }

    context 'when parameters are valid' do
      context 'when the SQS queue is empty' do
        let!(:stub_sqs) do
          allow_any_instance_of(Aws::SQS::Client)
            .to receive(:receive_message)
            .with(queue_url: queue_url, max_number_of_messages: valid_max_count)
            .and_return(double('SQS response', messages: Aws::Xml::DefaultList.new))
        end

        it 'should return an empty collection' do
          expect(queue.receive_messages(valid_max_count)).to be_empty
        end
      end

      context 'when there are messages in the SQS queue' do
        let(:messages) do
          (1..2).map { Aws::SQS::Types::Message.new(message_id: SecureRandom.uuid) }
        end

        let!(:stub_sqs) do
          allow_any_instance_of(Aws::SQS::Client)
            .to receive(:receive_message)
            .with(queue_url: queue_url, max_number_of_messages: valid_max_count)
            .and_return(double('SQS response', messages: Aws::Xml::DefaultList.new(messages)))
        end

        it 'should return a non-empty collection of SQS messages' do
          response = queue.receive_messages(valid_max_count)
          expect(response.length).to eq(messages.length)
          expect(response.first).to be_a(Aws::SQS::Types::Message)
        end
      end
    end

    context 'when parameters are invalid' do
      it 'should raise an ArgumentError' do
        [nil, '', 0, 11].each do |invalid_max_count|
          expect { queue.receive_messages(invalid_max_count) }
            .to raise_error(ArgumentError)
        end
      end
    end

    it_behaves_like 'an authenticated SQS query' do
      let(:client_method) { :receive_message }
      let(:client_method_params) { { queue_url: queue_url, max_number_of_messages: valid_max_count } }
      let(:local_method) { :receive_messages }
      let(:local_params) { valid_max_count }
    end
  end
end
