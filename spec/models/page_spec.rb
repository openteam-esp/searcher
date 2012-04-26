# encoding: utf-8
#
require 'spec_helper'

describe Page do
  context '#self.index_url' do
    before { Page.index_url 'http://example.com' }

    specify { Page.find_by_url('http://example.com').should be_persisted }
    specify {
      expect { Page.index_url 'http://example.com' }.to_not change(Page, :count)
    }
  end

  context '#self.destroy_url' do
    before { Page.index_url 'http://example.com' }
    before { Page.index_url 'http://example.com/ru/about' }

    specify {
      expect { Page.destroy_url 'http://example.com' }.to change(Page, :count).to(0)
    }
  end

  context '#self.update_index' do
    context 'with searcher.add' do
      before { Page.should_receive(:index_url).with('http://example.com') }

      specify { Page.update_index('searcher.add', 'http://example.com') }
    end

    context 'with searcher.remove' do
      before { Page.should_receive(:destroy_url).with('http://example.com') }

      specify { Page.update_index('searcher.remove', 'http://example.com') }
    end
  end
end
