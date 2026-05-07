#!/bin/bash

sudo chmod 666 /var/run/docker.sock

if [ -d /home/frappe/.ssh-mount ]; then
    echo "### STEP 5.5 Copy ssh keys"
    rsync -avP /home/frappe/.ssh-mount/ /home/frappe/.ssh/
    find ~/.ssh -type f -exec chmod 600 {} \;
    find ~/.ssh -type d -exec chmod 700 {} \;
fi

ERPNEXT_VERSION=15

echo "### STEP 6 Initialize frappe bench with frappe version ${ERPNEXT_VERSION} and Switch directory"
pushd /workspace/development
bench init --skip-redis-config-generation --frappe-branch version-${ERPNEXT_VERSION} frappe-bench
pushd frappe-bench

echo "### STEP 7 Setup hosts"
# We need to tell bench to use the right containers instead of localhost. Run the following commands inside the container:
bench set-config -g db_host mariadb
bench set-config -g redis_cache redis://redis:6379
bench set-config -g redis_queue redis://redis:6379
bench set-config -g redis_socketio redis://redis:6379
# For any reason the above commands fail, set the values in common_site_config.json manually.
#{
#  "db_host": "mariadb",
#  "redis_cache": "redis://redis:6379",
#  "redis_queue": "redis://redis:6379",
#  "redis_socketio": "redis://redis:6379"
#}

echo "### STEP 8 Create a new site"
# sitename MUST end with .localhost for trying deployments locally.
bench new-site d-code.localhost --mariadb-user-host-login-scope='%' --mariadb-root-password 123 --admin-password admin 

echo "### STEP 9 Set bench developer mode on the new site"
bench --site d-code.localhost set-config developer_mode 1
bench --site d-code.localhost clear-cache

echo "### STEP 10 Install ERPNext with full git repository"
# Get the ERPnext app
bench get-app erpnext --branch version-${ERPNEXT_VERSION}

# Install ERPNext on the site
bench --site d-code.localhost install-app erpnext

echo "### STEP 11 Configure Git for ERPNext updates"
# Set up git configuration for ERPNext app to enable easy updates
pushd apps/erpnext
git config pull.rebase false  # Use merge strategy for pulls
git config branch.autosetupmerge always
git config branch.autosetuprebase never
popd  # Back to frappe-bench

echo "### STEP 12 Display Git status"
pushd apps/erpnext
echo "ERPNext Git repository status:"
echo "Current branch: $(git branch --show-current)"
echo "Remote tracking: $(git branch -vv | grep \* | sed 's/.*\[\([^]]*\)\].*/\1/' || echo 'No tracking branch')"
echo "Latest commit: $(git log -1 --oneline)"
popd  # Back to frappe-bench

echo "### STEP 13 Start Frappe bench"
echo "ERPNext has been installed with full git functionality!"
echo "- Current branch: version-${ERPNEXT_VERSION}"
echo "- Git repository is fully functional and trackable"
echo "- To update ERPNext and all apps, run: bench update"
echo ""
echo "Now go to /workspace/development/frappe-bench/ and run bench start"
echo "Then open your browser and go to http://d-code.localhost:8000"
