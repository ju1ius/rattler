require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe DirectAction do
  include CombinatorParserSpecHelper
  
  describe '#parse' do
    
    context 'with a capturing parser' do
      
      subject { DirectAction[Match[/[[:digit:]]+/], '|_| _ * 2'] }
      
      context 'when the parser matches' do
        it 'applies the action binding the captured results as arguments' do
          parsing('451a').should result_in('451451').at(3)
        end
      end
      
      context 'when the parser fails' do
        it 'fails' do
          parsing('foo').should fail
        end
      end
    end
    
    context 'with a sequence parser' do
      subject do
        DirectAction[
          Sequence[Match[/[[:alpha:]]+/], Skip[Match[/\=/]], Match[/[[:digit:]]+/]],
          '|l, r| "#{r} -> #{l}"'
        ]
      end
      
      context 'when the parser matches' do
        it 'applies the action binding the captured results as arguments' do
          parsing('val=42 ').should result_in('42 -> val').at(6)
        end
      end
    end
    
    context 'with an optional parser' do
      
      subject { DirectAction[Optional[Match[/\d+/]], '|_| _'] }
      
      context 'when the nested parser matches' do
        it 'applies the action to an array containing the match' do
          parsing('451a').should result_in(['451']).at(3)
        end
      end
      
      context 'when the nested parser fails' do
        it 'applies the action to an empty array' do
          parsing('foo').should result_in([]).at(0)
        end
      end
    end
    
    context 'with a zero-or-more parser' do
      
      subject { DirectAction[ZeroOrMore[Match[/\d/]], '|_| _'] }
      
      context 'when the nested parser matches' do
        it 'applies the action to an array containing the matches' do
          parsing('451a').should result_in(['4', '5', '1']).at(3)
        end
      end
      
      context 'when the nested parser fails' do
        it 'applies the action to an empty array' do
          parsing('foo').should result_in([]).at(0)
        end
      end
    end
    
    context 'with a one-or-more parser' do
      
      subject { DirectAction[OneOrMore[Match[/\d/]], '|_| _'] }
      
      context 'when the nested parser matches' do
        it 'applies the action to an array containing the matches' do
          parsing('451a').should result_in(['4', '5', '1']).at(3)
        end
      end
      
      context 'when the nested parser fails' do
        it 'fails' do
          parsing('foo').should fail
        end
      end
    end
    
    context 'with a token parser' do
      subject { DirectAction[Token[Match[/[[:digit:]]+/]], '|_| _.to_i'] }
      
      context 'when the parser matches' do
        it 'applies the action to the matched string' do
          parsing('42 ').should result_in(42).at(2)
        end
      end
    end
    
    context 'with a non-capturing parser' do
      
      subject { DirectAction[Skip[Match[/\w+/]], '42'] }
      
      context 'when the parser matches' do
        it 'applies the action with no arguments' do
          parsing('abc123 ').should result_in(42).at(6)
        end
      end
    end
    
    context 'with a sequence of labeled parsers' do
      subject do
        DirectAction[
          Sequence[
            Label[:left, Match[/[[:alpha:]]+/]],
            Match[/\=/],
            Label[:right, Match[/[[:digit:]]+/]]
          ],
          '"#{right} -> #{left}"'
        ]
      end
      context 'when the parser matches' do
        it 'applies the action binding the labels to the results' do
          parsing('val=42 ').should result_in('42 -> val').at(6)
        end
      end
    end
  end
  
  describe '#capturing?' do
    
    context 'with a capturing parser' do
      subject { DirectAction[Match[/\w+/], ''] }
      it 'is true' do
        subject.should be_capturing
      end
    end
    
    context 'with a non-capturing parser' do
      subject { DirectAction[Skip[Match[/\s*/]], ''] }
      it 'is false' do
        subject.should_not be_capturing
      end
    end
  end
  
end
