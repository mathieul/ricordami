module Ricordami
  MetaField = Struct.new(:name, :operator)
end

class Symbol
  [:eq, :lt, :lte, :gt, :gte, :in].each do |name|
    define_method(name) do
      Ricordami::MetaField.new(self, name)
    end
  end
end
