require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

include Rattler::Parsers

describe Rattler::Compiler::Optimizer::SimplifyTokenMatch do

  describe '#apply' do

    context 'given a token of a match' do

      let(:parser) { Token[Match[/a/]] }

      it 'returns the match' do
        subject.apply(parser, :any).should == Match[/a/]
      end
    end

    context 'given a token of a back reference' do

      let(:parser) { Token[BackReference[:a]] }

      it 'returns the back reference' do
        subject.apply(parser, :any).should == BackReference[:a]
      end
    end

    context 'given a token of a token' do

      let(:parser) { Token[Token[Apply[:foo]]] }

      it 'returns the inner token' do
        subject.apply(parser, :any).should == Token[Apply[:foo]]
      end
    end
  end

  describe '#applies_to?' do

    context 'given a token of a match' do

      let(:parser) { Token[Match[/a/]] }

      it 'returns true' do
        subject.applies_to?(parser, :any).should be_true
      end
    end

    context 'given a token of a back reference' do

      let(:parser) { Token[BackReference[:a]] }

      it 'returns true' do
        subject.applies_to?(parser, :any).should be_true
      end
    end

    context 'given a token of a token' do

      let(:parser) { Token[Token[Apply[:foo]]] }

      it 'returns true' do
        subject.applies_to?(parser, :any).should be_true
      end
    end

    context 'given a token of something other than a terminal parser' do

      let(:parser) { Token[Apply[:foo]] }

      it 'returns false' do
        subject.applies_to?(parser, :any).should be_false
      end
    end

    context 'given something other than a token' do

      let(:parser) { Apply[:foo] }

      it 'returns false' do
        subject.applies_to?(parser, :any).should be_false
      end
    end
  end

end
