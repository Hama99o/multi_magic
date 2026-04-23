# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CompanyInfo do
  describe '.dev_emails' do
    context 'when DEV_MAIL env is not set' do
      before { stub_const('ENV', ENV.to_h.merge('DEV_MAIL' => nil)) }

      it 'returns the default fallback email array' do
        expect(described_class.dev_emails).to eq(%w[hmmshl@gmail.com])
      end
    end

    context 'when DEV_MAIL env is set to multiple emails' do
      before { stub_const('ENV', ENV.to_h.merge('DEV_MAIL' => 'a@example.com,b@example.com')) }

      it 'returns the split email array' do
        expect(described_class.dev_emails).to eq(%w[a@example.com b@example.com])
      end
    end
  end

  describe '.no_reply' do
    it 'returns the no-reply sender string' do
      expect(described_class.no_reply).to eq('Multi Magic Team <no-reply@gmail.com>')
    end
  end
end
