# Cloudflare's published edge ranges (https://www.cloudflare.com/ips/).
#
# Behind the Cloudflare proxy $remote_addr is an edge address that changes
# per request, so every visitor would geolocate to the same handful of
# places. real_ip_header restores the client address from CF-Connecting-IP,
# but only for connections that actually come from Cloudflare -- the header
# is attacker-controlled otherwise. Harmless when a host is not proxied: no
# source matches and the header is ignored.
#
# Same list the docxty and wedding project flakes install on this host.
[
  "173.245.48.0/20"
  "103.21.244.0/22"
  "103.22.200.0/22"
  "103.31.4.0/22"
  "141.101.64.0/18"
  "108.162.192.0/18"
  "190.93.240.0/20"
  "188.114.96.0/20"
  "197.234.240.0/22"
  "198.41.128.0/17"
  "162.158.0.0/15"
  "104.16.0.0/13"
  "104.24.0.0/14"
  "172.64.0.0/13"
  "131.0.72.0/22"
  "2400:cb00::/32"
  "2606:4700::/32"
  "2803:f800::/32"
  "2405:b500::/32"
  "2405:8100::/32"
  "2a06:98c0::/29"
  "2c0f:f248::/32"
]
