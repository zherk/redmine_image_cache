config.gem 'mini_magick'

require 'redmine'

ActionController::Dispatcher.to_prepare :image_cache do
  def include_patch_unless_included(obj_name, patch_name)
    dependencies = {'user' => ['principal'], 'application_helper' => ['redmine/themes']}
    dependencies[obj_name.underscore].try(:each) { |dep| require_dependency(dep) }
    require_dependency(obj_name.underscore)
    require(patch_name.underscore)
    obj, patch = [obj_name, patch_name].collect(&:constantize)
    obj.send(:include, patch) unless obj.included_modules.include?(patch)
  end

  include_patch_unless_included('Attachment', 'ImageCache::AttachmentPatch')
  include_patch_unless_included('ApplicationHelper', 'ImageCache::ApplicationHelperPatch')
end

Redmine::Plugin.register :redmine_image_cache do
  name 'Image Cache plugin'
  author 'Just Lest'
  description ''
  version '0.0.1'
end
