# This rake task was added by annotate_rb gem.

# Can set `ANNOTATERB_SKIP_ON_DB_TASKS` to be anything to skip this
if Rails.env.development? && ENV["ANNOTATERB_SKIP_ON_DB_TASKS"].nil?
  require "annotate_rb"

  AnnotateRb::Core.load_rake_tasks

  namespace :annotate_rb do
    desc "Annotate routes after db:migrate"
    task annotate_routes: :environment do
      Rake::Task["db:migrate"].enhance do
        AnnotateRb::Runner.run([ "routes" ])
      end
    end
  end

  Rake::Task["db:migrate"].enhance do
    Rake::Task["annotate_rb:annotate_routes"].invoke
  end
end
