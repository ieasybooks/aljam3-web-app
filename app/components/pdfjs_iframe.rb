class Components::PdfjsIframe < Components::Base
  def view_template
    turbo_frame_tag :pdfjs_iframe do
      iframe(
        src: params[:src],
        class: "w-full h-full",
        data: {
          pdf_viewer_target: "iframe",
          top_controls_target: "iframe",
          bottom_controls_target: "iframe",
          cropperjs_target: "iframe"
        }
      )
    end
  end
end
