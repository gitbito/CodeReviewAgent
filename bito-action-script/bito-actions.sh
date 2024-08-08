#!/bin/bash

# Function to read property values from the file
read_property() {
  local property_key=$1
  local property_file=$2
  local property_value=$(grep -w "${property_key}" "${property_file}" | cut -d'=' -f2-)
  echo "${property_value//\"}"
}

# Initialize variables with default empty values
agent_instance_url=""
agent_instance_secret=""
git_url=""

# Check if the first argument is a file
if [ -f "$1" ]; then
  PROPERTY_FILE=$1
  shift

  # Read initial values from the property file
  agent_instance_url=$(read_property "agent_instance_url" "${PROPERTY_FILE}")
  agent_instance_secret=$(read_property "agent_instance_secret" "${PROPERTY_FILE}")
  git_url=$(read_property "git_url" "${PROPERTY_FILE}")
fi

# Override with command line arguments if provided
for arg in "$@"
do
  case $arg in
    agent_instance_url=*)
      agent_instance_url="${arg#*=}"
      agent_instance_url="${agent_instance_url//\"}"
      ;;
    agent_instance_secret=*)
      agent_instance_secret="${arg#*=}"
      agent_instance_secret="${agent_instance_secret//\"}"
      ;;
    git_url=*)
      git_url="${arg#*=}"
      git_url="${git_url//\"}"
      ;;
    *)
      echo "Unknown argument: $arg"
      ;;
  esac
done

# Check if any of the required properties are empty
if [ -z "$agent_instance_url" ]; then
  echo "Error: agent_instance_url is empty"
  exit 1
fi

if [ -z "$agent_instance_secret" ]; then
  echo "Error: agent_instance_secret is empty"
  exit 1
fi

if [ -z "$git_url" ]; then
  echo "Error: git_url is empty"
  exit 1
fi

# Print properties
echo "Agent Instance URL: $agent_instance_url"
echo "Agent Instance Secret: $agent_instance_secret"
echo "Git URL: $git_url"

# Execute the curl command
eval "curl --location '$agent_instance_url' \
--header 'X-Bito-Action-Token: $agent_instance_secret' \
--header 'Content-Type: application/json' \
--data '{
    \"git_url\": \"$git_url\",
    \"command\": \"review\",
    \"arguments\": {}
}'"
