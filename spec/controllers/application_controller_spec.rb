# frozen_string_literal: true

require 'rails_helper'

describe ApplicationController, type: :request do
  shared_examples 'visiting multi_magic url' do
    context 'when visiting multi_magic url' do
      it 'stays at multi_magic' do
        get '/'

        expect(response.request.fullpath).to eq('/')
      end
    end
  end

  context 'when user not logged-in' do
    context 'when visiting multi_magic url' do
      it 'redirects to multi_magic' do
        get '/multi_magic'

        expect(response).to redirect_to('/')
      end
    end

    include_examples 'visiting multi_magic url'
  end

  context 'when user logged-in' do
    let(:user) { create(:user) }

    before { login(user) }

    context 'when visiting multi_magic url' do
      it 'stay at multi_magic' do
        get '/multi_magic'

        expect(response.request.fullpath).to eq('/multi_magic')
      end
    end

    include_examples 'visiting multi_magic url'
  end
end
