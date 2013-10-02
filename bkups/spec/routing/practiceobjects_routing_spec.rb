require "spec_helper"

describe PracticeobjectsController do
  describe "routing" do

    it "routes to #index" do
      get("/practiceobjects").should route_to("practiceobjects#index")
    end

    it "routes to #new" do
      get("/practiceobjects/new").should route_to("practiceobjects#new")
    end

    it "routes to #show" do
      get("/practiceobjects/1").should route_to("practiceobjects#show", :id => "1")
    end

    it "routes to #edit" do
      get("/practiceobjects/1/edit").should route_to("practiceobjects#edit", :id => "1")
    end

    it "routes to #create" do
      post("/practiceobjects").should route_to("practiceobjects#create")
    end

    it "routes to #update" do
      put("/practiceobjects/1").should route_to("practiceobjects#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/practiceobjects/1").should route_to("practiceobjects#destroy", :id => "1")
    end

  end
end
