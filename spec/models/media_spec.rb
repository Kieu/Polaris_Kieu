require 'spec_helper'
describe Media do
  let(:medium){ FactoryGirl.create(:medium)}
  describe "#get_media_list" do
    before { medium }
    subject {Media.get_media_list.count}
    it {should == 3}
  end
end
