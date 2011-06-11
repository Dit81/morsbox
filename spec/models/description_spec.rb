require 'spec_helper'

describe Description do
  describe "scope :ordered" do
    before :each do
      @description = Factory :description
    end
    
    it "returns descriptions ordered by show_order" do
      @second_description = Factory :description, :show_order => 1
      Description.ordered.should == [@description,@second_description]
    end
    
    it "returns descriptions with equal show_order ordered by creation time" do
      @second_description = Factory :description, :created_at => Time.now.tomorrow
      Description.ordered.should == [@second_description,@description]
    end
  end
  
  describe "scope :enabled" do
    before :each do
      @description = Factory :description
      @disabled_description = Factory :description, :enabled => false
    end
    
    it "returns enabled descriptions" do
      Description.enabled.should include(@description)
    end
    
    it "doesn't return disabled descriptions"do
      Description.enabled.should_not include(@disabled_description)
    end
    
    it "returns descriptions ordered by show_order" do
      @second_description = Factory :description, :show_order => 1
      Description.enabled.should == [@description,@second_description]
    end
    
    it "returns descriptions with equal show_order ordered by creation time" do
      @second_description = Factory :description, :created_at => Time.now.tomorrow
      Description.enabled.should == [@second_description,@description]
    end
  end
end
