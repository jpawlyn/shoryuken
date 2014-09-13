module Shoryuken
  class Launcher
    include Celluloid
    include Util

    trap_exit :actor_died

    def initialize
      @manager = Shoryuken::Manager.new_link
      @fetcher = Shoryuken::Fetcher.new_link(@manager)

      @done = false

      @manager.fetcher = @fetcher
    end

    def stop
      watchdog('Launcher#stop') do
        @done = true
        @fetcher.terminate if @fetcher.alive?

        @manager.async.stop
      end
    end

    def run
      watchdog('Launcher#run') do
        @manager.async.start
      end
    end

    def actor_died(actor, reason)
      return if @done
      Shoryuken.logger.warn('Shoryuken died due to the following error, cannot recover, process exiting')
      exit(1)
    end
  end
end
