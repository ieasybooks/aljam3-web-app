# frozen_string_literal: true

class Components::PdfContent < Components::Base
  def initialize(file:, page:)
    @file = file
    @page = page
  end

  def view_template
    turbo_frame_tag "pdf-frame-#{@page.id}" do
      Card(
        class: "sm:max-w-1/2 flex-1 flex flex-col overflow-hidden",
        data: {
          top_controls_target: "pdfContent"
        }
      ) do
        iframe(
          src: pdfjs_path(file: @file.pdf_url, anchor: "page=#{@page.number}"),
          class: "w-full h-full",
          data: {
            pdf_viewer_target: "iframe",
            top_controls_target: "iframe",
            bottom_controls_target: "iframe"
          }
        )
      end
    end
  end

  private

  def pdfjs_path(file:, anchor: nil)
    path = "/pdfjs?file=#{CGI.escape(file)}"
    path += "##{anchor}" if anchor
    path
  end
end