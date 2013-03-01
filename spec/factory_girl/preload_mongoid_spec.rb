require "spec_helper_mongoid"

describe FactoryGirl::Preload do
  include FactoryGirl::Preload::Helpers

  it "should lazy load all factories, loading only when used" do
    FactoryGirl::Preload.record_ids['Artist'][:sid].should_not be_nil
    FactoryGirl::Preload.factories['Artist'][:sid].should be_nil

    artist = artists(:sid)

    FactoryGirl::Preload.factories['Artist'][:sid].should eq(artist)
  end

  it "injects model methods" do
    expect { artists(:sid) }.to_not raise_error
  end

  it "returns :syd factory for Artist model" do
    artists(:sid).should be_a(Artist)
  end

  it "returns :sid factory's name" do
    artists(:sid).name.should == "Sid Vicious"
  end

  it "raises error for missing factories" do
    expect { artists(:axl) }.to raise_error(%[Couldn't find :axl factory for "Artist" model])
  end

  it "removes records" do
    Artist.count.should == 1
    FactoryGirl::Preload.clean
    Artist.count.should == 0
  end

  context "reloadable factories" do
    before :all do
      FactoryGirl::Preload.clean
      FactoryGirl::Preload.run
    end

    before :each do
      FactoryGirl::Preload.reload_factories
    end

    it "updates name" do
      artists(:sid).name = "Axl Rose"
      artists(:sid).name.should == "Axl Rose"
    end

    it "reloads factory" do
      artists(:sid).name.should == "Sid Vicious"
      artists(:sid).should_not be_frozen
    end

    it "freezes object" do
      artists(:sid).destroy
      artists(:sid).should be_frozen
    end
  end
end

