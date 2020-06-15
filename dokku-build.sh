# Please replace the values for these variables but do not commit
# the changes to Github:
DOMAIN=sentry.example.com
EMAIL_HOST=smtp.example.com
SERVER_EMAIL=sentry@example.com
EMAIL_USER=sentry@example.com
EMAIL_PASSWORD=

# Create dokku app
dokku apps:create sentry

# Create postgres database
dokku postgres:create sentry-db && dokku postgres:link sentry-db sentry

# Create redis store
dokku redis:create sentry-redis &&  dokku redis:link sentry-redis sentry

# Create memcache
dokku memcached:create sentry-memcached && dokku memcached:link sentry-memcached sentry

# Add domain
dokku domains:set sentry $DOMAIN

# Add environment variables
dokku config:set sentry SENTRY_SECRET_KEY=$(echo `openssl rand -base64 64` | tr -d ' ') \
   SENTRY_EMAIL_HOST=$EMAIL_HOST \
   SENTRY_EMAIL_USER=$EMAIL_USER \
   SENTRY_EMAIL_PASSWORD=$EMAIL_PASSWORD \
   SENTRY_EMAIL_PORT=25 \
   SENTRY_SERVER_EMAIL=$SERVER_EMAIL \
   SENTRY_EMAIL_USE_TLS=True

# Setup storage
sudo mkdir -p /var/lib/dokku/data/storage/sentry
sudo chown 32768:32768 /var/lib/dokku/data/storage/sentry
dokku storage:mount sentry /var/lib/dokku/data/storage/sentry:/var/lib/sentry/files

# Setup ports
dokku proxy:ports-add sentry http:80:9000
dokku proxy:ports-remove sentry http:80:5000

# Check assigned ports
dokku proxy:report sentry
