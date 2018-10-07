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
  # @return [Seahorse::Client::Response] the response received from SQS.
  def send_message(message)
    @client.send_message(
      queue_url: @queue_url,
      message_body: message
    )
  rescue Aws::SQS::Errors::InvalidClientTokenId, Aws::SQS::Errors::SignatureDoesNotMatch
    raise AuthenticationError, 'Authorization error sending a message to SQS'
  end
end
