require "./helper"

describe Pinger do
  it "should ping IPv4" do
    pinger = Pinger.new("127.0.0.1")
    result = pinger.ping

    # expect(@general_failure).to eq([])
    # expect(pinger.pingable).to eq(true)
    # expect(pinger.exception).to eq(nil)
    # expect(pinger.warning).to eq(nil)
    # expect(pinger.duration).to be > 0
  end

  it "should ping IPv6" do
    pinger = Pinger.new("::1")
    result = pinger.ping

    # expect(@general_failure).to eq([])
    # expect(pinger.pingable).to eq(true)
    # expect(pinger.exception).to eq(nil)
    # expect(pinger.warning).to eq(nil)
    # expect(pinger.duration).to be > 0
  end

  it "should ping localhost after resolving using DNS" do
    pinger = Pinger.new("localhost")
    result = pinger.ping

    # expect(@general_failure).to eq([])
    # expect(pinger.pingable).to eq(true)
    # expect(pinger.exception).to eq(nil)
    # expect(pinger.warning).to eq(nil)
    # expect(pinger.duration).to be > 0
  end
end
