require "net/https"
require "uri"

hostname="foreman.example.com"

SCHEDULER.every '4s' do
  http = Net::HTTP.new(hostname, 443)
  http.use_ssl = true
  hosts_request = Net::HTTP::Get.new("/hosts.json")
  hosts_request.basic_auth("USER", "PASS")
  hosts_response = http.request(hosts_request)
  hosts = JSON.parse(hosts_response.body)
  error_request = Net::HTTP::Get.new("/hosts/errors.json")
  error_request.basic_auth("USER", "PASS")
  error_response = http.request(error_request)
  errors = JSON.parse(error_response.body)

  total_hosts = hosts.length
  total_error = errors.length

  if total_error > 0 then
    value = total_error
    color = 'red'
  else
    value = total_hosts
    color = 'green'
  end

  send_event('foreman', {
    value: value,
    color: color })
end
