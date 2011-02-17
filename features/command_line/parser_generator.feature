Feature: Parser Generator

  The "rtlr" command is used to generate a grammar module or parser class from
  a Rattler grammar file.
  
  Scenario: Getting help
    When I run "rtlr --help"
    Then the output should contain:
      """
      Usage: rtlr FILENAME [options]

          -d, --dest DIRECTORY             Specify the destination directory
          -o, --output FILENAME            Specify a different output filename
          -f, --force                      Force overwrite if the output file exists

          -h, --help                       Show this message
      """

  Scenario: Generate a grammar module
    Given a file named "binary.rtlr" with:
      """
      grammar BinaryGrammar
      expr <- [01]*
      """
    When I run "rtlr binary.rtlr"
    Then the output should contain "binary.rtlr -> binary_grammar.rb"
      And the file "binary_grammar.rb" should contain:
        """
        # @private
        module BinaryGrammar #:nodoc:
          
          # @private
          def start_rule #:nodoc:
            :expr
          end
          
          # @private
          def match_expr #:nodoc:
            a0 = []
            while r = @scanner.scan(/[01]/)
              a0 << r
            end
            a0
          end
          
        end
        """
  
  Scenario: Generate a parser class
    Given a file named "binary.rtlr" with:
      """
      require "rattler"
      parser BinaryParser < Rattler::Runtime::PackratParser
      expr <- [01]*
      """
    When I run "rtlr binary.rtlr"
    Then the output should contain "binary.rtlr -> binary_parser.rb"
      And the file "binary_parser.rb" should contain:
        """
        require "rattler"
        
        # @private
        class BinaryParser < Rattler::Runtime::PackratParser #:nodoc:
          
          # @private
          def start_rule #:nodoc:
            :expr
          end
          
          # @private
          def match_expr #:nodoc:
            a0 = []
            while r = @scanner.scan(/[01]/)
              a0 << r
            end
            a0
          end
          
        end
        """