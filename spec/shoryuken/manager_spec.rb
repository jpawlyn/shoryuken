require 'spec_helper'

describe Shoryuken::Manager do
  let(:fetcher) { Shoryuken::Fetcher.new(manager) }
  let(:manager) { described_class.new }

  before do
    manager.fetcher = fetcher
  end

  describe 'Consuming messages', slow: :true do
    before do
      $received_messages = 0
    end

    class CoolWorker
      include Shoryuken::Worker

      shoryuken_options queue: 'shoryuken', auto_delete: true

      def perform(sqs_msg)
        $received_messages += 1
      end
    end

    it 'consumes a message' do
      Shoryuken::Client.queues('shoryuken').send_message('Be cool')

      manager.start

      10.times do
        break if $received_messages > 0
        sleep 1
      end

      manager.stop

      expect($received_messages).to eq 1
    end
  end
end
