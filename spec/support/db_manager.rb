module Support
  module DbManager
    def switch_db_to_error
      @_db_mode_error = true
      error = BasicObject.new
      def error.method_missing(meth, *args, &blk)
        raise Errno::ECONNREFUSED
      end
      Souvenirs.instance_eval { @driver = error }
    end

    def switch_db_to_ok
      return unless @_db_mode_error
      Souvenirs.instance_eval { @driver = nil }
      @_db_mode_error = false
    end
  end
end
