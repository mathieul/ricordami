require "base64"

module Souvenirs
  module Factory
    extend self

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
        info = opts[:info].dup
        op = info.shift
        if info.empty?
          info = [op]
        else
          info = ["#{op}(#{info.join(",")})"]
        end
        unless opts[:key].nil?
          key = opts[:key].sub("~:#{opts[:model]}:set:", "")
          info.unshift(key)
        end
        "~:#{opts[:model]}:set:#{info.join(":")}"
      when :model_tmp
        lock_id = opts[:model].redis.incr("#{opts[:model]}:seq:lock")
        "#{opts[:model]}:val:_tmp:#{lock_id}"
      when :model_lock
        "#{opts[:model]}:val:#{opts[:id]}:_lock"
      when :model_sort
        "#{opts[:model]}:att:*->#{opts[:sort_by]}"
      end
    end

    private

    def encode(value)
      Base64.encode64(value.to_s).gsub("\n", "")
    end
  end
end
