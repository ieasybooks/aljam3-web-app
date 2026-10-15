require "test_helper"

class InternationalizationTestController < ActionController::Base
  include Internationalization

  def index
    render plain: "Locale: #{I18n.locale}"
  end
end

class InternationalizationControllerTest < ActionController::TestCase
  tests InternationalizationTestController

  def setup
    super
    @routes = ActionDispatch::Routing::RouteSet.new
    @routes.draw { get "index" => "internationalization_test#index" }

    @_original_locales = I18n.available_locales
    @_original_default_locale = I18n.default_locale
    @_original_locale = I18n.locale
    I18n.available_locales = [ :en, :fr, :de ]
    I18n.default_locale = :en
    I18n.locale = :en
  end

  def teardown
    I18n.available_locales = @_original_locales
    I18n.default_locale = @_original_default_locale
    I18n.locale = @_original_locale
    super
  end

  test "sets locale from URL and updates cookie and header" do
    get :index, params: { locale: "fr" }

    assert_includes response.body, "Locale: fr"
    assert_equal "fr", cookies[:locale]
    assert_equal "fr", response.headers["Content-Language"]
  end

  test "ignores invalid locale in URL param" do
    get :index, params: { locale: "es" }

    assert_includes response.body, "Locale: en"
    assert_equal "en", cookies[:locale]
    assert_equal :en, response.headers["Content-Language"]
  end

  test "sets locale from cookie if no URL param" do
    request.cookies[:locale] = "de"
    get :index

    assert_includes response.body, "Locale: de"
    assert_equal "de", cookies[:locale]
    assert_equal "de", response.headers["Content-Language"]
  end

  test "ignores invalid locale in cookie" do
    request.cookies[:locale] = "jp"
    get :index

    assert_includes response.body, "Locale: en"
    assert_equal "en", cookies[:locale]
    assert_equal :en, response.headers["Content-Language"]
  end

  test "parses and selects supported locale from Accept-Language header" do
    request.headers["HTTP_ACCEPT_LANGUAGE"] = "fr-CH,fr;q=0.9,en;q=0.8"
    get :index

    assert_includes response.body, "Locale: fr"
    assert_equal "fr", cookies[:locale]
    assert_equal "fr", response.headers["Content-Language"]
  end

  test "ignores unsupported Accept-Language header" do
    request.headers["HTTP_ACCEPT_LANGUAGE"] = "es-MX,es;q=0.9"
    get :index

    assert_includes response.body, "Locale: en"
    assert_equal "en", cookies[:locale]
    assert_equal :en, response.headers["Content-Language"]
  end

  test "ignores empty Accept-Language header" do
    request.headers["HTTP_ACCEPT_LANGUAGE"] = ""
    get :index

    assert_includes response.body, "Locale: en"
    assert_equal "en", cookies[:locale]
    assert_equal :en, response.headers["Content-Language"]
  end

  test "falls back to the default locale" do
    get :index

    assert_includes response.body, "Locale: en"
    assert_equal "en", cookies[:locale]
    assert_equal :en, response.headers["Content-Language"]
  end
end
