require 'spec_helper'

describe Media do
  let(:media) {FactoryGirl.create(:media)}

  subject {media}

  it {should respond_to(:media_name)}
  it {should respond_to(:media_category_id)}
  it {should respond_to(:del_flg)}
  it {should be_valid}
end
