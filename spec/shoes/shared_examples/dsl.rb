shared_context "style context" do
  let(:fill_color) { Shoes::COLORS.fetch(:tomato) }
  let(:stroke_color) { Shoes::COLORS.fetch(:chartreuse) }

  before :each do
    subject.fill fill_color
    subject.stroke stroke_color
  end
end

# Specs behavior for "global" fill
#
# @example
#   Shoes.app do
#     fill tomato
#     arc 400, 200, 200, 300, 0, Shoes::HALF_PI
#   end
#
# In these specs, subject is Shoes::App, element is created element (e.g. Shoes::Arc)
shared_examples_for "persistent fill" do
  include_context "style context"

  specify "passes to element" do
    element.fill.should eq(fill_color)
  end
end

shared_examples_for "persistent stroke" do
  include_context "style context"

  specify "passes to element" do
    element.stroke.should eq(stroke_color)
  end
end


# Shared examples for app, flow, stack
shared_examples "dsl container" do
  describe "animate" do
    context "defaults" do
      let(:animation) { subject.animate {} }

      specify "is a Shoes::Animation" do
        animation.should be_an_instance_of(Shoes::Animation)
      end

      specify "framerate is 24" do
        animation.framerate.should eq(24)
      end
    end

    context "with numeric argument" do
      let(:animation) { subject.animate(13) {} }

      specify "sets framerate" do
        animation.framerate.should eq(13)
      end
    end

    context "with hash argument" do
      let(:animation) { subject.animate(:framerate => 17) {} }

      specify "sets framerate" do
        animation.framerate.should eq(17)
      end
    end
  end

  describe "arc" do
    let(:arc) { subject.arc(13, 44, 200, 300, 0, Shoes::TWO_PI) }

    specify "creates a Shoes::Arc" do
      arc.should be_an_instance_of(Shoes::Arc)
    end

    it_behaves_like "persistent fill" do
      let(:element) { arc }
    end

    it_behaves_like "persistent stroke" do
      let(:element) { arc }
    end
  end

  describe "fill" do
    let(:color) { Shoes::COLORS.fetch :tomato }

    specify "returns a color" do
      subject.fill(color).class.should eq(Shoes::Color)
    end

    # This works differently on a container than on a normal element
    specify "sets on receiver" do
      subject.fill color
      subject.style[:fill].should eq(color)
    end

    specify "applies to subsequently created objects" do
      subject.fill color
      Shoes::Oval.should_receive(:new).with do |*args|
        style = args.pop
        style[:fill].should eq(color)
      end
      subject.oval(10, 10, 100, 100)
    end
  end

  describe "flow" do
    it "creates a Shoes::Flow" do
      blk = Proc.new {}
      opts = Hash.new
      flow = subject.flow opts, &blk
      flow.should be_an_instance_of(Shoes::Flow)
    end
  end

  describe "line" do
    it "creates a Shoes::Line" do
      subject.line(10, 15, 20, 30).should be_an_instance_of(Shoes::Line)
    end
  end

  describe "oval" do
    it "creates a Shoes::Oval" do
      subject.oval(10, 50, 250).should be_an_instance_of(Shoes::Oval)
    end
  end

  describe "rgb" do
    let(:red) { 100 }
    let(:green) { 149 }
    let(:blue) { 237 }
    let(:alpha) { 133 } # cornflower

    it "sends args to Shoes::Color" do
      Shoes::Color.should_receive(:new).with(red, green, blue, alpha)
      subject.rgb(red, green, blue, alpha)
    end

    it "defaults to opaque" do
      Shoes::Color.should_receive(:new).with(red, green, blue, Shoes::Color::OPAQUE)
      subject.rgb(red, green, blue)
    end
  end

  describe "shape" do
    let(:shape) {
      subject.shape {
        move_to 400, 300
        line_to 400, 200
        line_to 100, 100
        line_to 400, 300
      }
    }

    specify "creates a Shoes::Shape" do
      shape.should be_an_instance_of(Shoes::Shape)
    end

    it "receives style from app" do
      green = Shoes::COLORS.fetch :green
      subject.style[:stroke] = green
      shape.stroke.should eq(green)
    end
  end

  describe "stroke" do
    let(:color) { Shoes::COLORS.fetch :tomato }

    specify "returns a color" do
      subject.stroke(color).class.should eq(Shoes::Color)
    end

    # This works differently on a container than on a normal element
    specify "sets on receiver" do
      subject.stroke color
      subject.style[:stroke].should eq(color)
    end

    specify "applies to subsequently created objects" do
      subject.stroke color
      Shoes::Oval.should_receive(:new).with do |*args|
        style = args.pop
        style[:stroke].should eq(color)
      end
      subject.oval(10, 10, 100, 100)
    end
  end

  describe "strokewidth" do
    specify "returns a number" do
      subject.strokewidth(4).should eq(4)
    end

    specify "sets on receiver" do
      subject.strokewidth 4
      subject.style[:strokewidth].should eq(4)
    end

    specify "applies to subsequently created objects" do
      subject.strokewidth 6
      Shoes::Oval.should_receive(:new).with do |*args|
        style = args.pop
        style[:strokewidth].should eq(6)
      end
      subject.oval(10, 10, 100, 100)
    end
  end

  describe "text_block" do
    it "should set banner font size to 48" do
      text_block = subject.banner("hello!")
      text_block.font_size.should eql 48
    end

    it "should set title font size to 34" do
      text_block = subject.title("hello!")
      text_block.font_size.should eql 34
    end

    it "should set subtitle font size to 26" do
      text_block = subject.subtitle("hello!")
      text_block.font_size.should eql 26
    end

    it "should set tagline font size to 18" do
      text_block = subject.tagline("hello!")
      text_block.font_size.should eql 18
    end

    it "should set caption font size to 14" do
      text_block = subject.caption("hello!")
      text_block.font_size.should eql 14
    end

    it "should set para font size to 12" do
      text_block = subject.para("hello!")
      text_block.font_size.should eql 12
    end

    it "should set inscription font size to 10" do
      text_block = subject.inscription("hello!")
      text_block.font_size.should eql 10
    end
  end
end
