# encoding: utf-8

class VidrecUploader < CarrierWave::Uploader::Base
#include SessionsHelper
  after :store, :zencode 

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
 # storage :file
   storage :fog
   
  include CarrierWave::MimeTypes
  process :set_content_type


  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  #def store_dir
 #   "#{model.id.to_s}.mov"
 # end
 
  # so that stores directly in S3 bucket
 def store_dir
 end

 #def store_dir
   # "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
 #end

  #no idea why zencode requires an argument - was getting wrong number of arguments error without it
  def zencod2e(args)

            #transcode the file as a genuine mp3 via Zencoder
        Zencoder::Job.create({
                      :api_key => ENV['ZEN_API_KEY'],    
                      :input => "s3://#{ENV['BUCKET_NAME']}/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}.mov",
                      :outputs => [
                        {
                          :url => "s3://#{ENV['BUCKET_NAME']}/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}.mp3",
                          :skip_video => true,
                          :audio_codec => "mp3",
                          :public => 1,

                          }]

                          })

  end


  def zencode(args)

            #transcode the file as a genuine mp3 via Zencoder
        zencoder_response = Zencoder::Job.create({
                      :api_key => ENV['ZEN_API_KEY'],    
                      :input => "s3://#{ENV['BUCKET_NAME']}/#{model.id.to_s}.mov",
                      :outputs => [
                        {
                          :url => "s3://#{ENV['BUCKET_NAME']}/#{model.id.to_s}.mp3",
                          :skip_video => true,
                          #:clip_length => "10",
                          :audio_codec => "mp3",
                          :public => 1,

                          }]

                          })

   @model.rec_file_size = zencoder_response.body['id'] 
   @model.save

  end


  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process :scale => [50, 50]
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_white_list
  #   %w(jpg jpeg gif png)
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
   def filename
    "#{model.id.to_s}.mov" if original_filename
   end

end
