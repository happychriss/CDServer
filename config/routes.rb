CDServer::Application.routes.draw do

  ## Upload Sorting, non HABTM
  get 'upload_status' => 'upload_sorting#upload_status'
  get 'sorting/destroy_page' => 'upload_sorting#destroy_page'


  ### Upload from Client
  post 'upload_page' => 'uploads#create_from_client',:as => :upload_page

  ## Search Controller, non HABTM
  match 'pdf/:id' => 'search#show_pdf', :as => :pdf
  match 'rtf/:id' => 'search#show_rtf', :as => :rtf
  post 'add_page' => 'search#add_page'

  match 'search/' => 'search#search'
  match 'found/' => 'search#found'
  match 'show_document_pages/:id' => 'search#show_document_pages',:as => :show_document_pages

  ## Edit Documents contgroller
  post 'sort_pages' => 'documents#sort_pages'
  get 'documents/remove_page/:id' => 'documents#remove_page'
  get 'documents/destroy_page' => 'documents#destroy_page'

  ## Status
  get 'status/index' => 'status#index'

  resources :folders
  resources :tags
  resources :upload_sorting
  resources :documents
  resources :status
  resources :uploads

  #resources :documents do
  #     resources :documents, :uploads
  #end

  root :to => 'search#search'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
