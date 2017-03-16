require 'nokogiri'

module I18n
  module ASF
    class Processor
      SKIP_TAG_NAMES = %w(dnt desc)

      def self.shared
        @processor ||= self.new
      end

      def self.process_document(document)
        self.shared.process_document(document)
      end

      def process_document(document, output={})
        if document.is_a?(String) || document.respond_to?(:read)
          document = Nokogiri::XML(document) or raise "Document could not be parsed"
        end

        document.children.each do |node|
          next if SKIP_TAG_NAMES.include?(node.name)

          if node.name == 'str'
            key, value = process_string_node(node)
            output[key] = value
          elsif node.name == 'set'
            key = node[:name] or raise "Set missing name attribute at line #{string_node.line}"
            output[key] = process_document(node, {})
          elsif node.name == 'asf'
            if _locale = node["locale"]
              output["_locale"] = _locale
            end

            process_document(node, output)
          end
        end

        output
      end

      def process_string_node(string_node)
        key = string_node[:name] or raise "Str missing name attribute at line #{string_node.line}"
        value = ""

        string_node.at("val").children.each do |node|
          value << process_content(node)
          next
        end

        [key, value]
      end

      def named_parameter(node)
        raise "Param tag missing `name' attribute at line #{node.line}" unless node[:name]
        raise "Param name #{node[:name].inspect} is too short" unless node[:name].length >= 1
        "%{#{node[:name]}}"
      end

      def process_content(node, output="")
        current_tag = nil

        if node.content.nil?
          # Special case - likely HTML entity
          output << node.to_s
        elsif node.name == "param"
          output << named_parameter(node)
        elsif node.children.count == 0
          output << node.content
        else
          # If element name isn't on the blacklist, turn it back to a string,
          # append its opening tag, and remember its name so the tag can be
          # closed later.
          unless SKIP_TAG_NAMES.include?(node.name)
            output << node.to_s.split(">").first + ">"
            current_tag = node.name
          end

          node.children.each do |part|
            if part.name == "param"
              output << named_parameter(part)
            elsif part.name == "dnt"
              process_content(part, output)
            elsif part.text?
              output << part.content
            else
              raise "Unhandled node type #{node} on line #{node.line}"
            end
          end

          if current_tag
            output << "</#{current_tag}>"
            current_tag = nil
          end
        end

        output
      end
    end
  end
end