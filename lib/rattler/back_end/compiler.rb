#
# = rattler/back_end/compiler.rb
#
# Author:: Jason Arhart
# Documentation:: Author
#
require 'rattler/back_end'

module Rattler::BackEnd
  #
  # The +Compiler+ compiles parser models into parser classes and methods.
  #
  # @author Jason Arhart
  #
  class Compiler
    
    include Rattler::Parsers
    
    # Compile rules or grammar source into a new parser subclass of +base+.
    #
    # @overload compile_parser(base, rules)
    #   Compile +rules+ into a new parser subclass of +base+.
    #   @param [Class] base the base class for the new parser class
    #   @param [Rattler::Parser::Rules] rules the rules to compile
    #   @return [Class] a new parser class
    #
    # @overload compile_parser(base, rule)
    #   Compile +rule+ into a new parser subclass of +base+.
    #   @param [Class] base the base class for the new parser class
    #   @param [Rattler::Parser::Rule] rule the rule to compile
    #   @return [Class] a new parser class
    #
    # @overload compile_parser(base, grammar)
    #   Compile +grammar+ into a new parser subclass of +base+.
    #   @param [Class] base the base class for the new parser class
    #   @param [String] grammar the grammar source to compile
    #   @return [Class] a new parser class
    #
    def self.compile_parser(base, rules_or_grammar)
      parser_class = Class.new(base)
      compile(parser_class, rules_or_grammar)
    end
    
    # Compile rules or grammar source into match methods in the module +mod+.
    def self.compile(mod, rules_or_grammar)
      self.new(mod).compile(rules_or_grammar)
    end
    
    # Compile +rules+ into match methods in the module +mod+.
    def self.compile_rules(mod, rules)
      self.new(mod).compile_rules(rules)
    end
    
    # Compile grammar +source+ into a match method in the module +mod+.
    def compile_grammar(mod, source)
      self.new(mod).compiler_grammar(source)
    end
    
    # Create a new compiler that compiles rules into match methods in the
    # given module.
    def initialize(mod)
      @mod = mod
    end
    
    # Compile the rules or grammar source into match methods in the module.
    #
    # @overload compile(rules)
    #   Compile +rules+ into match methods in the module.
    #   @param [Rattler::Parser::Rules] rules the rules to compile
    #   @return [Module] the module
    #
    # @overload compile(rule)
    #   Compile +rule+ into match methods in the module.
    #   @param [Rattler::Parser::Rule] rule the rule to compile
    #   @return [Module] the module
    #
    # @overload compile(grammar)
    #   Compile +grammar+ into match methods in the module.
    #   @param [String] grammar the grammar source to compile
    #   @return [Module] the module
    #
    def compile(_)
      case _
      when Rules then compile_rules(_)
      when Rule then compile_rules(_)
      else compile_grammar(_.to_s)
      end
    end
    
    # Compile +rules+ into match methods in the module.
    #
    # @overload compile_rules(rules)
    #   Compile +rules+ into match methods in the module.
    #   @param [Rattler::Parser::Rules] rules the rules to compile
    #   @return [Module] the module
    #
    # @overload compile_rules(rule)
    #   Compile +rule+ into match methods in the module.
    #   @param [Rattler::Parser::Rule] rule the rule to compile
    #   @return [Module] the module
    #
    def compile_rules(rules)
      assert_kind_of([Rules, Rule], rules)
      compile_model(rules.optimized)
    end
    
    # Compile +grammar+ into match methods in the module.
    # @param [String] grammar the grammar source to compile
    # @return [Module] the module
    def compile_grammar(source)
      result = Rattler::Grammar.parse!(source)
      compile_model(result.rules)
    end
    
    private
    
    def assert_kind_of(kinds, model) #:nodoc:
      unless kinds.any? {|kind| model.kind_of?(kind) }
        raise TypeError, "Expected #{model.inspect} to be a kind of #{klass}", caller
      end
    end
    
    def compile_model(model) #:nodoc:
      @mod.module_eval ParserGenerator.code_for(model)
      @mod
    end
    
  end
end
