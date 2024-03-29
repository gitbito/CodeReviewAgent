#!/bin/bash


# Arguments to run the Docker image
echo $INPUT_PR
echo $INPUT_COMMAND
echo $INPUT_OPTIONS

SUPPORTED_COMMANDS=("/review" "review")

INPUT_COMMAND=$(echo "$INPUT_COMMAND" | tr -d '[:space:]')
for command in "${SUPPORTED_COMMANDS[@]}"; do
  if [ "$command" = "$INPUT_COMMAND" ]; then
    valid_command=true
    break
  fi
done


# Run the Docker container from the specified image
if [ "$valid_command" = true ]; then
  exec docker pull bitoai/cra:latest 
  exec docker run bitoai/cra:latest --mode=cli --pr_url $INPUT_PR $INPUT_COMMAND $INPUT_OPTIONS
else
  echo "$INPUT_COMMAND is not supported"
  exit 0  # Exit the script with a non-zero status code
fi
