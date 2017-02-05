# frozen_string_literal: true
class Shoes
  module Logger
    class Ruby < SimpleDelegator
      def initialize(device = STDERR)
        logger = ::Logger.new(device)
        logger.formatter = proc do |severity, _datetime, _progname, message|
          "%s: %s\n" % [severity, message]
        end
        super(logger)
      end
    end
  end
end

Shoes::Logger.register(:ruby, Shoes::Logger::Ruby)
