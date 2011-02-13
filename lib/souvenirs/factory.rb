require "base64"

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
      when :index
        value = encode(opts[:value])
        "#{opts[:model]}:idx:#{opts[:field]}:#{value}"
      when :volatile_set
        info = opts[:info]
        unless opts[:key].nil?
          key = opts[:key].sub("~:#{opts[:model]}:set:", "")
          info.unshift(key)
        end
        "~:#{opts[:model]}:set:#{info.join(":")}"
      end
    end

    private

    def encode(value)
      Base64.encode64(value.to_s).gsub("\n", "")
    end
  end
end
