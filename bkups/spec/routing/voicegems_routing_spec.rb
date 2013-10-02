require "spec_helper"

describe VoicegemsController do
  describe "routing" do

    it "routes to #index" do
      get("/voicegems").should route_to("voicegems#index")
    end

    it "routes to #new" do
      get("/voicegems/new").should route_to("voicegems#new")
    end

    it "routes to #show" do
      get("/voicegems/1").should route_to("voicegems#show", :id => "1")
    end

    it "routes to #edit" do
      get("/voicegems/1/edit").should route_to("voicegems#edit", :id => "1")
    end

    it "routes to #create" do
      post("/voicegems").should route_to("voicegems#create")
    end

    it "routes to #update" do
      put("/voicegems/1").should route_to("voicegems#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/voicegems/1").should route_to("voicegems#destroy", :id => "1")
    end

  end
end
