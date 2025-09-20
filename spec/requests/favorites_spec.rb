require 'rails_helper'

RSpec.describe "Favorites" do
  let(:user) { create(:user) }
  let(:book) { create(:book) }

  describe 'GET /favorites' do
    context 'when user is signed in' do
      before { sign_in user }

      it 'renders the favorites index page' do
        get favorites_path
        expect(response).to have_http_status(:ok)
      end

      it 'displays user favorites' do
        user.favorites.create!(book: book)
        get favorites_path
        expect(response.body).to include(book.title)
      end
    end

    context 'when user is not signed in' do
      it 'redirects to sign in' do
        get favorites_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'POST /books/:book_id/favorites' do
    context 'when user is signed in' do
      before { sign_in user }

      it 'creates a new favorite' do
        expect {
          post book_favorites_path(book_id: book.id)
        }.to change(Favorite, :count).by(1)
      end

      it 'responds with turbo stream' do
        post book_favorites_path(book_id: book.id), as: :turbo_stream
        expect(response).to have_http_status(:ok)
      end

      it 'returns correct content type for turbo stream' do
        post book_favorites_path(book_id: book.id), as: :turbo_stream
        expect(response.content_type).to eq('text/vnd.turbo-stream.html; charset=utf-8')
      end

      it 'responds with HTML redirect' do
        post book_favorites_path(book_id: book.id)
        expect(response).to redirect_to(books_path)
      end

      it 'associates the favorite with the correct user and book' do
        post book_favorites_path(book_id: book.id)
        favorite = Favorite.last
        expect(favorite.user).to eq(user)
      end

      it 'associates the favorite with the correct book' do
        post book_favorites_path(book_id: book.id)
        favorite = Favorite.last
        expect(favorite.book).to eq(book)
      end

      context 'when favorite already exists' do
        before { user.favorites.create!(book: book) }

        it 'does not create a duplicate favorite due to find_or_initialize_by' do
          expect {
            post book_favorites_path(book_id: book.id)
          }.not_to change(Favorite, :count)
        end

        it 'responds with success for turbo stream' do
          post book_favorites_path(book_id: book.id), as: :turbo_stream
          expect(response).to have_http_status(:ok)
        end

        it 'responds with HTML redirect for existing favorite' do
          post book_favorites_path(book_id: book.id)
          expect(response).to redirect_to(books_path)
        end
      end

      context 'when favorite save fails' do
        let(:favorite_double) { instance_double(Favorite, save: false, persisted?: false) }

        before do
          allow(user.favorites).to receive(:find_or_initialize_by).and_return(favorite_double)
        end

        it 'responds with unprocessable content for turbo stream' do
          post book_favorites_path(book_id: book.id), as: :turbo_stream
          expect(response).to have_http_status(:unprocessable_content)
        end

        it 'redirects with alert for HTML format' do
          post book_favorites_path(book_id: book.id)
          expect(response).to redirect_to(books_path)
        end

        it 'sets alert flash message for HTML format' do
          post book_favorites_path(book_id: book.id)
          expect(flash[:alert]).to be_present
        end
      end

      context 'when book does not exist' do
        it 'returns 404 not found' do
          post book_favorites_path(book_id: 999)
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when user is not signed in' do
      it 'redirects to sign in' do
        post book_favorites_path(book_id: book.id)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'DELETE /books/:book_id/favorites/:id' do
    context 'when user is signed in' do
      before { sign_in user }

      context 'when favorite exists' do
        let!(:favorite) { user.favorites.create!(book: book) }

        it 'destroys the favorite' do
          expect {
            delete book_favorite_path(book_id: book.id, id: favorite.id)
          }.to change(Favorite, :count).by(-1)
        end

        it 'responds with turbo stream' do
          delete book_favorite_path(book_id: book.id, id: favorite.id), as: :turbo_stream
          expect(response).to have_http_status(:ok)
        end

        it 'returns correct content type for turbo stream' do
          delete book_favorite_path(book_id: book.id, id: favorite.id), as: :turbo_stream
          expect(response.content_type).to eq('text/vnd.turbo-stream.html; charset=utf-8')
        end

        it 'responds with HTML redirect' do
          delete book_favorite_path(book_id: book.id, id: favorite.id)
          expect(response).to redirect_to(books_path)
        end
      end

      context 'when favorite does not exist' do
        it 'does not raise an error' do
          expect {
            delete book_favorite_path(book_id: book.id, id: 999)
          }.not_to raise_error
        end

        it 'responds with unprocessable content for non-existent favorite' do
          delete book_favorite_path(book_id: book.id, id: 999), as: :turbo_stream
          expect(response).to have_http_status(:unprocessable_content)
        end

        it 'redirects with alert for HTML format when favorite not found' do
          delete book_favorite_path(book_id: book.id, id: 999)
          expect(response).to redirect_to(books_path)
        end

        it 'sets alert flash message when favorite not found' do
          delete book_favorite_path(book_id: book.id, id: 999)
          expect(flash[:alert]).to be_present
        end
      end

      context 'when book does not exist' do
        it 'returns 404 not found' do
          delete book_favorites_path(book_id: 999)
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when user is not signed in' do
      it 'redirects to sign in' do
        delete book_favorite_path(book_id: book.id, id: 1)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
