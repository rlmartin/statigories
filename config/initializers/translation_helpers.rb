module ActionView
  module Helpers
    module TranslationHelper
      alias :_translate :translate

      def translate(*args)
        options = args.extract_options!
        options.each_key { |key| options[key] = h(options[key]) unless options[key].html_safe? }
        _translate(args[0], options)
      end

      def t(*args)
        translate(args[0], args.extract_options!)
      end
    end
  end
end
