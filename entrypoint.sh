#!/bin/bash


# Arguments to run the Docker image
echo $INPUT_PR
echo $INPUT_COMMAND
echo $INPUT_OPTIONS
echo $EVENT_NAME

if [ "$EVENT_NAME" = "pull_request" ]; then
    INPUT_OPTIONS="$INPUT_OPTIONS --cr_event_type=automated"
else
    INPUT_OPTIONS="$INPUT_OPTIONS --cr_event_type=manual"
fi

# Function to remove spaces from the value
remove_spaces() {
  echo "$1" | tr -d ' '
}

# Function to convert a string to lowercase
to_lowercase() {
  echo "$1" | tr '[:upper:]' '[:lower:]'
}

process_input_options() {
  local input="$1"
  local docker_cmd_args=""

  # Use sed to add newlines before each '--' to simplify processing
  local formatted_input=$(echo "$input" | sed 's/ --/\n--/g')

  docker_cmd_args=$(echo "$formatted_input" | while IFS= read -r line
  do
    # Extract key by cutting until the first '='
    key=$(echo "$line" | cut -d'=' -f1)

    # Extract value by removing everything before the first '='
    value=$(echo "$line" | cut -d'=' -f2-)

    # Check if the argument is --review_scope, --exclude_files, or --exclude_branches and remove spaces
    if [[ "$key" == "--review_scope" || "$key" == "--static_analysis_tool" ]]; then
      value=$(remove_spaces "$value")
      value=$(to_lowercase "$value")
    elif [[ "$key" == "--exclude_files" || "$key" == "--exclude_branches" ]]; then
      value=$(remove_spaces "$value")
    fi

    # Append to the modified arguments
    echo -n "$key=$value "
  done)

  # Return the docker command arguments
  echo "$docker_cmd_args"
}

# Process the input arguments and get the modified result
docker_cmd_args=$(process_input_options "$INPUT_OPTIONS")
echo "Docker Command Args: $docker_cmd_args"

SUPPORTED_COMMANDS=("/review" "review")

#INPUT_COMMAND=$(echo "$INPUT_COMMAND" | tr -d '[:space:]')
INPUT_COMMAND=$(echo "$INPUT_COMMAND" | xargs)

# Check if the command starts with any of the supported commands
for command in "${SUPPORTED_COMMANDS[@]}"; do
  if [[ "$INPUT_COMMAND" =~ ^$command ]]; then
    valid_command=true
    break
  fi
done


# Run the Docker container from the specified image
if [ "$valid_command" = true ]; then
  docker pull bitoai/cra:1.4.5 >&2
  exec docker run bitoai/cra:1.4.5 --mode=cli --pr_url $INPUT_PR --command "$INPUT_COMMAND" rest $docker_cmd_args
else
  echo "$INPUT_COMMAND is not supported"
  exit 0  # Exit the script with a non-zero status code
fi
