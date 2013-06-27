require 'spec_helper'

describe BackgroundJobsController do

    describe "GET download" do
      before {get :new}
      subject {response}
    end

    describe "GET Upload" do
      before {get :upload}
      subject {response}
    end

    describe "GET inprogress" do
      before {get :inprogress}
      subject {response}
    end

end
