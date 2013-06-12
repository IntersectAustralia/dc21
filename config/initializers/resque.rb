# Default socket to localhost:6379
# Resque.redis = ""

# Redis is RAM based so after a duration the object will be removed.
# Expires in 1 hour
Resque::Plugins::Status::Hash.expire_in = (60 * 60)