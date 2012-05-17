# encoding: utf-8
require 'spec_helper'

describe HtmlPage do
  let(:content) { open("spec/html/inotomsk.ru.html").read }
  let(:html_page) { HtmlPage.new('http://openteam.ru', content) }

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

end
