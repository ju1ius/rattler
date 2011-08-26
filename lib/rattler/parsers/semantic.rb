require 'rattler/parsers'

module Rattler::Parsers
  # @private
  module Semantic #:nodoc:

    def bind(scope)
      bindable_code.bind(scope)
    end

    def bindable_code
      @bindable_code ||= create_bindable_code
    end

    private

    def apply(scope)
      code_bindings = {}
      scope.each_binding {|k, v| code_bindings[k] = v.inspect }
      code_captures = scope.captures.map {|_| _.inspect }
      code_scope = ParserScope.new(code_bindings, code_captures)
      eval(bind(code_scope))
    end

  end
end
