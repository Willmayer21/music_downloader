require 'shellwords'
class DownloadsController < ApplicationController
 protect_from_forgery with: :exception

 def new
 end

 def create
   @url = params[:youtube_url]
   if @url.present?
     begin
       # Create a temporary directory for downloads
       temp_dir = Rails.root.join('tmp', 'downloads')
       FileUtils.mkdir_p(temp_dir)

       escaped_url = Shellwords.escape(@url)
       escaped_path = Shellwords.escape("#{temp_dir}/%(title)s.%(ext)s")

       command = "yt-dlp --extract-audio --audio-format mp3 --audio-quality 0 " \
                "--no-check-certificates --force-ipv4 " \
                "--output #{escaped_path} #{escaped_url}"

       output = `#{command}`
       success = $?.success?

       if success
         # Find the downloaded file
         filename = output.match(/Destination: .*\/([^\/]+\.mp3)/i)&.captures&.first
         if filename
           file_path = File.join(temp_dir, filename)

           # Send file to browser and then delete it
           send_file(
             file_path,
             filename: filename,
             type: "audio/mpeg",
             disposition: "attachment"
           )

           # Clean up after sending
           FileUtils.rm_f(file_path)
           return
         end
       end

       flash[:alert] = "❌ Download failed. Please check the URL and try again."
     rescue => e
       flash[:alert] = "❌ Error: #{e.message}"
     ensure
       # Clean up temp directory
       FileUtils.rm_rf(temp_dir)
     end
   else
     flash[:alert] = "Please enter a URL"
   end
   redirect_to new_download_path
 end
end
