# frozen_string_literal: true

# Check and Radio
shared_examples "selectable" do
  it "calls get_selection when checked? is called" do
    expect(real).to receive(:get_selection)
    subject.checked?
  end

  it "calls set_selection when checked= is called" do
    expect(real).to receive(:set_selection).with(true)
    subject.checked = true
  end
end
