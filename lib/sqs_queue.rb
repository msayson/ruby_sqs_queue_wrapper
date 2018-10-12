require 'aws-sdk-sqs'

# A wrapper class for AWS SQS queues.
#
# See https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/SQS/Client.html
# for the AWS Ruby SDK documentation for SQS.
class SqsQueue
  attr_reader :queue_url

  class AuthenticationError < StandardError; end

  # Initialize a SQS queue with identifying metadata and credentials.
  #
  # @param options [Hash] queue initialization options.
  # @option options [String] queue_url URL to the AWS SQS queue.
  # @option options [String] aws_region AWS region where the SQS queue resides.
  # @option options [String] access_id_var name of the environment variable
  #   storing the access key ID to use when querying SQS.
  # @option options [String] secret_key_var name of the environment variable
  #   storing the secret key to use when querying SQS.
  def initialize(options)
    @queue_url = options.fetch(:queue_url)

    @client = Aws::SQS::Client.new(
      region: options.fetch(:aws_region),
      access_key_id: ENV.fetch(options.fetch(:access_id_var)),
      secret_access_key: ENV.fetch(options.fetch(:secret_key_var))
    )
  end

  # Send a message to the SQS queue.
  #
  # @param message [String] the message to send.
  # @return [Aws::SQS::Types::Message, nil] an SQS message, or nil if none was found.
  # @raise [SqsQueue::AuthenticationError] error raised if credentials are invalid.
  def send_message(message)
    run_authenticated_query do
      @client.send_message(
        queue_url: @queue_url,
        message_body: message
      )
    end
  end

  # Retrieve a single message from the SQS queue.
  #
  # @return [Seahorse::Client::Response, nil] a SQS message, or nil if none were found.
  # @raise [SqsQueue::AuthenticationError] error raised if credentials are invalid.
  def receive_single_message
    receive_messages(1).first
  end

  # Retrieve messages from the SQS queue.
  #
  # @param max_count [Integer] the maximum number of SQS messages to retrieve.
  # @return [Aws::Xml::DefaultList<Aws::SQS::Types::Message>] a collection of up to max_count SQS messages.
  # @raise [ArgumentError] error raised if parameters are invalid.
  # @raise [SqsQueue::AuthenticationError] error raised if credentials are invalid.
  def receive_messages(max_count)
    validate_receive_messages_params(max_count)

    run_authenticated_query do
      response = @client.receive_message(
        queue_url: @queue_url,
        max_number_of_messages: max_count
      )
      response.messages
    end
  end

  private

  # Run the input block and raise an SqsQueue::AuthenticationError
  # if receive AWS errors related to invalid credentials.
  #
  # @yield Runs and returns the result of the input code block.
  # @raise [SqsQueue::AuthenticationError] error raised if credentials are invalid.
  def run_authenticated_query
    yield
  rescue Aws::SQS::Errors::InvalidClientTokenId, Aws::SQS::Errors::SignatureDoesNotMatch
    raise AuthenticationError, 'Authorization error retrieving messages from SQS'
  end

  # Validate SqsQueue#receive_messages parameters.
  # See https://docs.aws.amazon.com/sdkforruby/api/Aws/SQS/Client.html#receive_message-instance_method
  #
  # @param max_count [Integer] the maximum number of SQS messages to retrieve.
  # @raise [ArgumentError] error raised if inputs are invalid.
  def validate_receive_messages_params(max_count)
    return if max_count.is_a?(Integer) && (1..10).cover?(max_count)

    raise(
      ArgumentError,
      "SqsQueue#receive_messages: max_count must be an Integer between 1 and 10, received #{max_count}"
    )
  end
end
