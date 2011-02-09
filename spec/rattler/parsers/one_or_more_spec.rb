require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe OneOrMore do
  include CombinatorParserSpecHelper
  
  describe '#parse' do
    
    context 'with a capturing parser' do
      
      subject { OneOrMore[Match[/\w/]] }
      
      context 'while the parser matches' do
        it 'matches returning the results in an array' do
          parsing('foo').should result_in(['f', 'o', 'o']).at(3)
        end
      end
      
      context 'when the parser never matches' do
        it 'fails' do
          parsing('   ').should fail
        end
      end
      
    end
    
    context 'with a non-capturing parser' do
      
      subject { OneOrMore[Skip[Match[/\w/]]] }
      
      context 'while the parser matches' do
        it 'matches returning true' do
          parsing('foo').should result_in(true).at(3)
        end
      end
      
      context 'when the parser never matches' do
        it 'fails' do
          parsing('   ').should fail
        end
      end
      
    end
    
  end
  
  describe '#capturing?' do
    
    context 'with a capturing parser' do
      subject { OneOrMore[Match[/\w+/]] }
      it 'is true' do
        subject.should be_capturing
      end
    end
    
    context 'with a non-capturing parser' do
      subject { OneOrMore[Skip[Match[/\s*/]]] }
      it 'is false' do
        subject.should_not be_capturing
      end
    end
    
  end
  
end
