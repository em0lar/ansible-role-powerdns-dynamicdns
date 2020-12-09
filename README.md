# powerdns-dynamicdns

This role does Dynamic DNS with powerdns in an easy way.

## Requirements
You need a powerdns instance running with the following settings:
  * `dnsupdate: yes` 
  * `allow-dnsupdate-from: "ALLOWED_DNSUPDATE_NET"`. This net can be e.g. a private VPN net between your servers or you can allow every IP, but in this case you should have TSIG signing in this role activated!
It also needs the sqlite3 database configured as backend.

## Role Variables

### General (all required)

| Variable Name | Function | Example Value | Comment |
| ------------- | -------- | ------------- | ------- |
| `powerdns_dynamicdns_database_file` | Path to SQLite3 file where domain database will be saved in | `/var/lib/powerdns/sqlite3.db` |
| `powerdns_dynamicdns_ansible_server` | Address of the server the powerdns server runs on (used for connection with ansible)  | `dns.exmaple.org` |
| `powerdns_dynamicdns_nsupdate_server` | Address of the server the powerdns server runs on (used for connection from the client server) | `fd8a:a2312:s212:a1::1` (VPN) or `dns.example.org` (public net)  | 
| `powerdns_dynamicdns_zone` | Zone the server dyndns records are saved in | `dyn.example.org` |
| `powerdns_dynamicdns_record_name` | The name of the dyndns records | `server1.dyn.example.org` | must be in the zone specified in `powerdns_dynamicdns_zone`

### TSIG

| Variable Name | Function | Default value | Comment |
| ------------- | -------- | ------------- | ------- |
| `powerdns_dynamicdns_activate_tsig` | Activates TSIG signing of the requests between the client server and powerdns | `yes` | 
| `powerdns_dynamicdns_tsig_key_algorithm` | Algorithm used for TSIG signing | `hmac-sha512` | Must be supported by powerdns and nsupdate
| `powerdns_dynamicdns_tsig_key_name` | Name of the TSIG signature name (required when TSIG signature is enabled) | | 

### Domain Metadata

| Variable Name | Function | Default value | Comment |
| ------------- | -------- | ------------- | ------- |
| `powerdns_dynamicdns_domainmetadata` | Add metadata to the zome | `[]` | `[{'key': 'ALLOW-DNSUPDATE-FROM', 'value': '0.0.0.0/0'}]`

### SOA and nameserver records

| Variable Name | Function | Default value | Comment |
| ------------- | -------- | ------------- | ------- |
| `powerdns_dynamicdns_soa_record_mname` | mname of the SOA record used in domain | | Example: `ns.example.org` (required if soa record is not set before)
| `powerdns_dynamicdns_soa_record_rname` | rname of the SOA record used in domain | | Example: `noc.example.org` (required if soa record is not set before)
| `powerdns_dynamicdns_soa_record_min_ttl` | Minimum TTL of records in zone | `60` | Time in seconds 
| `powerdns_dynamicdns_nameservers` | List of nameservers responsible for the zone | | Example: `- ns1.he.net` 

### IPs

| Variable Name | Function | Default value | Comment |
| ------------- | -------- | ------------- | ------- |
| `dyndns_get_ipv4_command` | Command the client runs to get the IPv4 address | `curl -4 -f -s --connect-timeout 20 -S http://ipv4.xnet.space 2>/dev/null` | 
| `dyndns_get_ipv6_command` | Command the client runs to get the IPv6 address | `curl -6 -f -s --connect-timeout 20 -S http://ipv6.xnet.space 2>/dev/null` |  

## Dependencies

None

## Example Playbook

```yaml
# With TSIG support enabled and already existing SOA
- hosts: servers
  roles:
     - { 
        role: em0lar.powerdns-dynamicdns,
        powerdns_dynamicdns_database_file: "/var/lib/powerdns/sqlite3.db",
        powerdns_dynamicdns_ansible_server: "dns.exmaple.org",
        powerdns_dynamicdns_nsupdate_server: "fd8a:a2312:s212:a1::1",
        powerdns_dynamicdns_zone: "dyn.example.org",
        powerdns_dynamicdns_record_name: "server1.dyn.example.org",
        powerdns_dynamicdns_tsig_key_name: "server1",
     }

# With TSIG support enabled and without existing SOA and NS records
- hosts: servers
  roles:
     - { 
        role: em0lar.powerdns-dynamicdns,
        powerdns_dynamicdns_database_file: "/var/lib/powerdns/sqlite3.db",
        powerdns_dynamicdns_ansible_server: "dns.exmaple.org",
        powerdns_dynamicdns_nsupdate_server: "fd8a:a2312:s212:a1::1",
        powerdns_dynamicdns_zone: "dyn.example.org",
        powerdns_dynamicdns_record_name: "server1.dyn.example.org",
        powerdns_dynamicdns_tsig_key_name: "server1",
        powerdns_dynamicdns_soa_record_mname: "ns.example.org",
        powerdns_dynamicdns_soa_record_rname: "noc.example.org",
        powerdns_dynamicdns_nameservers:
          - ns1.he.net
          - ns2.he.net
     }
```

## License

MIT
