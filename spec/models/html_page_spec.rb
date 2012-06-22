# encoding: utf-8
require 'spec_helper'

describe HtmlPage do
  let(:html_path) { "spec/html/inotomsk.ru.html" }
  let(:content) { open(html_path).read }
  let(:html_page) { HtmlPage.new('http://openteam.ru', content) }

  subject { html_page }

  its(:entry_date) { should be_nil }

  describe '#html' do
    subject { html_page.html }
    it { should =~ /<html/}
  end

  describe '#text' do
    subject { html_page.text }
    it { should_not =~ /</}
    it { should =~ /Студенты ТУСУРа приняли участие/ }
    it { should_not =~ /Точка зрения/ }
    it { should_not =~ /В мире/ }
    context 'should correctly remove <br /> and insert spaces between tags' do
      let(:content) { "<div class='index'><p>Строка<br />разрывается</p><p>по разному</p></div>" }
      it { should == "Строка разрывается по разному" }
    end
  end

  describe '#title' do
    subject { html_page.title }
    it { should == 'Главная' }
  end

  context 'with entry date' do
    let(:html_path) { "spec/html/tomsk.gov.ru/news.html" }
    its(:entry_date) { should == DateTime.parse('22.06.2012 09:53:43 +0700') }
  end

end
