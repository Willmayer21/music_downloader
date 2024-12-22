require 'shellwords'

class DownloadsController < ApplicationController
  protect_from_forgery with: :exception

  def new
  end

  def create
    @url = params[:youtube_url]

    if @url.present?
      begin
        download_directory = File.expand_path("~/Downloads")

        escaped_url = Shellwords.escape(@url)
        escaped_path = Shellwords.escape("#{download_directory}/%(title)s.%(ext)s")

        command = "yt-dlp --extract-audio --audio-format mp3 --audio-quality 0 " \
                 "--no-check-certificates --force-ipv4 " \
                 "--output #{escaped_path} #{escaped_url}"

        output = `#{command}`
        success = $?.success?

        if success
          filename = output.match(/Destination: .*\/([^\/]+\.mp3)/i)&.captures&.first
          if filename
            flash[:notice] = "✅ Downloaded: #{filename}"
          else
            flash[:notice] = "✅ Download completed!"
          end
        else
          flash[:alert] = "❌ Download failed. Please check the URL and try again."
        end
      rescue => e
        flash[:alert] = "❌ Error: #{e.message}"
      end
    else
      flash[:alert] = "Please enter a URL"
    end

    redirect_to new_download_path
  end
end
