require 'spec_helper'

describe Admin::ProjectsController do
  it "redirects to sign in form, when not admin" do
    get :index, :locale => 'ru'
    response.should redirect_to(new_admin_session_path)
    get :new, :locale => 'ru'
    response.should redirect_to(new_admin_session_path)
    post :create, :locale => 'ru'
    response.should redirect_to(new_admin_session_path)
    get :edit, :locale => 'ru', :id => 1
    response.should redirect_to(new_admin_session_path)
    put :update, :locale => 'ru', :id => 1
    response.should redirect_to(new_admin_session_path)
    delete :destroy, :locale => 'ru', :id => 1
    response.should redirect_to(new_admin_session_path)
  end
    
  describe "GET index" do
    before :each do
      @request.env["devise.mapping"] = Devise.mappings[:admin]
      sign_in Factory.create(:admin)
      @section = mock_model(Section).as_null_object
      @section.stub_chain(:projects,:sorted).and_return []
      @project = mock_model(Project).as_null_object
      Project.stub(:sorted).and_return [@project]
      Section.stub(:find_by_id).and_return nil
      Section.stub(:sorted).and_return [@section]
    end
    
    it "assign @admin_sections" do
      get :index, :locale => "ru"
      assigns(:admin_sections).should == [@section]
    end
    
    it "checks section filter" do
      Section.should_receive(:find_by_id).with '1'
      get :index, :locale => "ru", :section_id => '1'
    end
    
    context "when no section filter" do
      it "assign @projects" do
        get :index, :locale => "ru"
        assigns(:projects).should == [@project]
      end
    end
  
    context "when section filter present" do
      it "assign @projects only belonging to this section" do
        Section.stub(:find_by_id).and_return @section
        get :index, :locale => "ru", :section_id => '1'
        assigns(:projects).should == []
      end
    end
    
    it "renders index view" do
      get :index, :locale => 'ru'
      response.should render_template(:index)
    end
  end
  
  describe "GET new" do
    before :each do
      @request.env["devise.mapping"] = Devise.mappings[:admin]
      sign_in Factory.create(:admin)
      @section = mock_model(Section).as_null_object
      @project = mock_model(Project).as_null_object
      Section.stub(:sorted).and_return [@section]
      Project.stub(:new).and_return @project
    end
    
    it "assigns new project to @project" do
      get :new, :locale => 'en'
      assigns[:project].should == @project
    end
    
    it "creates new project from flash[:project]" do
      Project.should_receive(:new).with "name_ru"=>"Room"
      get :new, {:locale => 'en'}, nil, {:project => {"name_ru"=>"Room"}}
    end
    
    it "assign @admin_sections" do
      get :index, :locale => "ru"
      assigns(:admin_sections).should == [@section]
    end
    
    it "renders new template" do
      get :new, :locale => 'en'
      response.should render_template(:new)
    end
  end
  
  describe "POST create" do
    before :each do
      @request.env["devise.mapping"] = Devise.mappings[:admin]
      sign_in Factory.create(:admin)
      @project = mock_model(Project).as_null_object
      Project.stub(:new).and_return @project
      @project.stub(:save).and_return true
    end
    
    it "creates new project" do
      Project.should_receive(:new).with "name_ru"=>"Room"
      post :create, :locale => "ru", :project => {"name_ru"=>"Room"}
    end
    
    it "saves project" do
      @project.should_receive :save
      post :create, :locale => "ru"
    end
    
    it "nullifies empty translates from param hash" do
      Project.should_receive(:new).with "name_ru"=>"Room","name_en"=>nil
      post :create, :locale => "ru", :project=>{"name_ru"=>"Room","name_en"=>""}
    end
    
    context "when saving is successful" do
      it "sets flash[:notice]" do
        post :create, :locale => "ru"
        flash[:notice].should=~ /.+/
      end
      
      it "redirects to edit this project if apply was passed" do
        post :create, :locale => "ru", :apply => "foo"
        response.should redirect_to(edit_admin_project_path(@project))
      end
      
      it "redirects to index of projects if apply wasn't passed" do
        post :create, :locale => "ru"
        response.should redirect_to(admin_projects_path)
      end
    end
    
    context "when saving isn't successful" do
      before :each do
        @project.stub(:save).and_return false
      end
      
      it "sets flash[:alert]" do
        post :create, :locale => "ru"
        flash[:alert].should=~ /.+/
      end
      
      it "sets flash[:project] with params[:section]" do
        post :create, :locale => 'en', :project => {"name_ru"=>"Room"}
        flash[:project].should == {"name_ru"=>"Room"}
      end
      
      it "redirects to new project" do
        post :create, :locale => "ru"
        response.should redirect_to(new_admin_project_path)
      end
    end
  end
  
  describe "GET edit" do
    before :each do
      @request.env["devise.mapping"] = Devise.mappings[:admin]
      sign_in Factory.create(:admin)
      @section = mock_model(Section).as_null_object
      @project = mock_model(Project, :id => 1, :name_ru=>"Room").as_null_object
      Section.stub(:sorted).and_return [@section]
      Project.stub(:find).and_return @project
    end
    
    it "assigns @project" do
      Project.should_receive(:find).with 1
      get :edit, :locale => "ru", :id => 1
      assigns(:project).should == @project
    end
    
    it "assigns @admin_sections" do
      get :edit, :locale => "ru", :id => 1
      assigns(:admin_sections).should == [@section]
    end
    
    it "renders edit view" do
      get :edit, :locale => 'ru', :id => 1
      response.should render_template(:edit)
    end
  end
end