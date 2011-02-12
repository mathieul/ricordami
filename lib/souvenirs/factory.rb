module Souvenirs
  module Factory
    extend self

    def id_generator(model)
      key = key_name(:sequence, :type => "id", :model => model)
      Proc.new { Souvenirs.driver.incr(key) }
    end

    def key_name(type, opts = {})
      case type
      when :sequence
        "#{opts[:model]}:seq:#{opts[:type]}"
      when :attributes
        "#{opts[:model]}:att:#{opts[:id]}"
      when :unique_index
        "#{opts[:model]}:udx:#{opts[:name]}"
      when :hash_ref
        fields = opts[:fields].join("_") + "_to_id"
        "#{opts[:model]}:hsh:#{fields}"
      end
    end
  end
end
