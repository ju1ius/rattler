require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/shared_parser_examples')

describe Rattler::Runtime::RecursiveDescentParser do
  it_behaves_like 'a generated recursive descent parser'
end
