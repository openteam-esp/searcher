# encoding: utf-8
#
require 'spec_helper'

describe CmsSubscriber do
  subject { CmsSubscriber.new }

  def add_url(url)
    VCR.use_cassette(:default) do
      subject.add url
    end
  end

  context '#add' do
    before { add_url 'http://tomsk.gov.ru/' }

    specify {
      expect { add_url 'http://tomsk.gov.ru/' }.to_not change(Page, :count)
    }
  end

  context '#remove' do
    before { add_url 'http://tomsk.gov.ru/' }
    before { add_url 'http://tomsk.gov.ru/ru/organy_vlasti/' }

    specify {
      expect { subject.remove 'http://tomsk.gov.ru/' }.to change(Page, :count).to(0)
    }
  end
end
