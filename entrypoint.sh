#!/bin/bash


# Arguments to run the Docker image
echo $INPUT_PR
echo $INPUT_COMMAND
echo $INPUT_OPTIONS
echo $EVENT_NAME

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
  docker pull bitoai/cra:1.3.0 >&2
  exec docker run bitoai/cra:1.3.0 --mode=cli --pr_url $INPUT_PR --command "$INPUT_COMMAND" rest $INPUT_OPTIONS
else
  echo "$INPUT_COMMAND is not supported"
  exit 0  # Exit the script with a non-zero status code
fi
