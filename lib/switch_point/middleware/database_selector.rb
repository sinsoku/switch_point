# frozen_string_literal: true

require 'switch_point/middleware/database_selector/resolver'
require 'action_dispatch'

module SwitchPoint
  module Middleware
    class DatabaseSelector
      def initialize(app, delay: nil)
        @app = app
        @delay = delay
      end

      def call(env)
        request = ActionDispatch::Request.new(env)
        resolver = Resolver.new(request, delay: @delay)

        resolver.select_database { @app.call(env) }
      end
    end
  end
end
