require 'swt_shoes/spec_helper'
require 'shoes/swt/text_block_fitter'

describe Shoes::Swt::TextBlockFitter do
  let(:dsl) { double('dsl', parent: parent_dsl, text: "Text goes here",
                     absolute_left: 25, absolute_top: 75,
                     desired_width: 85,
                     element_left: 26, element_top: 76,
                     margin_left: 1, margin_top: 1) }

  let(:parent_dsl) { double('parent_dsl',
                            absolute_left: 0, absolute_right: 100,
                            width: 100, height: 200) }

  let(:text_block) { double('text_block', dsl: dsl) }

  let(:current_position) { double('current_position') }

  subject { Shoes::Swt::TextBlockFitter.new(text_block, current_position) }

  before(:each) do
    text_block.stub(:generate_layout)
  end

  describe "determining available space" do
    it "should offset by parent with current position" do
      when_positioned_at(x: 15, y: 5, next_line_start: 30)
      expect(subject.available_space).to eq([85, 24])
    end

    it "should move to next line with at very end of vertical space" do
      when_positioned_at(x: 15, y: 5, next_line_start: 5)
      expect(subject.available_space).to eq([85, :unbounded])
    end

    it "should move to next line when top is past the projected next line" do
      when_positioned_at(x: 15, y: 100, next_line_start: 5)
      expect(subject.available_space).to eq([85, :unbounded])
    end
  end

  describe "layout generation" do
    it "should be delegated to the text block" do
      expect(text_block).to receive(:generate_layout).with(150, "Test")
      subject.generate_layout(150, "Test")
    end
  end

  describe "finding what didn't fit" do
    it "should tell split text by offsets and heights" do
      layout = double('layout', line_offsets: [0, 5, 9], text: "Text Split")
      layout.stub(:line_metrics) { double('line_metrics', height: 50)}

      subject.split_text(layout, 55).should eq(["Text ", "Split"])
    end

    it "should be able to split text when too small" do
      layout = double('layout', line_offsets: [0, 10], text: "Text Split")
      layout.stub(:line_metrics).with(0) { double('line_metrics', height: 21)}
      layout.stub(:line_metrics).with(1) { raise "Boom" }

      subject.split_text(layout, 33).should eq(["Text Split", ""])
    end
  end

  describe "fit it in" do
    let(:bounds) { double('bounds', width: 100, height: 50)}
    let(:layout) { double('layout', text: "something something",
                          line_count: 1, line_offsets:[], get_bounds: bounds) }

    before(:each) do
      text_block.stub(:generate_layout) { layout }
    end

    context "to one layout" do
      it "should work" do
        fitted_layouts = when_fit_at(x: 25, y: 75, next_line_start: 130)
        expect_fitted_layouts(fitted_layouts, [26, 76])
      end

      it "with one line, even if height is bigger" do
        bounds.stub(width: 50)
        fitted_layouts = when_fit_at(x: 25, y: 75, next_line_start: 95)
        expect_fitted_layouts(fitted_layouts, [26, 76])
      end
    end

    context "to two layouts" do
      before(:each) do
        layout.stub(line_count: 2, line_metrics: double(height: 15))
        bounds.stub(width: 50)
        dsl.stub(containing_width: :unused)
      end

      it "should split text and overflow to second layout" do
        with_text_split("something ", "something")
        fitted_layouts = when_fit_at(x: 25, y: 75, next_line_start: 95)
        expect_fitted_layouts(fitted_layouts, [26, 76], [1, 126])
      end

      it "should overflow all text to second layout" do
        with_text_split("", "something something")
        fitted_layouts = when_fit_at(x: 25, y: 75, next_line_start: 95)
        expect_fitted_layouts(fitted_layouts, [26, 76], [1, 95])
      end
    end
  end

  def with_text_split(first, second)
    dsl.stub(text: first + second)
    layout.stub(line_offsets: [0, first.length, first.length + second.length])
  end

  def when_positioned_at(args)
    x = args.fetch(:x)
    y = args.fetch(:y)
    next_line_start = args.fetch(:next_line_start)

    dsl.stub(absolute_left: x, absolute_top: y)
    current_position.stub(:next_line_start) { next_line_start }
  end

  def when_fit_at(args)
    when_positioned_at(args)
    subject.fit_it_in
  end

  def expect_fitted_layouts(fitted_layouts, *coordinates)
    actual = fitted_layouts.map {|fitted| [fitted.left, fitted.top] }
    expect(coordinates).to eq(actual)
  end
end
