require 'open-uri'

def fetch_proxies(proxy_url, output_file)
  proxies = []

  begin
    # Open the proxy list page
    open(proxy_url) do |page|
      page.each_line do |line|
        # Extract proxies in the format IP:PORT
        if line =~ /\d+\.\d+\.\d+\.\d+:\d+/
          proxies << line.strip
        end
      end
    end

    # Save proxies to a file
    File.open(output_file, "w") do |file|
      proxies.each { |proxy| file.puts(proxy) }
    end

    puts "[+] Fetched #{proxies.size} proxies from #{proxy_url} and saved to #{output_file}."
  rescue => e
    puts "[!] Error fetching proxies: #{e.message}"
  end
end

# Example usage
proxy_url = "https://www.sslproxies.org/"
output_file = "proxies.txt"

fetch_proxies(proxy_url, output_file)
