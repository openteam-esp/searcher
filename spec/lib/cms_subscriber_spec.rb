# encoding: utf-8
#
require 'spec_helper'

describe CmsSubscriber do
  subject { CmsSubscriber.new }
  before  { Requester.stub(:new).and_return {mock(:response_status => 200, :response_body => 'html body')} }

  context '#add' do
    before { subject.add 'http://example.com/' }

    specify {
      expect { subject.add 'http://example.com/' }.to_not change(Page, :count)
    }
  end

  context '#remove' do
    before { subject.add 'http://example.com/' }
    before { subject.add 'http://example.com/ru/about/' }

    specify {
      expect { subject.remove 'http://example.com/' }.to change(Page, :count).to(0)
    }
  end
end
