class Shoes
  module Swt
    class FittedTextLayout
      attr_reader :layout, :left, :top

      def initialize(layout, left, top)
        @layout = layout
        @left = left
        @top = top
      end

      def get_location(cursor)
        @layout.get_location(cursor, false)
      end

      def text
        @layout.text
      end

      def style_from(default_text_styles, opts)
        layout.justify = opts[:justify]
        layout.spacing = (opts[:leading] || 4)
        layout.alignment = case opts[:align]
                             when 'center'; ::Swt::SWT::CENTER
                             when 'right'; ::Swt::SWT::RIGHT
                             else ::Swt::SWT::LEFT
                           end

        set_style(TextStyleFactory.apply_styles(default_text_styles, opts))
      end

      def set_style(styles, range=nil)
        range ||= 0..(text.length - 1)
        font_style = styles[:font_detail]
        font = TextFontFactory.create_font(font_style[:name], font_style[:size], font_style[:styles])
        style = TextStyleFactory.create_style(font, styles[:fg], styles[:bg], styles)
        layout.set_style(style, range.first, range.last)
      end

      def draw(graphics_context)
        layout.draw(graphics_context, left, top)
      end
    end
  end
end
