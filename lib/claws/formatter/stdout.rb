module Claws
  module Formatter
    class Stdout
      def self.report_violations(violations)
        violations.each do |v|
          puts "Violation: #{v.name} on #{v.file}:#{v.line}".red
          puts v.description
          puts v.snippet unless v.snippet.nil?
        end
      end
    end
  end
end
