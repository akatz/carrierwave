# encoding: utf-8
begin
  require 'dropbox'
rescue LoadError
  raise "You don't have the 'dropbox' gem installed. "
end

module CarrierWave
  module Storage

    class DropBox < Abstract

      class File

        def initialize(uploader, base, path)
          @uploader = uploader
          @path = path
          @base = base
        end
        
        def authorized?
          connection.authorized?
        end

        def authorize_url
          unless authorized?
            connection.authorize_url
          else
            nil
          end
        end

        ##
        # Returns the current path of the file
        #
        # === Returns
        #
        # [String] A path
        #
        def path
          @path
        end

        ##
        # Reads the contents of the file
        #
        # === Returns
        #
        # [String] contents of the file
        #
        def read
          connection.download(@path)
        end

        ##
        # Remove the file from DropBox
        #
        def delete
          connection.delete(@path)
        end

        ##
        # Returns the url on DropBox's service
        #
        # === Returns
        #
        # [String] file's url
        #

        def url
            session.url(@path)
        end

        def store(file)
          connection.upload(::File.open(file.file),path)
        end


        def size
           metadata.size.to_i
        end

        # Headers returned from file retrieval
        def metadata 
          @metadata ||=  connection.metadata(@path)
        end

      private

        def connection
          @base.connection
        end

      end

      ##
      # Store the file on dropbox
      #
      # === Parameters
      #
      # [file (CarrierWave::SanitizedFile)] the file to store
      #
      # === Returns
      #
      # [CarrierWave::Storage::DropBox::File] the stored file
      #
      def store!(file)
        f = CarrierWave::Storage::DropBox::File.new(uploader, self, uploader.store_path)
        f.store(file)
        f
      end

      # Do something to retrieve the file
      #
      # @param [String] identifier uniquely identifies the file
      #
      # [identifier (String)] uniquely identifies the file
      #
      # === Returns
      #
      # [CarrierWave::Storage::DropBox::File] the stored file
      #
      def retrieve!(identifier)
        CarrierWave::Storage::DropBox::File.new(uploader, self, uploader.store_path(identifier))
      end

      def connection
        @connection ||= uploader.connection
        @connection.mode = :dropbox
        unless @connection.authorized? 
          puts @connection.authorize_url
          gets
          @connection.authorize
          @connection
        else
          @connection
        end
      end

    end # S3
  end # Storage
end # CarrierWave


