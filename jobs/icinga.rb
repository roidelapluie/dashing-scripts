require "net/https"
require "uri"

uri = URI.parse("https://icinga.example/icinga/cgi-bin/status.cgi?host=all&nostatusheader&jsonoutput")

SCHEDULER.every '4s' do
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  request = Net::HTTP::Get.new(uri.request_uri)
  request.basic_auth("USER", "PASS")
  response = http.request(request)
  services = JSON.parse(response.body)["status"]["service_status"]
  total_critical = 0
  total_warning = 0
  total_ack = 0
  total = 0


  services.each { |service|
    case service["status"]
    when "CRITICAL"
      if service["has_been_acknowledged"]
      then
        total_ack += 1
      else
        total_critical += 1
      end
    when "WARNING"
      if service["has_been_acknowledged"]
      then
        total_ack += 1
      else
        total_warning += 1
      end
    end
    total +=1
  }
  if total_critical > 0 then
    color = 'red'
    value = total_critical.to_s
  elsif total_warning > 0 then
    color = 'yellow'
    value = total_warning.to_s
  else
    color = 'green'
    value = total.to_s
  end
  if total_ack > 0
    value = value + "*"
  end
  send_event('icinga', {
    value: value,
    color: color })
end
