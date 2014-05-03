class Shoes
  class Dimension
    attr_writer :extent
    attr_reader :parent
    attr_accessor :absolute_start
    protected :parent # we shall not mess with parent,see #495

    # in case you wonder about the -1... it is used to adjust the right and
    # bottom values. Because right is not left + width but rather left + width -1
    # Let me give you an example:
    # Say left is 20 and we have a width of 100 then the right must be 119,
    # because you have to take pixel number 20 into account so 20..119 is 100
    # while 20..120 is 101. E.g.:
    # (20..119).size => 100
    PIXEL_COUNTING_ADJUSTMENT = -1

    def initialize(parent = nil, start_as_center = false)
      @parent          = parent
      @start_as_center = start_as_center
    end

    def start
      value = @start || relative_to_parent_start
      if start_as_center?
        adjust_start_for_center(value)
      else
        value
      end
    end

    def end
      @end || relative_to_parent_end
    end

    def extent
      result = @extent
      if @parent
        result = calculate_relative(result) if is_relative?(result)
        result = calculate_negative(result) if is_negative?(result)
      end
      result
    end

    def extent=(value)
      @extent = value
      @extent = parse_from_string @extent if is_string? @extent
      @extent
    end

    def absolute_end
      return absolute_start if extent.nil?
      absolute_start + extent + PIXEL_COUNTING_ADJUSTMENT
    end

    def element_extent
      my_extent = extent
      if my_extent.nil?
        nil
      else
        extent - (margin_start + margin_end)
      end
    end
    
    def element_extent=(value)
      if value.nil?
        self.extent = nil
      else
        self.extent = margin_start + value + margin_end
      end
    end

    def element_start
      return nil if absolute_start.nil?
      absolute_start + margin_start + displace_start
    end

    def element_end
      return nil if element_start.nil? || element_extent.nil?
      element_start + element_extent + PIXEL_COUNTING_ADJUSTMENT
    end

    def absolute_start_position?
      not @start.nil?
    end

    def absolute_end_position?
      not @end.nil?
    end

    def absolute_position?
      absolute_start_position? || absolute_end_position?
    end

    def positioned?
      absolute_start
    end

    def in_bounds?(value)
      (absolute_start <= value) && (value <= absolute_end)
    end

    # For... reasons it is important to have the value of the instance variable
    # set to nil if it's not modified and then return a default value on the
    # getter... reason being that for ParentDimensions we need to be able to
    # figure out if a value has been modified or if we should consulte the
    # parent value - see ParentDimension implementation
    [:margin_start, :margin_end, :displace_start].each do |method|
      define_method method do
        instance_variable_name = '@' + method.to_s
        instance_variable_get(instance_variable_name) || 0
      end
    end

    def self.define_int_parsing_writer(name)
      define_method "#{name}=" do |value|
        instance_variable_set("@#{name}", parse_int_value(value))
      end
    end

    %w(start end margin_start margin_end displace_start).each do |method|
      define_int_parsing_writer method
    end

    private
    def is_relative?(result)
      result.is_a?(Float)
    end

    def calculate_relative(result)
      (result * @parent.element_extent).to_i
    end

    def is_string?(result)
      result.is_a?(String)
    end

    PERCENT_REGEX = /(-?\d+(\.\d+)*)%/

    def parse_from_string(result)
      match = result.gsub(/\s+/, "").match(PERCENT_REGEX)
      if match
        match[1].to_f / 100.0
      elsif valid_integer_string?(result)
        int_from_string(result)
      else
        nil
      end
    end

    def is_negative?(result)
      result && result < 0
    end

    def parse_int_value(input)
      if input.is_a?(Integer) || input.is_a?(Float)
        input
      elsif valid_integer_string?(input)
        int_from_string(input)
      else
        nil
      end
    end

    def int_from_string(result)
      (result.gsub(' ', '')).to_i
    end

    NUMBER_REGEX = /^-?\s*\d+/

    def valid_integer_string?(input)
      input.is_a?(String) && input.match(NUMBER_REGEX)
    end

    def calculate_negative(result)
      @parent.extent + result
    end

    def relative_to_parent_start
      if element_start && parent.element_start
        element_start - parent.element_start
      else
        nil
      end
    end

    def relative_to_parent_end
      if element_end && parent.element_end
        parent.element_end - element_end
      else
        nil
      end
    end

    def start_as_center?
      @start_as_center
    end

    def adjust_start_for_center(value)
      my_extent = extent
      if my_extent && my_extent > 0
        value - my_extent / 2
      else
        nil
      end
    end
  end

  class ParentDimension < Dimension
    SIMPLE_DELEGATE_METHODS = [:extent, :absolute_start, :margin_start,
                               :margin_end, :start]

    SIMPLE_DELEGATE_METHODS.each do |method|
      define_method method do
        if value_modified? method
          super
        else
          parent.public_send(method)
        end
      end
    end

    private
    def value_modified?(method)
      instance_variable = ('@' + method.to_s).to_sym
      instance_variable_get(instance_variable)
    end
  end
end