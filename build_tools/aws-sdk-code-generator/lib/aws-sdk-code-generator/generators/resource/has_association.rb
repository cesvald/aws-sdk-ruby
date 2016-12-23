module AwsSdkCodeGenerator
  module Generators
    module Resource
      class HasAssociation < Dsl::Method

        # @option options [required, String] :name
        # @option options [required, Hash] :has
        def initialize(options = {})
          @has = options.fetch(:has)
          @data_identifiers = data_identifiers
          @nullable = !@data_identifiers.empty?
          @plural = Api.plural?(@has['resource'])
          super(underscore(options.fetch(:name)))
          apply_params
          apply_code
          returns(return_type)
        end

        private

        def return_type
          if @plural
            collection_type
          elsif @nullable
            "#{type}, nil"
          else
            type
          end
        end

        def apply_params
          (@has['resource']['identifiers'] || []).each do |identifier|
            if identifier['source'] == 'input'
              param(underscore(identifier['target']), type:'String')
            end
          end
        end

        def type
          @has['resource']['type']
        end

        def collection_type
          "#{type}::Collection"
        end

        def apply_code
          if @plural
            code("batch = []")
            code(BatchBuilder.new(resource: @has['resource']))
            code("#{collection_type}.new([batch], size: batch.size)")
          elsif @nullable # singular association
            code do |c|
              c << "if #{null_checks}"
              c.indent do |c2|
                c2 << builder
              end
              c << "else"
              c << "  nil"
              c << "end"
            end
          else
            code(builder)
          end
        end

        def builder
          Builder.new(resource: @has['resource'], request_made: false)
        end

        def data_identifiers
          identifiers = []
          (@has['resource']['identifiers'] || []).each do |i|
            identifiers << i if i['source'] == 'data'
          end
          identifiers
        end

        def null_checks
          @data_identifiers.map do |i|
            ValueSource.new(i)
          end.join(' && ')
        end

      end
    end
  end
end
