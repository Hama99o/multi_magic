module EmailHelper
  # def email_image_tag(image, **options)
  #   attachments.inline[image] = File.read(Rails.root.join("app/assets/images/#{image}"))
  #   image_tag attachments[image].url, **options
  # end

  def email_redirect_to_front(path)
    ENV['APP_DOMAIN'] + path
  end
end
