require "test_helper"

class ApiV1BaseControllerTest < ModelTest
  test "joins adjacent highlighted fragments" do
    content = "<mark>علم</mark><mark>اء</mark>"

    assert_equal "<mark>علماء</mark>", format_highlights(content)
  end

  test "preserves spaces between separated highlighted words" do
    content = "<mark>ال</mark>علم <mark>نور</mark> <mark>وهدى</mark>"

    assert_equal "العلم <mark>نور&nbsp;وهدى</mark>", format_highlights(content)
  end

  private

  def format_highlights(content)
    Api::V1::BaseController.new.send(:process_meilisearch_highlights, content)
  end
end
