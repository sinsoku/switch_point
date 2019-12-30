# frozen_string_literal: true

module SwitchPoint
  module Middleware
    class DatabaseSelector
      class Resolver
        SEND_TO_REPLICA_DELAY = 2.seconds

        def self.convert_time_to_timestamp(time)
          time.to_i * 1000 + time.usec / 1000
        end

        def self.convert_timestamp_to_time(timestamp)
          timestamp ? Time.at(timestamp / 1000, (timestamp % 1000) * 1000) : Time.at(0)
        end

        def initialize(request, session: nil, delay: nil)
          @request = request
          @session = session || request.session
          @delay = delay || SEND_TO_REPLICA_DELAY
        end

        def select_database(&block)
          if read_from_primary?
            SwitchPoint.with_writable_all(&block)
          elsif reading_request?
            SwitchPoint.with_readonly_all(&block)
          else
            SwitchPoint.with_writable_all(&block).tap do
              session[:switch_point_last_write] = self.class.convert_time_to_timestamp(Time.now)
            end
          end
        end

        def last_write_timestamp
          self.class.convert_timestamp_to_time(session[:switch_point_last_write])
        end

        private

        attr_reader :request, :session, :delay

        def read_from_primary?
          Time.now - last_write_timestamp <= delay
        end

        def reading_request?
          request.get? || request.head?
        end
      end
    end
  end
end
