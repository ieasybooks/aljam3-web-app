class Api::V1::SearchController < Api::V1::BaseController
  def index
    @pagy, @pages = pagy_meilisearch(
      Page.pagy_search(
        params[:q],
        filter:,
        highlight_pre_tag: "<mark>",
        highlight_post_tag: "</mark>"
      ),
      limit: [ params[:limit].presence&.to_i || 20, 1000 ].min
    )
  end

  private

  def filter
    expression = [ "(hidden = false OR hidden NOT EXISTS)" ]
    expression << "library = #{params[:library].to_i}" if params[:library].present?
    expression << "book IN [#{Array(params[:books]).map(&:to_i).join(",")}]" if params[:books].present?
    expression << "author IN [#{Array(params[:authors]).map(&:to_i).join(",")}]" if params[:authors].present?
    expression << "category IN [#{Array(params[:categories]).map(&:to_i).join(",")}]" if params[:categories].present?
    expression.join(" AND ")
  end
end
