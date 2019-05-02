require "socket"

class Pinger
  VERSION = "0.1.0"

  # Host OS
  OS = `uname`.strip.downcase

  @ip : Socket::IPAddress?

  @warning : String?
  @exception : String?

  # Duration of ping request in milliseconds
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

    addrinfo.first?.try(&.ip_address)
  end

  protected def run_ping(host, count, timeout)
    args = pargs(host, count, timeout)

    start_time = Time.utc
    exit_status, info, err = run_ping_process(args)

    success = read_status(exit_status, info, err)

    @duration = (Time.utc - start_time).milliseconds if success
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

  protected def strip_port(host)
    host.rstrip(":7")
  end

  protected def run_ping_process(args)
    output = IO::Memory.new
    error = IO::Memory.new

    status = Process.run(
      args.shift,
      args: args,
      output: output,
      error: error,
    )

    {status, output.to_s, error.to_s}
  end

  # Get process arguments for ping
  protected def pargs(ip, count : Int32, timeout : Int32) : Array(String)
    host = strip_port(ip.to_s)
    ipv6 = ip.family == Socket::Family::INET6
    process = if ipv6
                # Removes the square brackets. i.e. [::1]:9
                host = host[1..-2]
                "ping6"
              else
                "ping"
              end

    # https://en.wikipedia.org/wiki/Uname
    case OS
    when /linux|gnu/
      [process, "-c", count.to_s, "-W", timeout.to_s, host]
    when /aix/
      [process, "-c", count.to_s, "-w", timeout.to_s, host]
    when /bsd|darwin|dragonfly/
      # FreeBSD + MidnightBSD + OpenBSD + NetBSD etc
      if ipv6
        [process, "-c", count.to_s, host]
      else
        [process, "-c", count.to_s, "-t", timeout.to_s, host]
      end
    when /sunos/
      [process, host, timeout.to_s]
    when "hp-ux"
      [process, host, "-n#{count.to_s}", "-m", timeout.to_s]
    when /cygwin|mingw|msys/
      [process, "-n", count.to_s, "-w", (timeout * 1000).to_s, host]
    else
      [process, host]
    end
  end
end
