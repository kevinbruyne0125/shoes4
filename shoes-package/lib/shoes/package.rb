# frozen_string_literal: true
class Shoes
  module Package
    def self.create_packager(config, package_type)
      require 'furoshiki/jar'
      require 'furoshiki/mac_app'
      require 'furoshiki/windows_app'

      case package_type
      when :jar
        ::Furoshiki::Jar.new(config)
      when :mac
        ::Furoshiki::MacApp.new(config)
      when :windows
        ::Furoshiki::WindowsApp.new(config)
      else
        abort "shoes: Don't know how to make #{package_type} packages"
      end
    end
  end
end
