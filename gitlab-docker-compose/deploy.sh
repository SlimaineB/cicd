#!/bin/bash

# Deploy GitLab and GitLab Runner

GITLAB_DOCKER_NAME="gitlab"
GITLAB_PROJECT_NAME="gitlab-project"

# Remove previous containers and volumes to ensure a clean start
docker compose -f docker-compose.yml down -v

# Verify that Docker is running before proceeding
if ! docker info > /dev/null 2>&1; then
  echo "Error: Docker is not running. Please start Docker and try again."
  exit 1
fi

# Start GitLab and GitLab Runner
docker compose -f docker-compose.yml up -d

# Wait until GitLab is fully initialized
echo "Waiting for GitLab to start..."
until curl -s "http://localhost/users/sign_in" > /dev/null; do
  echo "GitLab is not ready yet. Waiting..."
  sleep 5
done

echo "GitLab is now accessible."

# Retrieve the initial root password, extracting only the password value
ROOT_PASSWORD=$(docker exec -it gitlab cat /etc/gitlab/initial_root_password 2>/dev/null | grep "Password:" | awk '{print $2}')
echo "Initial root password retrieved."

# Retrieve the GitLab Runner registration token
RUNNER_REGISTER_TOKEN=$(docker exec -it gitlab gitlab-rails runner "puts Gitlab::CurrentSettings.current_application_settings.runners_registration_token" 2>/dev/null | tr -d '[:space:]')
echo "GitLab Runner registration token retrieved."

# Register the GitLab Runner with the correct URL
docker compose exec gitlab-runner gitlab-runner register --non-interactive \
  --registration-token "${RUNNER_REGISTER_TOKEN}" \
  --url "http://${GITLAB_DOCKER_NAME}/" \
  --docker-image "python:3.10" \
  --executor "docker" \
  --name "first-runner" \
  --clone-url "http://${GITLAB_DOCKER_NAME}" \
  --docker-network-mode gitlab_docker_gitlab_network

# Generate API Token for GitLab
API_TOKEN=$(docker exec -it gitlab gitlab-rails runner "user = User.find_by(username: 'root'); token = user.personal_access_tokens.create(name: 'API-Token', scopes: ['api'], expires_at: 1.year.from_now); token.save!; puts token.token" 2>/dev/null | tr -d '[:space:]')
echo "API Token retrieved: ${API_TOKEN}"

# Verify API Token by listing GitLab projects
if ! curl --silent --header "PRIVATE-TOKEN: ${API_TOKEN}" "http://localhost/api/v4/projects" > /dev/null; then
  echo "Error: API request failed. Please check the API token or GitLab configuration."
  exit 1
fi

# Create a new GitLab project
curl --request POST --header "PRIVATE-TOKEN: ${API_TOKEN}" \
  --data "name=${GITLAB_PROJECT_NAME}&visibility=private" \
  "http://localhost/api/v4/projects"

# Retrieve the project ID after creation
PROJECT_ID=$(docker exec -it gitlab gitlab-rails runner "puts Project.find_by(name: '${GITLAB_PROJECT_NAME}').id" 2>/dev/null | tr -d '[:space:]')

# Ensure the project ID was retrieved successfully
if [ -z "${PROJECT_ID}" ]; then
  echo "Error: Failed to retrieve project ID."
  exit 1
fi
echo "Project ID: ${PROJECT_ID} retrieved."

# Push the .gitlab-ci.yml file to the GitLab repository
curl --request POST --header "PRIVATE-TOKEN: ${API_TOKEN}" \
  --data-urlencode "branch=main" \
  --data-urlencode "commit_message=Ajout du pipeline" \
  --data-urlencode "content=$(cat .gitlab-ci.yml)" \
  "http://localhost/api/v4/projects/${PROJECT_ID}/repository/files/.gitlab-ci.yml"


# Add SSH Key
echo "Adding SSH key to GitLab..."
if [ ! -f ~/.ssh/id_rsa.pub ]; then
  echo "Error: SSH public key not found at ~/.ssh/id_rsa.pub. Please generate an SSH key pair first."
  exit 1
fi
curl -d '{"title":"test key","key":"'"$(cat ~/.ssh/id_rsa.pub)"'"}' -H 'Content-Type: application/json' http://localhost/api/v4/user/keys?private_token=${API_TOKEN}

# Final summary
echo "GitLab setup completed successfully."
echo "-------------------------------------------------"
echo "GitLab URL: http://localhost"
echo "Username: root"
echo "Initial Password: ${ROOT_PASSWORD}"
echo "Project Name: ${GITLAB_PROJECT_NAME}"
echo "Project ID: ${PROJECT_ID}"
echo "API Token : ${API_TOKEN}"
echo "-------------------------------------------------"
