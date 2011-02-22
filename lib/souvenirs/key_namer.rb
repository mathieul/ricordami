require "base64"

module Souvenirs
  module KeyNamer
    extend self

    def sequence(model, opts = {})
      "#{model}:seq:#{opts[:type]}"
    end

    def attributes(model, opts = {})
        "#{model}:att:#{opts[:id]}"
    end

    def unique_index(model, opts = {})
      "#{model}:udx:#{opts[:name]}"
    end

    def hash_ref(model, opts = {})
      fields = opts[:fields].join("_") + "_to_id"
      "#{model}:hsh:#{fields}"
    end

    def index(model, opts = {})
      value = encode(opts[:value])
      "#{model}:idx:#{opts[:field]}:#{value}"
    end

    def volatile_set(model, opts = {})
      info = opts[:info].dup
      op = info.shift
      if info.empty?
        info = [op]
      else
        info = ["#{op}(#{info.join(",")})"]
      end
      unless opts[:key].nil?
        key = opts[:key].sub("~:#{model}:set:", "")
        info.unshift(key)
      end
      "~:#{model}:set:#{info.join(":")}"
    end

    def temporary(model)
      lock_id = model.redis.incr("#{model}:seq:lock")
      "#{model}:val:_tmp:#{lock_id}"
    end

    def lock(model, opts = {})
      "#{model}:val:#{opts[:id]}:_lock"
    end

    def sort(model, opts = {})
      "#{model}:att:*->#{opts[:sort_by]}"
    end

    private

    def encode(value)
      Base64.encode64(value.to_s).gsub("\n", "")
    end
  end
end
