require 'spec_helper'

describe Page do
  subject { Page.new(:url => 'http://example.com/') }
  describe '#update_html' do
    context 'success curl response' do
      before  { Requester.stub(:new).and_return {mock(:response_status => 200, :response_body => 'html body')} }
      before { subject.update_html }
      specify { Page.find_by_url('http://example.com/').html.should == 'html body' }
    end
    context 'wrong curl response' do
      before  { Requester.stub(:new).and_return {mock(:response_status => 500, :response_body => 'there was an error')} }
      specify { expect{subject.update_html}.to raise_error }
      specify { expect{subject.update_html rescue nil}.to_not change{Page.count} }
    end
  end
end
