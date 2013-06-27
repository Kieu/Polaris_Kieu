require 'spec_helper'

describe BackgroundJobsController do

    describe "GET download" do
      before {get :new}
      subject {response}
      it {should redirect_to background_jobs_new_path}
    end

    describe "GET Upload" do
      before {get :upload}
      subject {response}
      it {should redirect_to background_jobs_upload_path}
    end

    describe "GET inprogress" do
      before {get :inprogress}
      subject {response}
      it {should redirect_to background_jobs_inprogress_path}
    end

end
