require 'spec_helper'

describe RedirectUrl do
  let(:promotion) {FactoryGirl.create(:promotion)}
  let(:account){ FactoryGirl.create(:account)}
  let(:medium){ FactoryGirl.create(:medium)}
  
  describe "get_url_data index" do
    subject{RedirectUrl.get_url_data promotion.id, account.id, medium.id, 1, 10, "2013/05/01", "2013/05/02", type = 'index'}
    it {should == [[], [{"totalCount"=>0}]]}
  end
  
  describe "get_url_data index" do
    subject{RedirectUrl.get_url_data promotion.id, account.id, medium.id, 1, 10, "2013/05/01", "2013/05/02", type = 'download'}
    it {should == [[], [{"totalCount"=>0}]]}
  end
end
