require 'shoes/common/common_methods'

class Shoes
  class Check
    include Shoes::CommonMethods

    attr_reader :parent
    attr_reader :blk
    attr_reader :gui

    def initialize(app, parent, blk = nil)
      @app    = app
      @parent = parent
      @blk    = blk

      @gui = Shoes.configuration.backend_for(self, @parent.gui, blk)
      @parent.add_child self

      click(&opts[:click]) if opts[:click]
    end

    def checked?
      @gui.checked?
    end

    def checked=(value)
      @gui.checked = value
    end

    def focus
      @gui.focus
    end

    def click
      @blk.call
    end
  end
end
