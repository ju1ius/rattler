require 'rattler/compiler/parser_generator'

module Rattler::Compiler::ParserGenerator

  # @private
  class SemanticActionGenerator < ExprGenerator #:nodoc:
    include NestedSubGenerating

    def gen_basic(action, scope = ParserScope.empty)
      expr { @g << action.bindable_code.bind(scope) }
    end

    def gen_assert(action, scope = ParserScope.empty)
      expr { @g.suffix(' && true') { gen_intermediate_assert action, scope } }
    end

    def gen_disallow(action, scope = ParserScope.empty)
      @g << '!'
      gen_nested action, :basic, scope
    end

    def gen_token(action, scope = ParserScope.empty)
      @g.suffix('.to_s') { gen_nested action, :basic, scope }
    end

    def gen_skip(action, scope = ParserScope.empty)
      expr { @g.suffix('; true') { gen_top_level action, :basic, scope } }
    end

    def gen_intermediate_assert(action, scope = ParserScope.empty)
      gen_nested action, :basic, scope
    end

    def gen_intermediate_skip(action, scope = ParserScope.empty)
      gen_nested action, :basic, scope
    end

  end

  # @private
  class NestedSemanticActionGenerator < SemanticActionGenerator #:nodoc:
    include Nested
  end

  def SemanticActionGenerator.nested(*args)
    NestedSemanticActionGenerator.new(*args)
  end

  # @private
  class TopLevelSemanticActionGenerator < SemanticActionGenerator #:nodoc:
    include TopLevel
  end

  def SemanticActionGenerator.top_level(*args)
    TopLevelSemanticActionGenerator.new(*args)
  end

end
