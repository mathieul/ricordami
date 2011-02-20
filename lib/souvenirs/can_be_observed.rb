module Souvenirs
  module CanBeObserved
    extend ActiveSupport::Concern

    module ClassMethods
      attr_reader :published

      def publish_when(*events)
        not_supported = events - [:created, :updated, :deleted]
        raise EventNotSupported.new(not_supported.join(", ")) unless not_supported.empty?
        (@published ||= []).push(*events)
      end

      def observe(*events, &block)
        raise ArgumentError.new("no block given") unless block_given?
        callbacks = capture_callbacks_for(&block)
        patterns = events.map { |event| pattern_for_event(event) }
        puts "before psubscribe(#{patterns.inspect})"
        Souvenirs.driver.psubscribe(*patterns) do |sub|
          sub.pmessage do |pattern, channel, message|
            callbacks[pattern].call(channel, message) if callbacks.has_key?(pattern)
          end
        end
      end

      def stop_observing(*events)
        patterns = events.map { |event| pattern_for_event(event) }
        puts "before punsubscribe(#{patterns.inspect})"
        Souvenirs.driver.punsubscribe(*patterns)
      end

      def pattern_for_event(event)
        case event
        when :created then "#{root}.created"
        end
      end

      private

      def root
        @channel_root ||= self.to_s.underscore
      end

      def capture_callbacks_for(&block)
        callbacks = {}
        created = pattern_for_event(:created)
        callbacks.instance_eval do
          def was_created
            self[created] = Proc.new if block_given?
          end
        end
        block.call(callbacks)
        callbacks
      end
    end

    module InstanceMethods
      def save(opts = {})
        super(opts)
        Souvenirs.driver.publish(self.class.pattern_for_event(:created), :id => self.id)
      end
    end
  end
end
