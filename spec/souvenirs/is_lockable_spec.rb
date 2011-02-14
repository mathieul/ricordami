require "spec_helper"

describe Souvenirs::IsLockable do
  uses_constants("Client")

  it "can get only one model lock at a time" do
    5.times do
      ts1 = ts2 = nil
      client = Client.create
      t1 = Thread.new do
        client.lock! { sleep(0.01); ts1 = Time.now }
      end
      t2 = Thread.new do
        sleep(0.01)
        client.lock! { ts2 = Time.now }
      end
      t1.join
      t2.join
      ts2.should > ts1
    end
  end

  it "can get one lock per instance" do
    5.times do
      c1ok, c2ok = false, false
      client = Client.create
      other = Client.create
      t1 = Thread.new do
        client.lock! do
          c1ok = true
          sleep 0.05 until c2ok
        end
      end
      t2 = Thread.new do
        other.lock! do
          c2ok = true
          sleep 0.05 until c1ok
        end
      end
      t1.join
      t2.join
      c2ok.should be_true
    end
  end
end
