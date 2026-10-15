require "test_helper"

class GenerateSitemapJobTest < ModelTest
  setup do
    @job = GenerateSitemapJob.new
    @sitemap_task = mock("sitemap_task")
    Rake::Task.stubs(:[]).with("sitemap:refresh").returns(@sitemap_task)
    @sitemap_task.stubs(:invoke)
    Rake::Task.stubs(:task_defined?).with("sitemap:refresh").returns(true)
    Rails.application.stubs(:load_tasks)
  end

  test "loads tasks and invokes sitemap refresh" do
    @job.expects(:load_rake_tasks_once)
    @sitemap_task.expects(:invoke)

    @job.perform
  end

  test "does not reload already loaded tasks" do
    Rails.application.expects(:load_tasks).never

    @job.send(:load_rake_tasks_once)
  end

  test "loads Rails tasks when the sitemap task is missing" do
    Rake::Task.stubs(:task_defined?).with("sitemap:refresh").returns(false)
    Rails.application.expects(:load_tasks)

    @job.send(:load_rake_tasks_once)
  end

  test "uses the sitemap queue" do
    assert_equal "sitemap", GenerateSitemapJob.queue_name
  end
end
