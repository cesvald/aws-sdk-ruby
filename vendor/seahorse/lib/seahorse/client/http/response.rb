require 'stringio'

module Seahorse
  module Client
    module Http
      class Response

        # @option options [Integer] :status_code (nil)
        # @option options [Headers] :headers (Headers.new)
        # @option options [IO] :body (StringIO.new)
        def initialize(options = {})
          @status_code = nil
          @headers = options[:headers] || Headers.new
          @body = options[:body] || PlainStringIO.new
        end

        # @return [Integer, nil]
        attr_accessor :status_code

        # @return [Headers]
        attr_accessor :headers

        # @return [IO]
        attr_accessor :body

        # @return [String]
        def body_contents
          contents = body.read
          body.rewind
          contents
        end

      end
    end
  end
end
