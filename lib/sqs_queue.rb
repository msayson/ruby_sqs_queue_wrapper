# A wrapper class for AWS SQS queues.
#
# See https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/SQS/Client.html
# for the AWS Ruby SDK documentation for SQS.
class SqsQueue
  attr_reader :queue_url

  # @param options [Hash] queue initialization options.
  # @option options [String] queue_url URL to the AWS SQS queue.
  def initialize(options)
    @queue_url = options.fetch(:queue_url)
  end
end
