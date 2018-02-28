# frozen_string_literal: true

require 'saml2/conditions'

module SAML2
  class Assertion < Message
    attr_writer :statements, :subject

    def initialize
      super
      @statements = []
      @conditions = Conditions.new
    end

    def from_xml(node)
      super
      @conditions = nil
      @statements = nil
    end

    # @return [Subject, nil]
    def subject
      if xml && !instance_variable_defined?(:@subject)
        @subject = Subject.from_xml(xml.at_xpath('saml:Subject', Namespaces::ALL))
      end
      @subject
    end

    # @return [Conditions]
    def conditions
      @conditions ||= Conditions.from_xml(xml.at_xpath('saml:Conditions', Namespaces::ALL))
    end

    # @return [Array<AuthnStatement, AttributeStatement>]
    def statements
      @statements ||= load_object_array(xml, 'saml:AuthnStatement|saml:AttributeStatement')
    end

    # (see Base#build)
    def build(builder)
      builder['saml'].Assertion(
          'xmlns:saml' => Namespaces::SAML
      ) do |assertion|
        super(assertion)

        subject.build(assertion)

        conditions.build(assertion)

        statements.each { |stmt| stmt.build(assertion) }
      end
    end
  end
end
