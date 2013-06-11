require 'resque/status_server'
require 'resque/job_with_status'
Dir[File.join(Rails.root, 'app', 'workers', '*.rb')].each{|file| require file}
redis_conf_path = Rails.root.join("config/redis", "#{Rails.env}.conf")
redis_conf = File.read(redis_conf_path)
port = /port.(\d+)/.match(redis_conf)[1]
#host = /host.(\w+)/.match(redis_conf)[1]
host = "localhost"
Resque.redis = Redis.new(host: host, port: port)
Resque::Plugins::Status::Hash.expire_in = (24 * 60 * 60)
