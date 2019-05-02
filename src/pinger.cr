require "socket"

class Pinger
  VERSION = "0.1.0"

  # Host OS
  OS = `uname`.strip.downcase

  @ip : Socket::IPAddress?

  @warning : String?
  @exception : String?

  # Duration of ping request in seconds
  @duration : Int32?

  # Whether host was reachable through ICMP
  @pingable : Bool?

  getter :host, :ip, :count, :timeout, :exception, :warning, :duration, :pingable

  def initialize(@host : String, @count : Int32 = 1, @timeout : Int32 = 5)
  end

  def ping
    @ip = resolve_host(@host)

    ip = @ip
    if ip.nil?
      @pingable = false
      @exception = "DNS lookup failed for both IPv4 and IPv6"
      return false
    end

    run_ping(ip, @count, @timeout)
  end

  protected def resolve_host(host)
    addrinfo = Socket::Addrinfo.resolve(
      domain: host,
      service: "echo",
      type: Socket::Type::DGRAM,
      protocol: Socket::Protocol::UDP,
    )

    ip = addrinfo.first?.try(&.ip_address)
  end

  protected def run_ping(ip, count, timeout)
    start_time = Time.utc

    args = pargs(ip.to_s, count, timeout)

    args.unshift("-6") if ip.family == Socket::Family::INET6

    exit_status, info, err = run_ping_process(args)

    success = read_status(exit_status, info, err)

    @duration = (Time.utc - start_time).seconds if success
    @pingable = success

    success
  end

  protected def read_status(status, info, err)
    case status.exit_status
    when 0
      @warning = err.chomp if err =~ /warning/i

      if info =~ /unreachable/ix # Windows
        @exception = "host unreachable"
        false
      else
        true # Success, at least one response.
      end
    when 2
      @exception = err.chomp if err

      false # Transmission successful, no response.
    else
      if err
        @exception = err.chomp
      else
        info.each_line do |line|
          if line =~ /(timed out|could not find host|bad address|packet loss)/i
            @exception = line.chomp
            break
          end
        end
      end

      false # An error occurred
    end
  end

  protected def run_ping_process(args)
    output = IO::Memory.new
    error = IO::Memory.new

    status = Process.run(
      "ping",
      args: args,
      output: output,
      error: error,
    )

    {status, output.to_s, error.to_s}
  end

  # Get process arguments for ping
  protected def pargs(host : String, count : Int32, timeout : Int32) : Array(String)
    case OS
    when /linux/
      ["-c", count.to_s, "-W", timeout.to_s, host]
    when /aix/
      ["-c", count.to_s, "-w", timeout.to_s, host]
    when /bsd|osx|mach|darwin/
      ["-c", count.to_s, "-t", timeout.to_s, host]
    when /solaris|sunos/
      [host, timeout.to_s]
    when /hpux/i
      [host, "-n#{count.to_s}", "-m", timeout.to_s]
    when /win32|windows|msdos|mswin|cygwin|mingw/i
      ["-n", count.to_s, "-w", (timeout * 1000).to_s, host]
    else
      [host]
    end
  end
end
