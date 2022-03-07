require 'chronicle/etl'
require 'sqlite3'

module Chronicle
  module Safari 
    class SafariExtractor < Chronicle::ETL::Extractor
      register_connector do |r|
        r.provider = 'safari'
        r.description = 'browser history'
      end

      setting :input, default: File.join(Dir.home, 'Library', 'Safari', 'history.db'), required: true
      setting :icloud_account_id
      setting :icloud_account_account_dsid
      setting :icloud_account_account_display_name

      def prepare
        @db = SQLite3::Database.new(@config.input, results_as_hash: true)
        @icloud_account = load_icloud_account
        @history = load_history
      end

      def extract
        @history.each do |entry|
          entry.transform_keys!(&:to_sym)
          yield Chronicle::ETL::Extraction.new(data: entry, meta: { icloud_account: @icloud_account } )
        end
      end

      def results_count
        @history.count
      end

      private

      def load_icloud_account
        {
          id: @config.icloud_account_id || icloud_account_info_default[:AccountID],
          dsid: @config.icloud_account_dsid || icloud_account_info_default[:AccountDSID],
          display_name: @config.icloud_account_display_name || icloud_account_info_default[:DisplayName]
        }
      end

      def icloud_account_info_default
        @icloud_account_info_default || begin
          output = `defaults read MobileMeAccounts Accounts | plutil -convert json -r -o - -- -`
          JSON.parse(output, symbolize_names: true).first
        end
      end

      def load_history
        conditions = []
        conditions << "history_visits.redirect_destination IS NULL"
        conditions << "visit_time_utc > '#{@config.since.utc}'" if @config.since
        conditions << "visit_time_utc < '#{@config.until.utc}'" if @config.until

        sql = <<~SQL
          SELECT
              *,
              datetime(visit_time + 978307200, 'unixepoch') as visit_time_utc           
          FROM
              history_visits             
          LEFT JOIN
              history_items             
                  ON history_items.id = history_item 
        SQL
        sql += " WHERE #{conditions.join(" AND ")}" if conditions.any?
        sql += " ORDER BY visit_time_utc DESC"
        sql += " LIMIT #{@config.limit}" if @config.limit

        results = @db.execute(sql)
      end
    end
  end
end
