module ImageCache
  module AttachmentPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        unloadable
        has_many :attaches, :class_name => 'Attachment', :as => :container, :dependent => :destroy
      end
    end

    module InstanceMethods
      # e.g. @attach.mogrify(['gravity', 'center'], ['resize', '200x200^'], ['crop', '200x200+0+0'])
      def mogrify(*commands)
        key = Digest::MD5.hexdigest(commands.to_yaml)
        attach = attaches.first(:conditions => {:description => key})
        unless attach
          image = MiniMagick::Image.from_file("#{Attachment.storage_path}/#{disk_filename}")
          image.combine_options do |c|
            commands.each do |command, *args|
              c.send(command, *args)
            end
          end

          file = File.open(image.path,"rb")
          def file.size
            File.size(path)
          end
          def file.original_filename
            File.basename(path)
          end
          def file.content_type
            nil
          end

          attach = attaches.create!(:file => file, :author => author, :description => key)
        end
        attach
      end

      def attachments_visible?(user)
        container.attachments_visible?(user)
      end
    end
  end
end
