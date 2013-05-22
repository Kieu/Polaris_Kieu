require 'spec_helper'

describe Agency do
  let(:agency) {FactoryGirl.create(:agency)}
  subject {agency}
  it {should respond_to(:agency_name)}
  it {should respond_to(:roman_name)}

  context "must be valid" do
    it {should be_valid}
  end

  context "must be invalid" do
    describe "when agency_name is blank" do
      before {agency.agency_name = " "}
      it {should_not be_valid}
    end

    describe "when roman_name is blank" do
      before {agency.roman_name = " "}
      it {should_not be_valid}
    end
  end
end
