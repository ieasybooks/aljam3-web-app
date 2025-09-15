class Hotwire::Ios::PathConfigurationsController < ApplicationController
  def show
    render json: {
      settings: {
        register_with_account: false,
        require_authentication: false,
        tabs: [
          {
            title: "الرئيسية",
            path: "/",
            ios_system_image_name: "house"
          },
          {
            title: "التصنيفات",
            path: "/categories",
            ios_system_image_name: "square.grid.2x2"
          },
          {
            title: "المؤلفون",
            path: "/authors",
            ios_system_image_name: "person.3"
          },
          {
            title: "الكتب",
            path: "/books",
            ios_system_image_name: "books.vertical"
          }
        ]
      },
      rules: [
        {
          patterns: [
            "/new$",
            "/edit$",
            "/users/sign_up",
            "/users/sign_in"
          ],
          properties: {
            context: "modal"
          }
        },
        {
          patterns: [ "^/unauthorized" ],
          properties: {
            view_controller: "unauthorized"
          }
        },
        {
          patterns: [ "^/reset_app$" ],
          properties: {
            view_controller: "reset_app"
          }
        },
        {
          patterns: [ "/?sign_in_token=.*" ],
          properties: {
            presentation: "replace"
          }
        }
      ]
    }
  end
end
