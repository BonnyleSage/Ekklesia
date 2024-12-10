# Ekklesia
Ekklesia is a ruby based, powerful and customizable stress-testing (Ddos)tool designed for penetration testers and network administrators to evaluate the resilience of servers and web applications. With features like multi-threaded requests, proxy support, randomized headers for WAF evasion, and attack monitoring, Ekklesia is perfect for authorized stress testing and performance analysis.

## 🎯 Features

- **Multi-Threaded Requests**: Configure multiple threads for faster stress tests.
- **Proxy Support**: Use a proxy list to anonymize and distribute traffic.
- **Randomized Headers**: Automatically bypass WAFs with randomized headers.
- **HTTP Method Support**: Choose HTTP methods (GET, POST, HEAD, etc.) for custom testing scenarios.
- **Layer Selection**: Test at the transport layer (L4) or application layer (L7).
- **Attack Monitoring**: Continuously monitor the server's status during the attack.

---

## 🛠️ Installation

1. **Clone the Repository**:
   
   git clone https://github.com/yourusername/ekklesia.git
   cd ekklesia
2. **Install Dependencies**: Ensure Ruby is installed on your system:
    ruby -v
3. **Run the Script**:
    ruby ekklesia.rb -h

## 🚀 Usage
 **Basic Syntax**
 ruby ekklesia.rb [options]
 **Options**
| Option              | Description                                                                |
|---------------------|----------------------------------------------------------------------------|
| -u, --url URL      | Target URL (required).                                                     |
| -t, --threads N    | Number of threads to use (default: 10).                                    |
| -r, --requests N   | Number of requests per thread (default: 100).                              |
| -p, --proxy FILE   | Path to proxy list file (optional).                                        |
| -m, --method METHOD| HTTP method to use (e.g., GET, POST, HEAD; default: GET).                  |
| -l, --layer LAYER  | Layer of attack: 4 (Transport Layer) or 7 (Application Layer); default: 7.  |
| -h, --help         | Show the help message.                                                     |

## 📚 Examples
**1. Basic Stress Test**
Perform a basic stress test on a target:
💫 ruby ekklesia.rb -u https://example.com

**2. Stress Test with Multiple Threads**
Use 20 threads for faster testing:
💫 ruby ekklesia.rb -u https://example.com -t 20
 
 **3. Use a Proxy List**
 Run the test using a proxy list from proxies.txt:
💫 ruby ekklesia.rb -u https://example.com -p proxies.txt
**4. Custom HTTP Method**
Use the POST method for the attack: 
💫 ruby ekklesia.rb -u https://example.com -m POST
**5. Layer 4 Attack**
Simulate a Layer 4 transport-level attack:
💫ruby ekklesia.rb -u https://example.com -l 4

## 🌟 Key Features in Action
 **1. Randomized Headers for WAF Evasion**
   Ekklesia generates dynamic HTTP headers for each request to bypass WAF detection:
    Randomized User-Agent, X-Forwarded-For, and Referer headers.
    Example header for one request:
          User-Agent: Mozilla/7.0 (Windows NT 10.0) Gecko/20220501 Firefox/68
          X-Forwarded-For: 192.168.10.23
          Referer: https://google.com/search?q=827
  **2. Proxy Support**
    Load proxies from a file to anonymize your requests:
     ◼Proxy file format:
       http://proxy1:port
       http://proxy2:port
     ◼Proxies are cycled across requests for effective distribution.
  **3. Continuous Server Monitoring**
    Ekklesia monitors the server's status during the attack:
      Alerts for status codes like 500 (server under stress) or 403 (WAF detection).
      Automatically detects when the server becomes unresponsive.

## 📋 Output Example
  **Command:**
    ❗❗❗❗  ruby ekklesia.rb -u https://example.com -t 10 -r 50 -m GET -p proxies.txt
  **Sample Output:**
  
  # ===========================================
          Ekklesia - Attack Details        
# ===========================================

**Tool:**       Ekklesia  
**Author:**     TheCybercoach  
**Email:**      thecybercoach971@gmail.com  
**Target:**     https://example.com  
**Threads:**    10  
**Requests:**   50 per thread  
**Proxy:**      Yes  
**Method:**     GET  
**Layer:**      7  

---

## Log:
- [+] Request sent via proxy http://proxy1:port - Response: 200  
- [+] Request sent via proxy http://proxy2:port - Response: 403  
- [!] WAF detected! Consider adjusting headers or using fragmented requests.  
- [+] Request sent via proxy http://proxy3:port - Response: 500  
- [!] Server under stress: 500  
- [INFO] Monitoring server status...  
- [ALERT] Server is down or unresponsive!

## 📄 Requirements

❗Ruby: Ensure Ruby is installed (ruby -v).
❗Network Access: Ensure you can access the target and proxies (if applicable).
❗Proxy List (optional): Use a proxy list for anonymized requests.

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





   

