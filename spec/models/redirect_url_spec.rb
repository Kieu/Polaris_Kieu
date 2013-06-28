require 'spec_helper'

describe RedirectUrl do
  let(:redirect_information) {FactoryGirl.create(:redirect_information)}
  let(:redirect_url) {FactoryGirl.create(:redirect_url, mpv: redirect_information.mpv)}

  subject {redirect_url}

  it {should respond_to(:mpv)}
  it {should respond_to(:url)}
  it {should respond_to(:rate)}
  it {should respond_to(:name)}
  it {should be_valid}
end
