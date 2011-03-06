module Support
  module DbManager
    def switch_db_to_error
      @_db_mode_error = true
      error = Object.new
      def error.method_missing(meth, *args, &blk)
        raise Errno::ECONNREFUSED
      end
      Ricordami.instance_eval { @redis = error }
    end

    def switch_db_to_ok
      return unless @_db_mode_error
      Ricordami.instance_eval { @redis = nil }
      @_db_mode_error = false
    end
  end
end
