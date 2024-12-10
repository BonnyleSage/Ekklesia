require 'net/http'
require 'uri'

# Function to check if a proxy is online
def proxy_online?(proxy)
  target_url = "https://example.com" # Target to test proxy
  proxy_uri = URI.parse("http://#{proxy}")

  begin
    # Create HTTP object using the proxy
    http = Net::HTTP.new(proxy_uri.host, proxy_uri.port)
    http.open_timeout = 5 # Set timeout
    http.read_timeout = 5

    # Make a test GET request
    request = Net::HTTP::Get.new("/")
    response = http.request(request)

    # Check for a valid HTTP response
    return response.code.to_i >= 200 && response.code.to_i < 400
  rescue
    return false # Proxy is not online
  end
end

# File paths
input_file = "proxy.txt"
output_file = "proxies.txt"

# Validate the proxy file exists
unless File.exist?(input_file)
  puts "[!] Error: #{input_file} not found in the current directory."
  exit
end

# Open files and test proxies
working_proxies = []
File.readlines(input_file).each do |proxy|
  proxy.strip!
  next if proxy.empty?

  formatted_proxy = "http://#{proxy}" # Ensure proper format
  if proxy_online?(proxy)
    puts "[+] Proxy is online: #{formatted_proxy}"
    working_proxies << formatted_proxy
  else
    puts "[-] Proxy is offline: #{formatted_proxy}"
  end
end

# Save working proxies to file
File.open(output_file, "w") do |file|
  working_proxies.each { |proxy| file.puts(proxy) }
end

puts "[*] Finished! #{working_proxies.size} working proxies saved to #{output_file}."
