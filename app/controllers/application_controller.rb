class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
  
  #before_filter :set_locale
  
  def signed_in_user
    redirect_to signin_url, notice: "Please sign in." unless signed_in?
  end
  
  def must_super
    redirect_to root_path unless current_user.super?
  end

  def must_super_agency
    redirect_to promotions_path if current_user.client?
  end
  
  private
  def set_locale
    I18n.locale = cookies[:locale] || I18n.default_locale
  end
  
  JS_ESCAPE_MAP = {
                    '\\'    => '\\\\',
                    '</'    => '<\/',
                    "\r\n"  => '\n',
                    "\n"    => '\n',
                    "\r"    => '\n',
                    '"'     => '\\"',
                    "'"     => "\\'" }

  def escape_javascript(str)
    return str if str.blank?
    str.gsub!(/(\\|<\/|\r\n|[\n\r"'])/) { JS_ESCAPE_MAP[$1] }
    str
  end
end
