require 'rattler/back_end/parser_generator'

module Rattler::BackEnd::ParserGenerator
  # @private
  module ListGenerating #:nodoc:

    def gen_basic_nested(list)
      atomic_block { gen_basic_top_level list }
    end

    def gen_basic_top_level(list)
      list.capturing? ? gen_capturing(list) : gen_skip_top_level(list)
    end

    def gen_dispatch_action_nested(list, target, method_name)
      atomic_block do
        gen_dispatch_action_top_level list, target, method_name
      end
    end

    def gen_dispatch_action_top_level(list, target, method_name)
      gen_capturing list do |a|
        dispatch_action_result target, method_name,
            :array_expr => "select_captures(#{a})"
      end
    end

    def gen_direct_action_nested(list, action)
      atomic_block do
        gen_direct_action_top_level list, action
      end
    end

    def gen_direct_action_top_level(list, action)
      gen_capturing list do |a|
        direct_action_result action, :bind_args => ["select_captures(#{a})"]
      end
    end

    def gen_skip_nested(list)
      atomic_block { gen_skip_top_level list }
    end

    protected

    def gen_capturing(list)
      (@g << "#{accumulator_name} = []").newline
      (@g << "#{saved_pos_name} = nil").newline
      @g << "while #{result_name} = "
      generate list.child, :gen_basic
      @g.block '' do
        (@g << "#{saved_pos_name} = @scanner.pos").newline
        (@g << "#{accumulator_name} << #{result_name}").newline
        @g << 'break unless '
        generate list.sep_parser, :gen_intermediate_skip
      end.newline
      @g << "@scanner.pos = #{saved_pos_name} unless #{saved_pos_name}.nil?"
      @g.newline
      gen_result(block_given? ? yield(accumulator_name) : accumulator_name)
    end

    def accumulator_name
      "a#{repeat_level}"
    end

    def saved_pos_name
      "lp#{repeat_level}"
    end

  end
end
