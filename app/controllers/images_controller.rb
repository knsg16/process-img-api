require 'open-uri'

class ImagesController < ApplicationController
  def resize
    File.delete("small.jpg") if File.file?("small.jpg")
    width_string, url = create_params.values_at(:width, :url)
    return response_bad_request if width_string.nil? || url.nil?

    width = width_string.to_f
    return response_bad_request if width <= 0

    create_sample_jpg(url)
    @img = Magick::Image.read("sample.jpg").first
    create_resize_img(width, calc_new_height(width))
    begin
      send_file "small.jpg", type: "image/jpeg", disposition: 'inline', status: 200
    rescue => e
      logger.error(e)
      logger.error(e.backtrace.join("\n"))
      return response_internal_server_error
    end

    File.delete("sample.jpg")
  end

  private
  def create_params
    params.permit(:width, :url)
  end

  def create_sample_jpg(url)
    f = File.open("sample.jpg", "wb")
    open(url, "rb") { |temp| f.write temp.read }
    f.close
  end

  def calc_new_height(width)
    img_width = @img.columns.to_f
    img_height = @img.rows.to_f
    return img_width if width > img_width
    return width / img_width * img_height
  end

  def create_resize_img(width, height)
    new_img = @img.resize(width, height)
    new_img.write("small.jpg") { self.quality = 50 }
    new_img.destroy!
  end
end
