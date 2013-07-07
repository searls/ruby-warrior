module Deciders
  module Advisors
    class Advisor
      attr_reader :brain, :body

      def call
        raise 'Abstract Method'
      end

      def suggest(brain, body)
        @brain = brain
        @body = body
        call
      end
    end
  end
end
