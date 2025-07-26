class FlashComponentPreview < Lookbook::Preview
  def notice
    render Components::Flash.new(flash: { "notice" => "This is a notice" })
  end

  def alert
    render Components::Flash.new(flash: { "alert" => "This is an alert" })
  end
end
