module ImageCache
  module ApplicationHelperPatch
    def self.included(base)
      base.send(:include, Redmine::Hook::Helper) unless base.included_modules.include?(Redmine::Hook::Helper)
      base.class_eval do
        unloadable

        def url_for_mogrified_attach(attach, mogrify_commands, url_options = {})
          resized_attach = attach.mogrify(*mogrify_commands) rescue attach
          url_for(url_options.merge(:controller => 'attachments', :action => 'download', :id => resized_attach.id, :filename => resized_attach.filename))
        end
      end
    end
  end
end
