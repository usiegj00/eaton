# frozen_string_literal: true

RSpec.describe Eaton do
  it "has a version number" do
    expect(Eaton::VERSION).not_to be nil
  end

  it "defines the Error class" do
    expect(Eaton::Error).to be < StandardError
  end
end
