class Shoes
  class Link < Span
    attr_reader :app, :parent, :gui, :blk

    DEFAULT_OPTS = { underline: true, fg: ::Shoes::COLORS[:blue] }

    def initialize(app, parent, texts, opts={}, &blk)
      @app = app
      @parent = parent
      setup_block(blk, opts)

      opts = DEFAULT_OPTS.merge(opts)
      @gui = Shoes.backend_for(self, opts)

      super texts, opts
    end

    def setup_block(blk, opts)
      if blk
        @blk = blk
      elsif opts.include?(:click)
        # Slightly awkward, but we need App, not InternalApp, to call visit
        @blk = Proc.new { app.app.visit(opts[:click]) }
      end
    end

  end
end
