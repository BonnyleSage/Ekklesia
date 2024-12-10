# Ekklesia
Ekklesia is a ruby based, powerful and customizable stress-testing (Ddos)tool designed for penetration testers and network administrators to evaluate the resilience of servers and web applications. With features like multi-threaded requests, proxy support, randomized headers for WAF evasion, and attack monitoring, Ekklesia is perfect for authorized stress testing and performance analysis.

## 🎯 Features

- **Layer 7 (HTTP/HTTPS Requests)**:
  - Supports GET, POST, HEAD methods.
  - Sends randomized headers to bypass WAFs and evade detection.
  - Proxy support to anonymize traffic.

- **Layer 4 (TCP/UDP Flood)**:
  - Floods raw TCP or UDP packets to target IP and port.
  - Configurable protocol, duration, and threads.

- **Customizable Parameters**:
  - Control threads, delay, proxies, and more.

- **Multi-Threading**:
  - Optimized for high-performance stress testing.

## 🛠️ Installation

1. Clone the repository:

git clone https://github.com/yourusername/ekklesia.git
cd ekklesia

2. Ensure Ruby is installed:
ruby -v
  
## 🚀 Usage
 ruby ekklesia.rb [options]
 **Options**
 
| Option                   | Description                                                         |
|--------------------------|---------------------------------------------------------------------|
| -u, --url URL            | Target URL or IP (required).                                        |
| -t, --threads THREADS    | Number of threads (default: 10).                                    |
| -r, --requests REQUESTS  | Number of requests per thread for Layer 7 (default: 100).           |
| -p, --proxy PROXY_FILE   | Path to proxy list file (optional for Layer 7).                     |
| -m, --method METHOD      | HTTP method for Layer 7 (GET, POST, HEAD; default: GET).            |
| -d, --delay DELAY        | Delay between requests in milliseconds for Layer 7 (default: 100).  |
| -l, --layer LAYER        | Layer of attack: 4 (Transport) or 7 (Application).                  |
| --protocol PROTOCOL      | Protocol for Layer 4 (TCP, UDP; default: TCP).                      |
| --port PORT              | Target port for Layer 4 (default: 80).                              |
| --duration DURATION      | Duration of Layer 4 attack in seconds (default: 60).                |

## 📚 Examples

**Layer 7 Attack (HTTP Requests)**
Perform a Layer 7 stress test using HTTP GET requests with 10 threads:
⚪ruby ekklesia.rb -u https://example.com -t 10 -r 100 -m GET -d 100 -l 7
**Layer 4 TCP Flood**
Flood the target IP 192.168.1.100 on port 80 using TCP for 60 seconds:
⚪ruby ekklesia.rb -u 192.168.1.100 --port 80 --protocol tcp -t 10 --duration 60 -l 4
**Layer 7 with Proxy Support**
Perform an HTTP GET flood using proxies from proxies.txt:
⚪ruby ekklesia.rb -u https://example.com -t 10 -r 100 -p proxies.txt -m GET -l 7

## 🔧 Proxy List Format
Proxies should be provided in a text file (proxies.txt), with one proxy per line in the format (we Provided some samples):
http://proxy1:port
http://proxy2:port
https://proxy3:port

## ⚙️ How It Works
**1. Randomized Headers**
Each HTTP request is sent with unique headers:

Randomized User-Agent, Referer, and X-Forwarded-For.
Example headers:
User-Agent: Mozilla/7.0 (Windows NT 10.0) Gecko/20211012 Firefox/93
Referer: https://google.com/search?q=135
X-Forwarded-For: 192.168.0.1
## 2. Multi-Layer Support
Layer 7: Suitable for application-layer stress testing.
Layer 4: Simulates transport-layer flood attacks.
## 📄 Requirements
Ruby: Ensure Ruby is installed (ruby -v).
Network Access: The target must be reachable from your system.
Permission: Ensure you have explicit authorization to test the target.

## 🚧 Disclaimer
A very  big Warning against  any  illegal use of this tool, Ekklesia is for authorized testing only. Misuse of this tool against unauthorized targets is illegal and unethical. Ensure you have explicit permission before conducting any stress tests.I Bonny leSage ,The author and contributor is not responsible for misuse or damage caused by this tool.

## 👩‍💻 Contributing 
Contributions are welcome! Feel free to submit pull requests or open issues to suggest new features or improvements.Thanks  in  advance🙏🙏🙏

## 📫 Contact
Author: TheCybercoach|| Bonny leSage
Email: thecybercoach971@gmail.com
GitHub: https://github.com/BonnyleSage

## 📝 License
This project is licensed under the MIT License. See the LICENSE file for details.

## NB
We invite you  guys to  fork  this project,  improvite it By  contribute, Open  Issue  section  ,  It will  help improvement.  And please Give us stars  .  
Thanks . 





   

