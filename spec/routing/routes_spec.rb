require 'rails_helper'

RSpec.describe 'Routes' do
  describe 'Health check route' do
    it 'routes GET /up to rails/health#show' do
      expect(get: '/up').to route_to(controller: 'rails/health', action: 'show')
    end

    it 'has a named route for rails_health_check' do
      expect(rails_health_check_path).to eq('/up')
    end
  end

  describe 'PWA routes' do
    describe 'manifest route' do
      it 'routes GET /manifest to rails/pwa#manifest' do
        expect(get: '/manifest').to route_to(controller: 'rails/pwa', action: 'manifest')
      end

      it 'has a named route for pwa_manifest' do
        expect(pwa_manifest_path).to eq('/manifest')
      end
    end

    describe 'service worker route' do
      it 'routes GET /service-worker to rails/pwa#service_worker' do
        expect(get: '/service-worker').to route_to(controller: 'rails/pwa', action: 'service_worker')
      end

      it 'has a named route for pwa_service_worker' do
        expect(pwa_service_worker_path).to eq('/service-worker')
      end
    end
  end

  describe 'Root route' do
    it 'routes GET / to pages#home' do
      expect(get: '/').to route_to(controller: 'pages', action: 'home')
    end

    it 'has a named route for root' do
      expect(root_path).to eq('/')
    end
  end

  describe 'Devise routes' do
    it 'has devise routes for users' do
      # Test that devise_for :users is configured by checking a basic devise route
      expect(get: '/users/sign_in').to route_to(controller: 'devise/sessions', action: 'new')
    end
  end

  describe 'Mounted engines' do
    describe 'MissionControl::Jobs engine' do
      it 'has MissionControl::Jobs::Engine mounted' do
        # Since the engine is behind authentication constraints,
        # we verify the engine is configured by checking the route exists in the routes table
        expect(Rails.application.routes.routes.to_a.any? { |route|
          route.path.spec.to_s.match?(/\/jobs/)
        }).to be true
      end
    end

    describe 'SolidErrors engine' do
      it 'has SolidErrors::Engine mounted' do
        # Since the engine is behind authentication constraints,
        # we verify the engine is configured by checking the route exists in the routes table
        expect(Rails.application.routes.routes.to_a.any? { |route|
          route.path.spec.to_s.match?(/\/solid_errors/)
        }).to be true
      end
    end
  end
end
