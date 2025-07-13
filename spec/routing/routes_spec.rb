require "rails_helper"

RSpec.describe "Routes" do
  describe "Health check route" do
    it "routes GET /up to rails/health#show" do
      expect(get: "/up").to route_to(controller: "rails/health", action: "show")
    end

    it "has a named route for rails_health_check" do
      expect(rails_health_check_path).to eq("/up")
    end
  end

  describe "PWA routes" do
    describe "manifest route" do
      it "routes GET /manifest to rails/pwa#manifest" do
        expect(get: "/manifest-v2").to route_to(controller: "rails/pwa", action: "manifest")
      end

      it "has a named route for pwa_manifest" do
        expect(pwa_manifest_path).to eq("/manifest-v2")
      end
    end

    describe "service worker route" do
      it "routes GET /service-worker to rails/pwa#service_worker" do
        expect(get: "/service-worker").to route_to(controller: "rails/pwa", action: "service_worker")
      end

      it "has a named route for pwa_service_worker" do
        expect(pwa_service_worker_path).to eq("/service-worker")
      end
    end
  end

  describe "Root route" do
    it "routes GET / to static#home" do
      expect(get: "/").to route_to(controller: "static", action: "home")
    end

    it "has a named route for root" do
      expect(root_path).to eq("/")
    end
  end

  describe "Devise routes" do
    it "has devise routes for users" do
      # Test that devise_for :users is configured by checking a basic devise route
      expect(get: "/users/sign_in").to route_to(controller: "devise/sessions", action: "new")
    end
  end

  describe "PDF.js route" do
    it "routes GET /pdfjs to pdfjs#index" do
      expect(get: "/pdfjs").to route_to(controller: "pdfjs", action: "index")
    end
  end

  describe "Contacts route" do
    it "routes POST /contacts to contacts#create" do
      expect(post: "/contacts").to route_to(controller: "contacts", action: "create")
    end

    it "has a named route for contacts" do
      expect(contacts_path).to eq("/contacts")
    end
  end

  describe "Authors route" do
    it "routes GET /authors to authors#index" do
      expect(get: "/authors").to route_to(controller: "authors", action: "index")
    end

    it "has a named route for authors" do
      expect(authors_path).to eq("/authors")
    end
  end

  describe "Books route" do
    it "routes GET /books/:id/search to books#search" do
      expect(get: "/books/1/search").to route_to(controller: "books", action: "search", book_id: "1")
    end

    it "has a named route for book_search" do
      expect(book_search_path(1)).to eq("/books/1/search")
    end

    it "routes GET /:book_id to books#show" do
      expect(get: "/1").to route_to(controller: "books", action: "show", book_id: "1")
    end

    it "has a named route for book" do
      expect(book_path(1)).to eq("/1")
    end
  end

  describe "BookFiles route" do
    it "routes GET /:book_id/:file_id to files#show" do
      expect(get: "/1/1").to route_to(controller: "files", action: "show", book_id: "1", file_id: "1")
    end

    it "has a named route for book_file" do
      expect(book_file_path(1, 1)).to eq("/1/1")
    end
  end

  describe "Pages route" do
    it "routes GET /:book_id/:file_id/:page_number to pages#show" do
      expect(get: "/1/1/1").to route_to(controller: "pages", action: "show", book_id: "1", file_id: "1", page_number: "1")
    end

    it "has a named route for book_file_page" do
      expect(book_file_page_path(1, 1, 1)).to eq("/1/1/1")
    end
  end

  # Since the engines are behind authentication constraints,
  # we verify the engines are configured by checking the routes exist in the routes table.
  describe "Mounted engines" do
    describe "Avo engine" do
      it "has Avo::Engine mounted" do
        expect(Rails.application.routes.routes.to_a.any? { |route|
          route.path.spec.to_s.match?(/\/avo/)
        }).to be true
      end
    end

    describe "MissionControl::Jobs engine" do
      it "has MissionControl::Jobs::Engine mounted" do
        expect(Rails.application.routes.routes.to_a.any? { |route|
          route.path.spec.to_s.match?(/\/jobs/)
        }).to be true
      end
    end

    describe "PgHero engine" do
      it "has PgHero::Engine mounted" do
        expect(Rails.application.routes.routes.to_a.any? { |route|
          route.path.spec.to_s.match?(/\/pghero/)
        }).to be true
      end
    end

    describe "SolidErrors engine" do
      it "has SolidErrors::Engine mounted" do
        expect(Rails.application.routes.routes.to_a.any? { |route|
          route.path.spec.to_s.match?(/\/solid_errors/)
        }).to be true
      end
    end

    describe "RailsPerformance engine" do
      it "has RailsPerformance::Engine mounted" do
        expect(Rails.application.routes.routes.to_a.any? { |route|
          route.path.spec.to_s.match?(/\/performance/)
        }).to be true
      end
    end
  end
end
