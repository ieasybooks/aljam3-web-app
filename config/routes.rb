# == Route Map
#
#                                   Prefix Verb     URI Pattern                                                                                       Controller#Action
#                                                   /assets                                                                                           Propshaft::Server
#                       rails_health_check GET      /up(.:format)                                                                                     rails/health#show
#                             pwa_manifest GET      /manifest-v2(.:format)                                                                            rails/pwa#manifest
#                       pwa_service_worker GET      /service-worker(.:format)                                                                         rails/pwa#service_worker
#                                     root GET      /                                                                                                 static#home
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
#                                 contacts POST     /contacts(.:format)                                                                               contacts#create
#                               categories GET      /categories(.:format)                                                                             categories#index
#                                 category GET      /categories/:id(.:format)                                                                         categories#show
#                                  authors GET      /authors(.:format)                                                                                authors#index
#                                   author GET      /authors/:id(.:format)                                                                            authors#show
#                              book_search GET      /books/:book_id/search(.:format)                                                                  books#search
#                                    books GET      /books(.:format)                                                                                  books#index
#                                      avo          /avo                                                                                              Avo::Engine
#                     mission_control_jobs          /jobs                                                                                             MissionControl::Jobs::Engine
#                                  pg_hero          /pghero                                                                                           PgHero::Engine
#                             solid_errors          /solid_errors                                                                                     SolidErrors::Engine
#                        rails_performance          /performance                                                                                      RailsPerformance::Engine
#                           book_file_page GET      /:book_id/:file_id/:page_number(.:format)                                                         pages#show {book_id: /\d+/, file_id: /\d+/, page_number: /\d+/}
#                                book_file GET      /:book_id/:file_id(.:format)                                                                      files#show {book_id: /\d+/, file_id: /\d+/}
#                                     book GET      /:book_id(.:format)                                                                               books#show {book_id: /\d+/}
#                                 lookbook          /lookbook                                                                                         Lookbook::Engine
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
# Routes for Avo::Engine:
#                                root GET    /                                                                                                  avo/home#index
#              avo_resources_redirect GET    /resources(.:format)                                                                               redirect(301, /avo)
#             avo_dashboards_redirect GET    /dashboards(.:format)                                                                              redirect(301, /avo)
#                 media_library_index GET    /media-library(.:format)                                                                           avo/media_library#index
#                       media_library GET    /media-library/:id(.:format)                                                                       avo/media_library#show
#                                     PATCH  /media-library/:id(.:format)                                                                       avo/media_library#update
#                                     PUT    /media-library/:id(.:format)                                                                       avo/media_library#update
#                                     DELETE /media-library/:id(.:format)                                                                       avo/media_library#destroy
#                        attach_media GET    /attach-media(.:format)                                                                            avo/media_library#attach
# rails_active_storage_direct_uploads POST   /rails/active_storage/direct_uploads(.:format)                                                     active_storage/direct_uploads#create
#                      avo_api_search GET    /avo_api/search(.:format)                                                                          avo/search#index
#                             avo_api GET    /avo_api/:resource_name/search(.:format)                                                           avo/search#show
#                                     POST   /avo_api/resources/:resource_name/:id/attachments(.:format)                                        avo/attachments#create
#                  distribution_chart GET    /:resource_name/:field_id/distribution_chart(.:format)                                             avo/charts#distribution_chart
#                      failed_to_load GET    /failed_to_load(.:format)                                                                          avo/home#failed_to_load
#                           resources DELETE /resources/:resource_name/:id/active_storage_attachments/:attachment_name/:attachment_id(.:format) avo/attachments#destroy
#                                     GET    /resources/:resource_name(/:id)/actions(/:action_id)(.:format)                                     avo/actions#show
#                                     POST   /resources/:resource_name(/:id)/actions(/:action_id)(.:format)                                     avo/actions#handle
#              preview_resources_user GET    /resources/users/:id/preview(.:format)                                                             avo/users#preview
#                     resources_users GET    /resources/users(.:format)                                                                         avo/users#index
#                                     POST   /resources/users(.:format)                                                                         avo/users#create
#                  new_resources_user GET    /resources/users/new(.:format)                                                                     avo/users#new
#                 edit_resources_user GET    /resources/users/:id/edit(.:format)                                                                avo/users#edit
#                      resources_user GET    /resources/users/:id(.:format)                                                                     avo/users#show
#                                     PATCH  /resources/users/:id(.:format)                                                                     avo/users#update
#                                     PUT    /resources/users/:id(.:format)                                                                     avo/users#update
#                                     DELETE /resources/users/:id(.:format)                                                                     avo/users#destroy
#      preview_resources_search_query GET    /resources/search_queries/:id/preview(.:format)                                                    avo/search_queries#preview
#            resources_search_queries GET    /resources/search_queries(.:format)                                                                avo/search_queries#index
#                                     POST   /resources/search_queries(.:format)                                                                avo/search_queries#create
#          new_resources_search_query GET    /resources/search_queries/new(.:format)                                                            avo/search_queries#new
#         edit_resources_search_query GET    /resources/search_queries/:id/edit(.:format)                                                       avo/search_queries#edit
#              resources_search_query GET    /resources/search_queries/:id(.:format)                                                            avo/search_queries#show
#                                     PATCH  /resources/search_queries/:id(.:format)                                                            avo/search_queries#update
#                                     PUT    /resources/search_queries/:id(.:format)                                                            avo/search_queries#update
#                                     DELETE /resources/search_queries/:id(.:format)                                                            avo/search_queries#destroy
#      preview_resources_search_click GET    /resources/search_clicks/:id/preview(.:format)                                                     avo/search_clicks#preview
#             resources_search_clicks GET    /resources/search_clicks(.:format)                                                                 avo/search_clicks#index
#                                     POST   /resources/search_clicks(.:format)                                                                 avo/search_clicks#create
#          new_resources_search_click GET    /resources/search_clicks/new(.:format)                                                             avo/search_clicks#new
#         edit_resources_search_click GET    /resources/search_clicks/:id/edit(.:format)                                                        avo/search_clicks#edit
#              resources_search_click GET    /resources/search_clicks/:id(.:format)                                                             avo/search_clicks#show
#                                     PATCH  /resources/search_clicks/:id(.:format)                                                             avo/search_clicks#update
#                                     PUT    /resources/search_clicks/:id(.:format)                                                             avo/search_clicks#update
#                                     DELETE /resources/search_clicks/:id(.:format)                                                             avo/search_clicks#destroy
#              preview_resources_page GET    /resources/pages/:id/preview(.:format)                                                             avo/pages#preview
#                     resources_pages GET    /resources/pages(.:format)                                                                         avo/pages#index
#                                     POST   /resources/pages(.:format)                                                                         avo/pages#create
#                  new_resources_page GET    /resources/pages/new(.:format)                                                                     avo/pages#new
#                 edit_resources_page GET    /resources/pages/:id/edit(.:format)                                                                avo/pages#edit
#                      resources_page GET    /resources/pages/:id(.:format)                                                                     avo/pages#show
#                                     PATCH  /resources/pages/:id(.:format)                                                                     avo/pages#update
#                                     PUT    /resources/pages/:id(.:format)                                                                     avo/pages#update
#                                     DELETE /resources/pages/:id(.:format)                                                                     avo/pages#destroy
#           preview_resources_library GET    /resources/libraries/:id/preview(.:format)                                                         avo/libraries#preview
#                 resources_libraries GET    /resources/libraries(.:format)                                                                     avo/libraries#index
#                                     POST   /resources/libraries(.:format)                                                                     avo/libraries#create
#               new_resources_library GET    /resources/libraries/new(.:format)                                                                 avo/libraries#new
#              edit_resources_library GET    /resources/libraries/:id/edit(.:format)                                                            avo/libraries#edit
#                   resources_library GET    /resources/libraries/:id(.:format)                                                                 avo/libraries#show
#                                     PATCH  /resources/libraries/:id(.:format)                                                                 avo/libraries#update
#                                     PUT    /resources/libraries/:id(.:format)                                                                 avo/libraries#update
#                                     DELETE /resources/libraries/:id(.:format)                                                                 avo/libraries#destroy
#           preview_resources_contact GET    /resources/contacts/:id/preview(.:format)                                                          avo/contacts#preview
#                  resources_contacts GET    /resources/contacts(.:format)                                                                      avo/contacts#index
#                                     POST   /resources/contacts(.:format)                                                                      avo/contacts#create
#               new_resources_contact GET    /resources/contacts/new(.:format)                                                                  avo/contacts#new
#              edit_resources_contact GET    /resources/contacts/:id/edit(.:format)                                                             avo/contacts#edit
#                   resources_contact GET    /resources/contacts/:id(.:format)                                                                  avo/contacts#show
#                                     PATCH  /resources/contacts/:id(.:format)                                                                  avo/contacts#update
#                                     PUT    /resources/contacts/:id(.:format)                                                                  avo/contacts#update
#                                     DELETE /resources/contacts/:id(.:format)                                                                  avo/contacts#destroy
#          preview_resources_category GET    /resources/categories/:id/preview(.:format)                                                        avo/categories#preview
#                resources_categories GET    /resources/categories(.:format)                                                                    avo/categories#index
#                                     POST   /resources/categories(.:format)                                                                    avo/categories#create
#              new_resources_category GET    /resources/categories/new(.:format)                                                                avo/categories#new
#             edit_resources_category GET    /resources/categories/:id/edit(.:format)                                                           avo/categories#edit
#                  resources_category GET    /resources/categories/:id(.:format)                                                                avo/categories#show
#                                     PATCH  /resources/categories/:id(.:format)                                                                avo/categories#update
#                                     PUT    /resources/categories/:id(.:format)                                                                avo/categories#update
#                                     DELETE /resources/categories/:id(.:format)                                                                avo/categories#destroy
#         preview_resources_book_file GET    /resources/book_files/:id/preview(.:format)                                                        avo/book_files#preview
#                resources_book_files GET    /resources/book_files(.:format)                                                                    avo/book_files#index
#                                     POST   /resources/book_files(.:format)                                                                    avo/book_files#create
#             new_resources_book_file GET    /resources/book_files/new(.:format)                                                                avo/book_files#new
#            edit_resources_book_file GET    /resources/book_files/:id/edit(.:format)                                                           avo/book_files#edit
#                 resources_book_file GET    /resources/book_files/:id(.:format)                                                                avo/book_files#show
#                                     PATCH  /resources/book_files/:id(.:format)                                                                avo/book_files#update
#                                     PUT    /resources/book_files/:id(.:format)                                                                avo/book_files#update
#                                     DELETE /resources/book_files/:id(.:format)                                                                avo/book_files#destroy
#              preview_resources_book GET    /resources/books/:id/preview(.:format)                                                             avo/books#preview
#                     resources_books GET    /resources/books(.:format)                                                                         avo/books#index
#                                     POST   /resources/books(.:format)                                                                         avo/books#create
#                  new_resources_book GET    /resources/books/new(.:format)                                                                     avo/books#new
#                 edit_resources_book GET    /resources/books/:id/edit(.:format)                                                                avo/books#edit
#                      resources_book GET    /resources/books/:id(.:format)                                                                     avo/books#show
#                                     PATCH  /resources/books/:id(.:format)                                                                     avo/books#update
#                                     PUT    /resources/books/:id(.:format)                                                                     avo/books#update
#                                     DELETE /resources/books/:id(.:format)                                                                     avo/books#destroy
#            preview_resources_author GET    /resources/authors/:id/preview(.:format)                                                           avo/authors#preview
#                   resources_authors GET    /resources/authors(.:format)                                                                       avo/authors#index
#                                     POST   /resources/authors(.:format)                                                                       avo/authors#create
#                new_resources_author GET    /resources/authors/new(.:format)                                                                   avo/authors#new
#               edit_resources_author GET    /resources/authors/:id/edit(.:format)                                                              avo/authors#edit
#                    resources_author GET    /resources/authors/:id(.:format)                                                                   avo/authors#show
#                                     PATCH  /resources/authors/:id(.:format)                                                                   avo/authors#update
#                                     PUT    /resources/authors/:id(.:format)                                                                   avo/authors#update
#                                     DELETE /resources/authors/:id(.:format)                                                                   avo/authors#destroy
#          resources_associations_new GET    /resources/:resource_name/:id/:related_name/new(.:format)                                          avo/associations#new
#        resources_associations_index GET    /resources/:resource_name/:id/:related_name(.:format)                                              avo/associations#index
#         resources_associations_show GET    /resources/:resource_name/:id/:related_name/:related_id(.:format)                                  avo/associations#show
#       resources_associations_create POST   /resources/:resource_name/:id/:related_name(.:format)                                              avo/associations#create
#      resources_associations_destroy DELETE /resources/:resource_name/:id/:related_name/:related_id(.:format)                                  avo/associations#destroy
#                  avo_private_status GET    /avo_private/status(.:format)                                                                      avo/debug#status
#              avo_private_send_to_hq POST   /avo_private/status/send_to_hq(.:format)                                                           avo/debug#send_to_hq
#            avo_private_debug_report GET    /avo_private/debug/report(.:format)                                                                avo/debug#report
#   avo_private_debug_refresh_license POST   /avo_private/debug/refresh_license(.:format)                                                       avo/debug#refresh_license
#                  avo_private_design GET    /avo_private/design(.:format)                                                                      avo/private#design
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
# Routes for PgHero::Engine:
#                     space GET  (/:database)/space(.:format)                     pg_hero/home#space
#            relation_space GET  (/:database)/space/:relation(.:format)           pg_hero/home#relation_space
#               index_bloat GET  (/:database)/index_bloat(.:format)               pg_hero/home#index_bloat
#              live_queries GET  (/:database)/live_queries(.:format)              pg_hero/home#live_queries
#                   queries GET  (/:database)/queries(.:format)                   pg_hero/home#queries
#                show_query GET  (/:database)/queries/:query_hash(.:format)       pg_hero/home#show_query
#                    system GET  (/:database)/system(.:format)                    pg_hero/home#system
#                 cpu_usage GET  (/:database)/cpu_usage(.:format)                 pg_hero/home#cpu_usage
#          connection_stats GET  (/:database)/connection_stats(.:format)          pg_hero/home#connection_stats
#     replication_lag_stats GET  (/:database)/replication_lag_stats(.:format)     pg_hero/home#replication_lag_stats
#                load_stats GET  (/:database)/load_stats(.:format)                pg_hero/home#load_stats
#          free_space_stats GET  (/:database)/free_space_stats(.:format)          pg_hero/home#free_space_stats
#                   explain GET  (/:database)/explain(.:format)                   pg_hero/home#explain
#                      tune GET  (/:database)/tune(.:format)                      pg_hero/home#tune
#               connections GET  (/:database)/connections(.:format)               pg_hero/home#connections
#               maintenance GET  (/:database)/maintenance(.:format)               pg_hero/home#maintenance
#                      kill POST (/:database)/kill(.:format)                      pg_hero/home#kill
# kill_long_running_queries POST (/:database)/kill_long_running_queries(.:format) pg_hero/home#kill_long_running_queries
#                  kill_all POST (/:database)/kill_all(.:format)                  pg_hero/home#kill_all
#        enable_query_stats POST (/:database)/enable_query_stats(.:format)        pg_hero/home#enable_query_stats
#                           POST (/:database)/explain(.:format)                   pg_hero/home#explain
#         reset_query_stats POST (/:database)/reset_query_stats(.:format)         pg_hero/home#reset_query_stats
#              system_stats GET  (/:database)/system_stats(.:format)              redirect(301, system)
#               query_stats GET  (/:database)/query_stats(.:format)               redirect(301, queries)
#                      root GET  /(:database)(.:format)                           pg_hero/home#index
#
# Routes for SolidErrors::Engine:
#   root GET    /              solid_errors/errors#index
# errors GET    /              solid_errors/errors#index
#  error GET    /:id(.:format) solid_errors/errors#show
#        PATCH  /:id(.:format) solid_errors/errors#update
#        PUT    /:id(.:format) solid_errors/errors#update
#        DELETE /:id(.:format) solid_errors/errors#destroy
#
# Routes for RailsPerformance::Engine:
#             rails_performance GET  /                      rails_performance/rails_performance#index
#    rails_performance_requests GET  /requests(.:format)    rails_performance/rails_performance#requests
#     rails_performance_crashes GET  /crashes(.:format)     rails_performance/rails_performance#crashes
#      rails_performance_recent GET  /recent(.:format)      rails_performance/rails_performance#recent
#        rails_performance_slow GET  /slow(.:format)        rails_performance/rails_performance#slow
#       rails_performance_trace GET  /trace/:id(.:format)   rails_performance/rails_performance#trace
#     rails_performance_summary GET  /summary(.:format)     rails_performance/rails_performance#summary
#     rails_performance_sidekiq GET  /sidekiq(.:format)     rails_performance/rails_performance#sidekiq
# rails_performance_delayed_job GET  /delayed_job(.:format) rails_performance/rails_performance#delayed_job
#       rails_performance_grape GET  /grape(.:format)       rails_performance/rails_performance#grape
#        rails_performance_rake GET  /rake(.:format)        rails_performance/rails_performance#rake
#      rails_performance_custom GET  /custom(.:format)      rails_performance/rails_performance#custom
#   rails_performance_resources GET  /resources(.:format)   rails_performance/rails_performance#resources
#
# Routes for Lookbook::Engine:
#                 cable      /cable                   #<ActionCable::Server::Base:0x000000014d1dea68 @config=#<ActionCable::Server::Configuration:0x000000014d29a8d0 @log_tags=[], @connection_class=#<Proc:0x0000000148c11be8 /Users/aliosm/.local/share/mise/installs/ruby/3.4.4/lib/ruby/gems/3.4.0/gems/lookbook-2.3.11/lib/lookbook/cable/cable.rb:48 (lambda)>, @worker_pool_size=4, @disable_request_forgery_protection=false, @allow_same_origin_as_host=true, @filter_parameters=[], @health_check_application=#<Proc:0x0000000148c11d50 /Users/aliosm/.local/share/mise/installs/ruby/3.4.4/lib/ruby/gems/3.4.0/gems/actioncable-8.0.2/lib/action_cable/server/configuration.rb:32 (lambda)>, @cable={"adapter" => "async"}, @mount_path=nil, @logger=#<ActiveSupport::BroadcastLogger:0x0000000149fbdea8 @broadcasts=[#<ActiveSupport::Logger:0x000000014af06860 @level=0, @progname=nil, @default_formatter=#<Logger::Formatter:0x0000000149fbe330 @datetime_format=nil>, @formatter=#<ActiveSupport::Logger::SimpleFormatter:0x0000000149fbe128 @datetime_format=nil, @thread_key="activesupport_tagged_logging_tags:13944">, @logdev=#<Logger::LogDevice:0x000000012e89c630 @shift_period_suffix="%Y%m%d", @shift_size=104857600, @shift_age=1, @filename="/Users/aliosm/Desktop/repositories/aljam3-web-app/log/development.log", @dev=#<File:/Users/aliosm/Desktop/repositories/aljam3-web-app/log/development.log>, @binmode=false, @reraise_write_errors=[], @skip_header=false, @mon_data=#<Monitor:0x0000000149fbe2b8>, @mon_data_owner_object_id=4064>, @level_override={}, @local_level_key=:logger_thread_safe_level_13936>], @progname="Broadcast", @formatter=#<ActiveSupport::Logger::SimpleFormatter:0x0000000149fbe128 @datetime_format=nil, @thread_key="activesupport_tagged_logging_tags:13944">>>, @mutex=#<Monitor:0x0000000148c119e0>, @pubsub=nil, @worker_pool=nil, @event_loop=nil, @remote_connections=nil>
#         lookbook_home GET  /                        lookbook/application#index
#   lookbook_page_index GET  /pages(.:format)         lookbook/pages#index
#         lookbook_page GET  /pages/*path(.:format)   lookbook/pages#show
#     lookbook_previews GET  /previews(.:format)      lookbook/previews#index
#      lookbook_preview GET  /preview/*path(.:format) lookbook/previews#show
#      lookbook_inspect GET  /inspect/*path(.:format) lookbook/inspector#show
# lookbook_embed_lookup GET  /embed(.:format)         lookbook/embeds#lookup
#        lookbook_embed GET  /embed/*path(.:format)   lookbook/embeds#show
#                       GET  /*path(.:format)         lookbook/application#not_found

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  get "manifest-v2" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "static#home"

  get "pdfjs", to: "pdfjs#index"

  devise_for :users

  resources :contacts, only: %i[create]
  resources :categories, only: %i[index show]
  resources :authors, only: %i[index show]

  resources :books, only: :index do
    get :search
  end

  authenticate :user, ->(user) { user.admin? } do
    mount_avo
    mount MissionControl::Jobs::Engine, at: "/jobs"
    mount PgHero::Engine, at: "/pghero"
    mount SolidErrors::Engine, at: "/solid_errors"
    mount RailsPerformance::Engine, at: "/performance"
  end

  get "/:book_id/:file_id/:page_number", to: "pages#show", as: :book_file_page, constraints: { book_id: /\d+/, file_id: /\d+/, page_number: /\d+/ }
  get "/:book_id/:file_id", to: "files#show", as: :book_file, constraints: { book_id: /\d+/, file_id: /\d+/ }
  get "/:book_id", to: "books#show", as: :book, constraints: { book_id: /\d+/ }

  mount Lookbook::Engine, at: "/lookbook" if Rails.env.development?
end
