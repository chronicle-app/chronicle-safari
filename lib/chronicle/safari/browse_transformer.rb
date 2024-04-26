require 'chronicle/etl'
require 'chronicle/models'

module Chronicle
  module Safari
    class BrowseTransformer < Chronicle::ETL::Transformer
      register_connector do |r|
        r.source = :safari
        r.type = :browse
        r.strategy = :local_db
        r.description = 'a history item'
        r.from_schema = :extraction
        r.to_schema = :chronicle
      end

      def transform(record)
        build_browse(record.data, record.extraction.meta[:my_icloud_account])
      end

      private

      def build_browse(data, icloud_account)
        Chronicle::Models::ViewAction.new do |r|
          r.source = 'safari'
          r.end_time = Time.parse(data[:visit_time_utc])
          r.agent = build_agent(icloud_account)
          r.object = build_site(data)
        end
      end

      def build_site(data)
        Chronicle::Models::Thing.new do |r|
          r.name = data[:title]
          r.url = data[:url]

          r.dedupe_on = [[:url]]
        end
      end

      def build_agent(icloud_account)
        Chronicle::Models::Person.new do |r|
          r.name = icloud_account[:display_name]
          r.source = 'icloud'
          r.slug = icloud_account[:id]
          r.source_id = icloud_account[:dsid]
          r.dedupe_on = [%i[type source source_id]]
        end
      end
    end
  end
end
