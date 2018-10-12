# SqsQueue

[<img src="https://travis-ci.org/msayson/ruby_sqs_queue_wrapper.svg?branch=master" alt="Build Status" />](https://travis-ci.org/msayson/ruby_sqs_queue_wrapper)

SqsQueue is a wrapper library for the AWS SQS SDK for Ruby, primarily written to test and verify behaviour.

This was written for educational purposes only and is not intended for production use.  This library is released under the MIT license, so feel free to reuse code samples for any purpose.

## Usage

Note: This gem has not been published, as it is currently intended for experimenting with the latest version of the AWS SDK.

```ruby
require 'sqs_queue'

# SqsQueue retrieves AWS credentials from environment variables specified by the caller.
#
# Eg. If you set access_id_var: 'AwsAccessIdEnvVar', SqsQueue will retrieve the access ID
# by calling ENV.fetch('AwsAccessIdEnvVar').
#
# This avoids storing credentials in source code while allowing multiple SQS queues to be
# initialized with different credentials.
queue = SqsQueue.new(
  queue_url: 'https://sqs.us-west-2.amazonaws.com/123456789012/YourQueueName',
  aws_region: 'us-west-2',
  access_id_var: 'AwsAccessIdEnvVar',
  secret_key_var: 'AwsSecretKeyEnvVar'
)

# Send a message with the given body to the SQS queue.
queue.send_message('Test message')

# Retrieve a single message from the queue if one exists.
message = queue.receive_single_message

# Retrieve up to max_count messages from the queue, where max_count is an Integer from 1 to 10.
max_count = 5
messages = queue.receive_messages(max_count)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies.

To run unit tests, run `rake spec`. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To run integration tests against a live SQS queue, create a YAML file named config/local_env_integ.yml with the values updated to match your SQS queue and AWS credentials, and run `rake integ`.

Example config/local_env_integ.yml contents:
```yaml
SqsQueueIntegTests_QueueUrl: 'YourQueueUrl'
SqsQueueIntegTests_QueueRegion: 'YourAwsRegion'
SqsQueueIntegTests_AccessId: 'YourAwsAccessId'
SqsQueueIntegTests_SecretKey: 'YourAwsSecretKey'
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
