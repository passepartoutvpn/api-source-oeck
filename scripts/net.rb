require "json"
require "resolv"
require "ipaddr"

cwd = File.dirname(__FILE__)
Dir.chdir(cwd)
load "util.rb"

###

template = File.read("../template/servers.json")
ca = File.read("../static/ca.crt")
client = File.read("../static/client.crt")
key = File.read("../static/client.key")
tls_wrap = read_tls_wrap("auth", 1, "../static/ta.key", 1)

cfg = {
  ca: ca,
  clientCertificate: client,
  clientKey: key,
  compressionFraming: 0,
  tlsWrap: tls_wrap,
  checksEKU: true
}

cfg_128 = cfg.dup
cfg_128["cipher"] = "AES-128-CBC"
cfg_128["digest"] = "SHA256"

cfg_256 = cfg.dup
cfg_256["cipher"] = "AES-256-GCM"
cfg_256["digest"] = "SHA256"

cfg_128 = {
  id: "cfg128",
  name: "128-bit",
  comment: "128-bit encryption",
  ovpn: {
    cfg: cfg_128,
    endpoints: [
      "UDP:1196",
      "TCP:445"
    ]
  }
}
cfg_256 = {
  id: "cfg256",
  name: "256-bit",
  comment: "256-bit encryption",
  ovpn: {
    cfg: cfg_256,
    endpoints: [
      "UDP:1194",
      "TCP:443"
    ]
  }
}
presets = [cfg_128, cfg_256]

defaults = {
  :username => "myusername",
  :country => "US"
}

###

servers = []

json = JSON.parse(template)
json["countries"].each { |country|
  country["cities"].each { |city|
    code = country["code"].upcase
    area = city["name"]

    city["relays"].each { |relay|
      id = relay["hostname"]
      #hostname = "#{id}.oeck.com"
      num = id.split("-").last.to_i

      addresses = [relay["ipv4_addr_in"]]
      addresses.map! { |a|
        IPAddr.new(a).to_i
      }

      server = {
        :id => id,
        :country => code,
        #:hostname => hostname,
        :addrs => addresses
      }
      server[:area] = area if !area.empty?
      server[:num] = num
      servers << server
    }
  }
}

###

infra = {
  :servers => servers,
  :presets => presets,
  :defaults => defaults
}

puts infra.to_json
puts
