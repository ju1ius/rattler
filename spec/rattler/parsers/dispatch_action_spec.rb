require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe DispatchAction do
  include CombinatorParserSpecHelper
  
  describe '#parse' do
    
    context 'with a capturing parser' do
      subject do
        DispatchAction[
          Sequence[Match[/[[:alpha:]]+/], Match[/\=/], Match[/[[:digit:]]+/]]
        ]
      end
      
      context 'when the parser matches' do
        it 'applies the action to the result' do
          parsing('val=42').
          should result_in(Rattler::Runtime::ParseNode.parsed(['val','=','42'])).at(6)
        end
      end
      
      context 'when the parser fails' do
        it 'fails' do
          parsing('val=x').should fail
        end
      end
    end
    
    context 'with a token parser' do
      
      subject { DispatchAction[Token[Match[/\w+/]]] }
      
      context 'when the parser matches' do
        it 'applies the action to the matched string' do
          parsing('foo ').
          should result_in(Rattler::Runtime::ParseNode.parsed(['foo'])).at(3)
        end
      end
    end
    
    context 'with a non-capturing parser' do
      
      subject { DispatchAction[Skip[Match[/\w+/]]] }
      
      context 'when the parser matches' do
        it 'applies the action to an empty array' do
          parsing('abc123 ').
          should result_in(Rattler::Runtime::ParseNode.parsed([])).at(6)
        end
      end
    end
    
    context 'with a choice of labeled parsers' do
      subject do
        DispatchAction[
          Choice[
            Label[:word, Match[/[[:alpha:]]+/]],
            Label[:num, Match[/[[:digit:]]+/]]
          ]
        ]
      end
      it 'applies the action with a labeled result' do
        parsing('foo ').should result_in(
          Rattler::Runtime::ParseNode.parsed(['foo'], :labeled => {:word => 'foo'}))
        parsing('42 ').should result_in(
          Rattler::Runtime::ParseNode.parsed(['42'], :labeled => {:num => '42'}))
      end
    end
    
    context 'with a sequence of labeled parsers' do
      subject do
        DispatchAction[
          Sequence[
            Label[:name, Match[/[[:alpha:]]+/]],
            Match[/\=/],
            Label[:value, Match[/[[:digit:]]+/]]
          ]
        ]
      end
      context 'when the parser matches' do
        it 'applies the action binding the labels to the results' do
          parsing('val=42 ').
          should result_in(Rattler::Runtime::ParseNode.parsed(['val','=','42'],
                                  :labeled => {:name => 'val', :value => '42'}))
        end
      end
    end
  end
  
  describe '#capturing?' do
    
    context 'with a capturing parser' do
      subject { DispatchAction[Match[/\w+/]] }
      it 'is true' do
        subject.should be_capturing
      end
    end
    
    context 'with a non-capturing parser' do
      subject { DispatchAction[Skip[Match[/\s*/]]] }
      it 'is false' do
        subject.should_not be_capturing
      end
    end
  end
  
end
