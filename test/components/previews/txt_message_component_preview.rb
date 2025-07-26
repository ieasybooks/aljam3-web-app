class TxtMessageComponentPreview < Lookbook::Preview
  def info
    render Components::TxtMessage.new(variant: :info, text: "This is a message")
  end

  def error
    render Components::TxtMessage.new(variant: :error, text: "This is a message")
  end
end
