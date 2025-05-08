module Claws
  module Formatter
    class Github
      def self.report_violations(violations)
        violations.each do |v|
          printf(
            "::%<severity>s file=%<file>s,line=%<line>d::%<message>s\n",
            severity: :error,
            file: v.file,
            line: v.line,
            message: v.description.gsub("\n", "%0A")
          )
        end
      end
    end
  end
end
