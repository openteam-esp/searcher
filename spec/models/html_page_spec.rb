# encoding: utf-8
require 'spec_helper'

describe HtmlPage do
  subject { HtmlPage.new('http://openteam.ru') }

  before { subject.stub(:html).and_return(open("spec/html/inotomsk.ru.html").read) }

  its(:html) { should =~ /<html/}
  its(:text) { should_not =~ /</}
  its(:text) { should =~ /Студенты ТУСУРа приняли участие/ }
  its(:text) { should_not =~ /Точка зрения/ }
  its(:text) { should_not =~ /В мире/ }
end
