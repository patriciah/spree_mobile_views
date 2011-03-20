require 'spree_core'
require 'spree_mobile_views_hooks'

module SpreeMobileViews
  class Engine < Rails::Engine

    config.autoload_paths += %W(#{config.root}/lib)

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), "../app/**/*_decorator*.rb")) do |c|
        Rails.env.production? ? require(c) : load(c)
      end
    end

    config.to_prepare &method(:activate).to_proc
  end
end


module SpreeBase
  module InstanceMethods
    protected

    def mobile_device?
      if cookies[:mobile_param]
        cookies[:mobile_param] == "1"
      else
        request.user_agent =~ /Mobile|webOS/
      end
    end

    def prepare_for_mobile
      cookies[:mobile_param] = params[:mobile] if params[:mobile]
    end
    
    def prepend_view_path_if_mobile
      if mobile_device?
        prepend_view_path File.join(File.dirname(__FILE__), '..', 'app', 'mobile_views')
        prepend_view_path File.join(Rails.root, 'app', 'mobile_views')
      end
    end
  end
  
  class << self

    def included_with_mobile_views(receiver)
      included_without_mobile_views(receiver)
      
      receiver.send :helper_method, 'mobile_device?'
      receiver.send :before_filter, 'prepare_for_mobile'
      receiver.send :before_filter, 'prepend_view_path_if_mobile'
    end
    
    alias_method_chain :included, :mobile_views
  
  end
end
