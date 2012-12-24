require 'spec_helper'

describe Page do
  subject { Page.new(:url => 'http://tomsk.gov.ru/') }

  def update_html
    VCR.use_cassette(:default) do
      subject.update_html
    end
  end

  describe '#update_html' do
    before  { update_html }
    specify { Page.find_by_url('http://tomsk.gov.ru/').html.should start_with('<!DOCTYPE html>') }
  end
end
