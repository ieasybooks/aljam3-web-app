require "test_helper"

class ReindexMeilisearchJobTest < ModelTest
  setup do
    @job = ReindexMeilisearchJob.new
    @model = "SomeModel"
    @constantized_model = mock("model")
    @records = mock("records")
    @job.stubs(:sleep)
    @model.stubs(:constantize).returns(@constantized_model)
    @constantized_model.stubs(:where).returns(@records)
    @records.stubs(:reindex!)
  end

  test "constantizes the model name" do
    @model.expects(:constantize).returns(@constantized_model)

    @job.perform(@model, 1, 25000)
  end

  test "reindexes default-sized chunks" do
    @constantized_model.expects(:where).with(id: 1..10000).returns(@records)
    @constantized_model.expects(:where).with(id: 10001..20000).returns(@records)
    @constantized_model.expects(:where).with(id: 20001..25000).returns(@records)

    @job.perform(@model, 1, 25000)
  end

  test "uses a custom chunk size" do
    @constantized_model.expects(:where).with(id: 1..5000).returns(@records)
    @constantized_model.expects(:where).with(id: 5001..10000).returns(@records)
    @constantized_model.expects(:where).with(id: 10001..15000).returns(@records)

    @job.perform(@model, 1, 15000, 5000)
  end

  test "reindexes a final partial chunk" do
    @constantized_model.expects(:where).with(id: 1..10000).returns(@records)
    @constantized_model.expects(:where).with(id: 10001..15500).returns(@records)

    @job.perform(@model, 1, 15500, 10000)
  end

  test "uses the default queue" do
    assert_equal "default", ReindexMeilisearchJob.new.queue_name
  end
end
