require "spec_helper"

describe Souvenirs::CanBePersistent do
  uses_constants("Tenant")

  it "is not persisted after it's just been initialized" do
    tenant = Tenant.new
    tenant.should_not be_persisted
  end

  it "is persisted after it's been successfully saved with #save" do
    tenant = Tenant.new
    tenant.save
    tenant.should be_persisted
  end
end
