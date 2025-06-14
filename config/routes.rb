# == Route Map
#
#                                   Prefix Verb     URI Pattern                                                                                       Controller#Action
#                                                   /assets                                                                                           Propshaft::Server
#                       rails_health_check GET      /up(.:format)                                                                                     rails/health#show
#                             pwa_manifest GET      /manifest(.:format)                                                                               rails/pwa#manifest
#                       pwa_service_worker GET      /service-worker(.:format)                                                                         rails/pwa#service_worker
#                                     root GET      /                                                                                                 static#home
#                           book_file_page GET      /books/:book_id/files/:file_id/pages/:id(.:format)                                                pages#show
#                                book_file GET      /books/:book_id/files/:id(.:format)                                                               files#show
#                                     book GET      /books/:id(.:format)                                                                              books#show
#                                    pdfjs GET      /pdfjs(.:format)                                                                                  pdfjs#index
#                         new_user_session GET      /users/sign_in(.:format)                                                                          devise/sessions#new
#                             user_session POST     /users/sign_in(.:format)                                                                          devise/sessions#create
#                     destroy_user_session DELETE   /users/sign_out(.:format)                                                                         devise/sessions#destroy
#           user_google_omniauth_authorize GET|POST /users/auth/google(.:format)                                                                      devise/omniauth_callbacks#passthru
#            user_google_omniauth_callback GET|POST /users/auth/google/callback(.:format)                                                             devise/omniauth_callbacks#google
#                        new_user_password GET      /users/password/new(.:format)                                                                     devise/passwords#new
#                       edit_user_password GET      /users/password/edit(.:format)                                                                    devise/passwords#edit
#                            user_password PATCH    /users/password(.:format)                                                                         devise/passwords#update
#                                          PUT      /users/password(.:format)                                                                         devise/passwords#update
#                                          POST     /users/password(.:format)                                                                         devise/passwords#create
#                 cancel_user_registration GET      /users/cancel(.:format)                                                                           devise/registrations#cancel
#                    new_user_registration GET      /users/sign_up(.:format)                                                                          devise/registrations#new
#                   edit_user_registration GET      /users/edit(.:format)                                                                             devise/registrations#edit
#                        user_registration PATCH    /users(.:format)                                                                                  devise/registrations#update
#                                          PUT      /users(.:format)                                                                                  devise/registrations#update
#                                          DELETE   /users(.:format)                                                                                  devise/registrations#destroy
#                                          POST     /users(.:format)                                                                                  devise/registrations#create
#                    new_user_confirmation GET      /users/confirmation/new(.:format)                                                                 devise/confirmations#new
#                        user_confirmation GET      /users/confirmation(.:format)                                                                     devise/confirmations#show
#                                          POST     /users/confirmation(.:format)                                                                     devise/confirmations#create
#                          new_user_unlock GET      /users/unlock/new(.:format)                                                                       devise/unlocks#new
#                              user_unlock GET      /users/unlock(.:format)                                                                           devise/unlocks#show
#                                          POST     /users/unlock(.:format)                                                                           devise/unlocks#create
#                     mission_control_jobs          /jobs                                                                                             MissionControl::Jobs::Engine
#                             solid_errors          /solid_errors                                                                                     SolidErrors::Engine
#         turbo_recede_historical_location GET      /recede_historical_location(.:format)                                                             turbo/native/navigation#recede
#         turbo_resume_historical_location GET      /resume_historical_location(.:format)                                                             turbo/native/navigation#resume
#        turbo_refresh_historical_location GET      /refresh_historical_location(.:format)                                                            turbo/native/navigation#refresh
#            rails_postmark_inbound_emails POST     /rails/action_mailbox/postmark/inbound_emails(.:format)                                           action_mailbox/ingresses/postmark/inbound_emails#create
#               rails_relay_inbound_emails POST     /rails/action_mailbox/relay/inbound_emails(.:format)                                              action_mailbox/ingresses/relay/inbound_emails#create
#            rails_sendgrid_inbound_emails POST     /rails/action_mailbox/sendgrid/inbound_emails(.:format)                                           action_mailbox/ingresses/sendgrid/inbound_emails#create
#      rails_mandrill_inbound_health_check GET      /rails/action_mailbox/mandrill/inbound_emails(.:format)                                           action_mailbox/ingresses/mandrill/inbound_emails#health_check
#            rails_mandrill_inbound_emails POST     /rails/action_mailbox/mandrill/inbound_emails(.:format)                                           action_mailbox/ingresses/mandrill/inbound_emails#create
#             rails_mailgun_inbound_emails POST     /rails/action_mailbox/mailgun/inbound_emails/mime(.:format)                                       action_mailbox/ingresses/mailgun/inbound_emails#create
#           rails_conductor_inbound_emails GET      /rails/conductor/action_mailbox/inbound_emails(.:format)                                          rails/conductor/action_mailbox/inbound_emails#index
#                                          POST     /rails/conductor/action_mailbox/inbound_emails(.:format)                                          rails/conductor/action_mailbox/inbound_emails#create
#        new_rails_conductor_inbound_email GET      /rails/conductor/action_mailbox/inbound_emails/new(.:format)                                      rails/conductor/action_mailbox/inbound_emails#new
#            rails_conductor_inbound_email GET      /rails/conductor/action_mailbox/inbound_emails/:id(.:format)                                      rails/conductor/action_mailbox/inbound_emails#show
# new_rails_conductor_inbound_email_source GET      /rails/conductor/action_mailbox/inbound_emails/sources/new(.:format)                              rails/conductor/action_mailbox/inbound_emails/sources#new
#    rails_conductor_inbound_email_sources POST     /rails/conductor/action_mailbox/inbound_emails/sources(.:format)                                  rails/conductor/action_mailbox/inbound_emails/sources#create
#    rails_conductor_inbound_email_reroute POST     /rails/conductor/action_mailbox/:inbound_email_id/reroute(.:format)                               rails/conductor/action_mailbox/reroutes#create
# rails_conductor_inbound_email_incinerate POST     /rails/conductor/action_mailbox/:inbound_email_id/incinerate(.:format)                            rails/conductor/action_mailbox/incinerates#create
#                       rails_service_blob GET      /rails/active_storage/blobs/redirect/:signed_id/*filename(.:format)                               active_storage/blobs/redirect#show
#                 rails_service_blob_proxy GET      /rails/active_storage/blobs/proxy/:signed_id/*filename(.:format)                                  active_storage/blobs/proxy#show
#                                          GET      /rails/active_storage/blobs/:signed_id/*filename(.:format)                                        active_storage/blobs/redirect#show
#                rails_blob_representation GET      /rails/active_storage/representations/redirect/:signed_blob_id/:variation_key/*filename(.:format) active_storage/representations/redirect#show
#          rails_blob_representation_proxy GET      /rails/active_storage/representations/proxy/:signed_blob_id/:variation_key/*filename(.:format)    active_storage/representations/proxy#show
#                                          GET      /rails/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format)          active_storage/representations/redirect#show
#                       rails_disk_service GET      /rails/active_storage/disk/:encoded_key/*filename(.:format)                                       active_storage/disk#show
#                update_rails_disk_service PUT      /rails/active_storage/disk/:encoded_token(.:format)                                               active_storage/disk#update
#                     rails_direct_uploads POST     /rails/active_storage/direct_uploads(.:format)                                                    active_storage/direct_uploads#create
#
# Routes for MissionControl::Jobs::Engine:
#     application_queue_pause DELETE /applications/:application_id/queues/:queue_id/pause(.:format) mission_control/jobs/queues/pauses#destroy
#                             POST   /applications/:application_id/queues/:queue_id/pause(.:format) mission_control/jobs/queues/pauses#create
#          application_queues GET    /applications/:application_id/queues(.:format)                 mission_control/jobs/queues#index
#           application_queue GET    /applications/:application_id/queues/:id(.:format)             mission_control/jobs/queues#show
#       application_job_retry POST   /applications/:application_id/jobs/:job_id/retry(.:format)     mission_control/jobs/retries#create
#     application_job_discard POST   /applications/:application_id/jobs/:job_id/discard(.:format)   mission_control/jobs/discards#create
#    application_job_dispatch POST   /applications/:application_id/jobs/:job_id/dispatch(.:format)  mission_control/jobs/dispatches#create
#    application_bulk_retries POST   /applications/:application_id/jobs/bulk_retries(.:format)      mission_control/jobs/bulk_retries#create
#   application_bulk_discards POST   /applications/:application_id/jobs/bulk_discards(.:format)     mission_control/jobs/bulk_discards#create
#             application_job GET    /applications/:application_id/jobs/:id(.:format)               mission_control/jobs/jobs#show
#            application_jobs GET    /applications/:application_id/:status/jobs(.:format)           mission_control/jobs/jobs#index
#         application_workers GET    /applications/:application_id/workers(.:format)                mission_control/jobs/workers#index
#          application_worker GET    /applications/:application_id/workers/:id(.:format)            mission_control/jobs/workers#show
# application_recurring_tasks GET    /applications/:application_id/recurring_tasks(.:format)        mission_control/jobs/recurring_tasks#index
#  application_recurring_task GET    /applications/:application_id/recurring_tasks/:id(.:format)    mission_control/jobs/recurring_tasks#show
#                             PATCH  /applications/:application_id/recurring_tasks/:id(.:format)    mission_control/jobs/recurring_tasks#update
#                             PUT    /applications/:application_id/recurring_tasks/:id(.:format)    mission_control/jobs/recurring_tasks#update
#                      queues GET    /queues(.:format)                                              mission_control/jobs/queues#index
#                       queue GET    /queues/:id(.:format)                                          mission_control/jobs/queues#show
#                         job GET    /jobs/:id(.:format)                                            mission_control/jobs/jobs#show
#                        jobs GET    /:status/jobs(.:format)                                        mission_control/jobs/jobs#index
#                        root GET    /                                                              mission_control/jobs/queues#index
#
# Routes for SolidErrors::Engine:
#   root GET    /              solid_errors/errors#index
# errors GET    /              solid_errors/errors#index
#  error GET    /:id(.:format) solid_errors/errors#show
#        PATCH  /:id(.:format) solid_errors/errors#update
#        PUT    /:id(.:format) solid_errors/errors#update
#        DELETE /:id(.:format) solid_errors/errors#destroy

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "static#home"

  resources :books, only: :show do
    resources :files, only: :show do
      resources :pages, only: :show
    end
  end

  get "pdfjs", to: "pdfjs#index"

  devise_for :users

  authenticate :user, ->(user) { user.admin? } do
    mount MissionControl::Jobs::Engine, at: "/jobs"
    mount SolidErrors::Engine, at: "/solid_errors"
  end
end
