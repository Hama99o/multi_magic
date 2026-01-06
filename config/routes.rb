Rails.application.routes.draw do
  mount ActionCable.server => "/cable"
  mount Sidekiq::Web => '/sidekiq'
  root to: 'application#multi_magic'

  namespace :api, defaults: {format: :json} do
    namespace :v1 do
      namespace :safezone_app do
        resources :passwords
        resources :payment_cards
        resources :identities
      end
      post 'ai/show'
      resources :images, only: [:create, :index]
      namespace :contact_app do
        resources :contacts do
          member do
            get :export_vcard
            put :restore
            delete :destroy_permanently
          end
          collection do
            post :import_vcard
            get :trashes
            get :export_multiple_contacts
          end
        end
      end

      namespace :my_finance_app do
        resources :loan_payments, only: [:destroy]

        resources :tags
        resources :loans do
          member do
            put :restore
            delete :destroy_permanently
            post :create_payment
          end

          collection do
            get :paid
            get :trashes
            get :pie_chart_data_by_cantact_name
          end
        end
        resources :expenses do
          member do
            put :restore
            delete :destroy_permanently
          end
          collection do
            get :trashes
            get :pie_chart_data_by_tag
            get :pie_chart_data_by_subcategories
            get :total_expenses_last_years_or_months
          end
        end
      end

      namespace :todo_app do
        resources :todo_groups
        resources :todos do
          member do
            put :toggle
          end
          collection do
            put :reorder
          end
        end
      end

      namespace :note_app do
        resources :tags
        resources :notes do
          member do
            put :restore
            delete :destroy_permanently
          end

          put :share_with_user_toggle
          put :update_shared_user_rights

          put :toggle_tag
          post :create_and_assign_tag
          collection do
            get :tags
            get :trashes

          end
        end
      end

      namespace :blog_app do
        namespace :users do
          get 'bookmarks/articles', to: 'bookmarks#user_article_bookmarks'
          delete 'bookmarks/articles/:id', to: 'bookmarks#destroy'
        end

        resources :tags
        resources :articles do
          resources :comments, only: [:index, :create, :update, :destroy], module: :articles
          resources :reactions, only: [:index, :create, :destroy], module: :articles do
            collection do
              delete '', to: 'reactions#destroy'  # Custom route for destroy without :id
            end
          end

          resources :bookmarks, only: [:index, :create, :destroy], module: :articles do
            collection do
              delete '', to: 'bookmarks#destroy'  # Custom route for destroy without :id
            end
          end
          member do
            put :restore
            delete :destroy_permanently
            post :toggle_tag
          end

          collection do
            get :drafts
            get :trashes
          end
        end
      end

      resources :impersonate do
        collection do
          get :is_impersonating
          post :start_impersonating
          post :stop_impersonating
        end
      end

      resources :users do
        collection do
          get :connected_user
          get :activated_users
          put :reset_password
          put :reset_password_confirmation
          get :global_users
        end

        member do
          delete :destroy_avatar
          put :change_password
          get :following
          get :followers
        end
      end

      resources :conversations do
        member do
          delete :destroy_permanently
        end

        collection do
          get :unread_messages_count
        end
        resources :messages, controller: "conversations/messages"
      end

      resources :follows do
        collection do
          post :follow
          post :unfollow
        end
      end

      resources :blocks do
        collection do
          post :block
          post :unblock
        end
      end

      resources :captcha, only: [] do
        collection do
          get :generate
          post :validate
        end
      end

    end
  end

  devise_for :users, defaults: { format: :json }, skip: :all
  get 'sitemap', to: 'sitemaps#show', defaults: { format: 'xml' }
  get 'google/callback', to: 'oauth_services#google_connect'

  devise_scope :user do
    # If you change these urls and helpers, you must change these files too:
    # - config/initializers/devise.rb#JWT Devise
    # - spec/support/authentication_helper.rb
    post '/users/login' => 'sessions#create', as: :user_session
    delete '/users/logout' => 'sessions#destroy', as: :destroy_user_session
    post '/users/signup' => 'registrations#create', as: :user_registration
  end

  get '/*path', to: 'application#multi_magic', as: :multi_magic, constraints: -> (req) { !(req.fullpath.start_with?('/rails/')) }
end
