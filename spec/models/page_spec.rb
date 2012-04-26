# encoding: utf-8
#
require 'spec_helper'

describe CmsSubscriber do
  context '#add' do
    before { subject.add 'http://example.com' }

    specify { Page.find_by_url('http://example.com').should be_persisted }
    specify {
      expect { subject.add 'http://example.com' }.to_not change(Page, :count)
    }
  end

  context '#remove' do
    before { subject.add 'http://example.com' }
    before { subject.add 'http://example.com/ru/about' }

    specify {
      expect { subject.remove 'http://example.com' }.to change(Page, :count).by(-1)
    }
  end
end
