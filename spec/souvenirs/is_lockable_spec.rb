require "spec_helper"

describe Souvenirs::IsLockable do
  uses_constants("Client", "Server")

  it "can get only one lock at a time" do
    Thread::abort_on_exception = true
    ts1 = ts2 = nil
    t1 = Thread.new do
      Client.lock do
        sleep(0.01)
        ts1 = Time.now
      end
    end
    t2 = Thread.new do
      sleep(0.01)
      Client.lock do
        ts2 = Time.now
      end
    end
    t1.join
    t2.join
    ts2.should > ts1
  end
end
