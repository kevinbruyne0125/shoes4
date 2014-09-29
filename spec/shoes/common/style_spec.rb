require 'spec_helper'

describe Shoes::Common::Style do
  include_context "dsl app"

  class StyleTester
    include Shoes::Common::Style
    attr_accessor :left
    style_with :key, :left, :click, :strokewidth

    def initialize(app, style = {})
      @app = app #needed for style init
      @left = 15
      style_init(key: 'value', left: @left)
    end

    def click(&arg)
      @click = arg
    end

    def click_blk
      @click
    end
  end

  subject {StyleTester.new(app)}
  #let(:default_styles) {Shoes::Common::Style::DEFAULT_STYLES}
  let(:initial_style) { {key: 'value', left: 15, click: nil, strokewidth: 1} }

  its(:style) { should eq (initial_style) }

  describe 'changing the style through #style(hash)' do
    let(:changed_style) { {key: 'changed value'} }
    let(:input_proc) { Proc.new {} }

    before :each do
      subject.style changed_style
    end

    it 'returns the changed style' do
      expect(subject.style).to eq initial_style.merge changed_style
    end

    it 'does update values for new values' do
      subject.style new_key: 'new value'
      expect(subject.style[:new_key]).to eq 'new value'
    end

    it 'reads new dimensions' do
      subject.left = 20
      expect(subject.style[:left]).to eq 20
    end

    it 'writes new dimensions' do
      subject.style(left: 200)
      expect(subject.left).to eq 200
    end

    it 'sets click' do
      subject.style(click: input_proc)
      expect(subject.click_blk).to eq input_proc
    end

    it 'sets non dimension non click style via setter' do
      subject.key = 'silver'
      expect(subject.style[:key]).to eq 'silver'
    end

    it 'gets non dimension non click style via getter' do
      expect(subject.key).to eq 'changed value'
    end

    it "reads 'default' styles with reader" do
      expect(subject.strokewidth).to eq 1
    end

    it "writes 'default' styles with writer" do
      subject.strokewidth = 5
      expect(subject.strokewidth).to eq 5
    end

    it "does not read 'default' styles that it doesn't support" do
      expect(subject).not_to respond_to :stroke
    end

    it "does not write 'default' styles that it doesn't support" do
      expect(subject).not_to respond_to :stroke=
    end

    # these specs are rather extensive as they are performance critical for
    # redrawing
    describe 'calling or not calling #update_style' do
      it 'does not call #update_style if no key value pairs changed' do
        expect(subject).not_to receive(:update_style)
        subject.style changed_style
      end

      it 'does not call #update_style if called without arg' do
        expect(subject).not_to receive(:update_style)
        subject.style
      end

      it 'does call #update_style if the values change' do
        expect(subject).to receive(:update_style)
        subject.style key: 'new value'
      end

      it 'does call #update_style if there is a new key-value' do
        expect(subject).to receive(:update_style)
        subject.style new_key: 'value'
      end
    end
  end

  describe 'StyleWith' do
    it 'ensures that readers exist for each supported style' do
      subject.supported_styles.each do |style|
        expect(subject).to respond_to style
      end
    end

    it 'ensures that writers exist for each supported style' do
      subject.supported_styles.each do |style|
        expect(subject).to respond_to "#{style}="
      end
    end

  end

end
