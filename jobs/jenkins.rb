require "net/https"
require "uri"

hostname="jenkins.example.com"

SCHEDULER.every '4s' do
  http = Net::HTTP.new(hostname, 443)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  jobs_request = Net::HTTP::Get.new("/view/pi/api/json")
  jobs_request.basic_auth("USER", "PASS")
  jobs_response = http.request(jobs_request)
  jobs = JSON.parse(jobs_response.body)["jobs"]

  total_jobs = jobs.length

  failed_jobs=Array.new()
  unstable_jobs=Array.new()
  building_jobs=Array.new()
  status = 0

  jobs.each do |job|
    case job['color']
    when 'red_anime'
      failed_jobs.push(job["name"])
      building_jobs.push(job["name"])
    when 'red'
      failed_jobs.push(job["name"])
      building_jobs.push(job["name"])
    when 'yellow_anime'
      unstable_jobs.push(job["name"])
      building_jobs.push(job["name"])
    when 'yellow'
      unstable_jobs.push(job["name"])
      building_jobs.push(job["name"])
    when 'grey_anime'
      building_jobs.push(job["name"])
    when 'geen_anime'
      building_jobs.push(job["name"])
    end
  end

    if failed_jobs.length > 0 then
      value = failed_jobs.length.to_i
      color = 'red'
    elsif unstable_jobs.length > 0
      value = unstable_jobs.length.to_i
      color = 'yellow'
    else
      value = jobs.length.to_i
      color = 'green'
    end
    if building_jobs.length > 0 then
      color = color + "-blink"
    end

  send_event('jenkins', {
    value: value,
    color: color }
      )
end
