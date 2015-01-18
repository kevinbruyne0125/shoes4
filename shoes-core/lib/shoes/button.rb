class Shoes
  class Button
    include Common::Initialization
    include Common::UIElement
    include Common::Style
    include Common::Clickable

    attr_reader :app, :parent, :dimensions, :gui

    style_with :click, :common_styles, :dimensions, :state, :text

    def before_initialize(styles, text)
      styles[:text] = text
    end

    def create_dimensions(*_)
      @dimensions = Dimensions.new @parent, @style
    end

    def focus
      @gui.focus
    end

    def state=(value)
      style(state: value)
      @gui.enabled value.nil?
    end
  end
end
