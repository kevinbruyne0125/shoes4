# frozen_string_literal: true
class Shoes
  class Packager
    attr_reader :packages, :backend

    def initialize
      begin
        @backend = Shoes.backend_for(self)
        configure_gems
      rescue ArgumentError
        # Packaging unsupported by this backend
      end
      @packages = []
    end

    def parse!(args)
      options = OptionParser.new do |opts|
        opts.on('-p', '--package PACKAGE_TYPE', 'Package as BACKEND:PACKAGE') do |package|
          create_package("shoes", package)
        end
      end

      options.parse!(args)
    end

    def create_package(program_name, package)
      @packages << @backend.create_package(program_name, package)
    end

    def run(path)
      raise "Packaging unsupported by this backend" if @backend.nil?
      @backend.run(path)
    end

    def configure_gems
      @backend.gems = []
      return unless defined?(::Bundler)

      @backend.gems = ::Bundler.environment.specs.map(&:name) - ["shoes"]
    rescue Bundler::GemfileNotFound
      # Ok to be quiet since we didn't even have a Gemfile
    rescue => e
      Shoes.logger.error "Looking up gems for packaging failed:\n#{e.message}"
    end

    def help(program_name)
      return "" if @backend.nil?
      @backend.help(program_name)
    end
  end
end
