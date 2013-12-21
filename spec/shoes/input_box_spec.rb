require 'shoes/spec_helper'

describe Shoes::InputBox do
  let(:left) { 10 }
  let(:top) { 20 }
  let(:width) { 100 }
  let(:height) { 200 }
  let(:input_block) { Proc.new {} }


  let(:app) { Shoes::App.new }
  let(:parent) { Shoes::Flow.new(app, app) }
  let(:text) { "the text" }
  let(:input_opts) {{left: left, top: top, width: width, height: height}}

  subject { Shoes::InputBox.new(app, parent, text, input_opts, input_block) }

  it_behaves_like "object with dimensions"
  it_behaves_like "movable object"
  it_behaves_like "an element that can respond to change"
  it_behaves_like "object with state"


  it { should respond_to :focus }
  it { should respond_to :text  }
  it { should respond_to :text= }

  describe "relative dimensions from parent" do
    subject { Shoes::EditBox.new(app, parent, text, relative_opts) }
    it_behaves_like "object with relative dimensions"
  end

  describe "negative dimensions" do
    subject { Shoes::EditBox.new(app, parent, text, negative_opts) }
    it_behaves_like "object with negative dimensions"
  end
end
