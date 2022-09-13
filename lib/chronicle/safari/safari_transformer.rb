require 'chronicle/etl'

module Chronicle
  module Safari
    class SafariTransformer < Chronicle::ETL::Transformer
      register_connector do |r|
        r.provider = 'safari'
        r.description = 'a history item'
      end

      def transform
        @data = @extraction.data
        build_browsed
      end

      def id
        # IDs from local db aren't global or stable across multiple installs 
      end

      def timestamp
        Time.parse(@data[:visit_time_utc])
      end

      private

      def build_browsed
        record = ::Chronicle::ETL::Models::Activity.new({
          verb: 'browsed',
          provider: 'safari',
          end_at: timestamp
        })
        record.dedupe_on << [:provider, :verb, :end_at]
        record.actor = build_actor
        record.involved = build_involved
        record
      end

      def build_involved
        record = ::Chronicle::ETL::Models::Entity.new({
          title: @data[:title],
          provider_url: @data[:url],
        })
        record.dedupe_on << [:provider_url]
        record
      end

      def build_actor
        record = ::Chronicle::ETL::Models::Entity.new({
          represents: 'identity',
          provider: 'icloud',
          provider_id: @extraction.meta[:icloud_account][:dsid],
          title: @extraction.meta[:icloud_account][:display_name],
          slug: @extraction.meta[:icloud_account][:id]
        })
        record.dedupe_on << [:provider, :represents, :slug]
        record
      end
    end
  end
end
