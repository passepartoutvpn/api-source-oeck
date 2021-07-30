require "json"
require "resolv"
require "ipaddr"

cwd = File.dirname(__FILE__)
Dir.chdir(cwd)
load "util.rb"

###

servers = File.read("../template/servers.json")
ca = File.read("../static/ca.crt")
client = File.read("../static/client.crt")
key = File.read("../static/client.key")
tls_wrap = read_tls_wrap("auth", 1, "../static/ta.key", 1)

cfg = {
    ca: ca,
    client: client,
    key: key,
    frame: 0,
    wrap: tls_wrap,
    eku: true
}

cfg_128 = cfg.dup
cfg_128["cipher"] = "AES-128-CBC"
cfg_128["auth"] = "SHA256"
cfg_128["ep"] = [
    "UDP:1196",
    "TCP:445"
]

cfg_256 = cfg.dup
cfg_256["cipher"] = "AES-256-GCM"
cfg_256["auth"] = "SHA256"
cfg_256["ep"] = [
    "UDP:1194",
    "TCP:443"
]

cfg_128 = {
    id: "cfg128",
    name: "128-bit",
    comment: "128-bit encryption",
    cfg: cfg_128
}
cfg_256 = {
    id: "cfg256",
    name: "256-bit",
    comment: "256-bit encryption",
    cfg: cfg_256
}
presets = [cfg_128, cfg_256]

defaults = {
    :username => "myusername",
    :pool => "us",
    :preset => "cfg128"
}

###

pools = []

json = JSON.parse(servers)
json["countries"].each { |country|
    country["cities"].each { |city|
        code = country["code"].upcase
        area = city["name"]

        city["relays"].each { |relay|
            id = relay["hostname"]
            hostname = "#{id}.oeck.com"
            num = id.split("-").last.to_i

            addresses = [relay["ipv4_addr_in"]]
            addresses.map! { |a|
                IPAddr.new(a).to_i
            }

            pool = {
                :id => id,
                :country => code,
                :addrs => addresses
            }
            pool[:area] = area if !area.empty?
            pool[:num] = num
            pools << pool
        }
    }
}

###

infra = {
    :pools => pools,
    :presets => presets,
    :defaults => defaults
}

puts infra.to_json
puts
