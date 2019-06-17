require "./helper"

describe Pinger do
  it "should ping IPv4" do
    pinger = Pinger.new("127.0.0.1")
    result = pinger.ping

    result.should be_true
    pinger.pingable.should be_true
    pinger.exception.should be_nil
    pinger.warning.should be_nil
    pinger.duration.try(&.should be > 0)
  end

  it "should not raise error on bang method success" do
    pinger = Pinger.new("127.0.0.1").ping!

    pinger.pingable.should be_true
    pinger.exception.should be_nil
    pinger.warning.should be_nil
    pinger.duration.try(&.should be > 0)
  end

  it "should raise error on bang method failure" do
    expect_raises(Pinger::Error) { Pinger.new("192.0.0.2").ping! }
  end

  travis_guard "should ping IPv6" do
    pinger = Pinger.new("::1")
    result = pinger.ping

    result.should be_true
    pinger.pingable.should be_true
    pinger.exception.should be_nil
    pinger.warning.should be_nil
    pinger.duration.try(&.should be > 0)
  end

  it "should ping localhost after resolving using DNS" do
    pinger = Pinger.new("localhost")
    result = pinger.ping

    result.should be_true
    pinger.pingable.should be_true
    pinger.exception.should be_nil
    pinger.warning.should be_nil
    pinger.duration.try(&.should be > 0)
  end
end
