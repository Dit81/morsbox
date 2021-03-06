Morsbox::Application.routes.draw do
  devise_for :admins, :controllers => {:registrations => "admin/registrations" }
  
  namespace 'admin' do
    resources :index
    resources :static_blocks, :except => [:new, :create, :show]
    resources :sections, :except => :show
    resources :projects, :except => :show do
      resources :descriptions, :only => [:create, :update, :destroy]
    end
    root :to => "projects#index"
  end

  resources :sections, :only => :show
  resources :projects, :only => :show
  resources :contacts, :only => [:index, :create]
  root :to => "pages#index"
  ActionDispatch::Routing::Translator.translate_from_file('config','i18n-routes.yml')
  
  match "(:locale)/*wrong" => "pages#404", :locale => /cs|en|ru/
  match "*wrong" => "pages#404"
end

