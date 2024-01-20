#!/usr/bin/env bash
#set -x

validate_bash_version() {
    # Get the Bash version
    bash_version=$(bash --version | head -n 1 | awk '{print $4}')

    # Extract the major version number
    major_version=$(echo "$bash_version" | awk -F '.' '{print $1}')

    # Check if the Bash version is less than 4.x
    if [[ $major_version -lt 4 ]]; then
        echo "Bash version $bash_version is not supported. Please upgrade to Bash 4.x or higher."
        exit 1
    fi
}

validate_docker_version() {
    # Get the Docker version
    docker_version=$(docker version --format '{{.Server.Version}}')

    # Extract the major version number
    major_version=$(echo "$docker_version" | awk -F '.' '{print $1}')

    # Check if the Docker version is less than 20.x
    if [[ $major_version -lt 20 ]]; then
        echo "Docker version $docker_version is not supported. Please upgrade to Docker 20.x or higher."
        exit 1
    fi
}

# Function to validate a URL (basic validation)
validate_url() {
  local url="$1"
  if ! [[ "$url" =~ ^https?:// ]]; then
    echo "Invalid URL. Please enter a valid URL."
    exit 1
  fi
}

# Function to validate a git provider value i.e. either GITLAB or GITHUB
validate_git_provider() {
  local git_provider_val="$1"
  if [ "$git_provider_val" == "GITLAB" ] || [ "$git_provider_val" == "GITHUB" ]; then
    #echo "Valid git provider value"
    echo
  else
    echo "Invalid git provider value. Please enter either GITLAB or GITHUB."
    exit 1
  fi
}

# Function to validate a boolean value i.e. string compare against "True" or "False"
validate_boolean() {
  local boolean_val="$1"
  if [ "$boolean_val" == "True" ] || [ "$boolean_val" == "False" ]; then
    #echo "Valid boolean value"
    echo
  else
    echo "Invalid boolean value. Please enter either True or False."
    exit 1
  fi
}

# Function to validate a mode value i.e. cli or server
validate_mode() {
  local mode_val="$1"
  if [ "$mode_val" == "cli" ] || [ "$mode_val" == "server" ]; then
    #echo "Valid mode value"
    echo
  else
    echo "Invalid mode value. Please enter either cli or server."
    exit 1
  fi    
}

# Check if a properties file is provided as an argument
if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <path-to-properties-file>"
  exit 1
fi

# Load properties from file
properties_file=$1
if [ ! -f "$properties_file" ]; then
    echo "Properties file not found!"
    exit 1
fi

#validate the bash versions and docker version
validate_bash_version
validate_docker_version

# Note down the hidden parameter for action directory
action_directory=
if [ "$#" -eq 2 ]; then
    action_directory=$2
    if [ ! -d "$action_directory" ]; then
        echo "Action directory not found!"
        exit 1
    fi
fi
#echo "Action Diretory: $action_directory"

# Read properties into an associative array
declare -A props
while IFS='=' read -r key value; do
  props["$key"]="$value"
done < "$properties_file"

# Function to ask for missing parameters
ask_for_param() {
  local param_name=$1
  local param_value=${props[$param_name]}
  local exit_on_empty=$2

  if [ -z "$param_value" ]; then
    read -p "Enter value for $param_name: " param_value
    if [ -z $param_value ] && [ $exit_on_empty == "True" ]; then
        echo "No input provided for $param_name. Exiting."
        exit 1
    else
        props[$param_name]=$param_value
    fi
  fi
}

# Parameters that are required/optional in mode cli
required_params_cli=(
  "mode"
  "pr_url"
  "git.provider"
  "git.access_token"
  "bito_cli.bito.access_key"
  "code_feedback"
)

optional_params_cli=(
  "static_analysis"
  "dependency_check"
  "dependency_check.snyk_auth_token"
  "cra_version"
)

# Parameters that are required/optional in mode server
required_params_server=(
  "mode"
  "code_feedback"
)

optional_params_server=(
  "git.provider"
  "git.access_token"
  "bito_cli.bito.access_key"
  "static_analysis"
  "dependency_check"
  "dependency_check.snyk_auth_token"
  "server_port"
  "cra_version"
)

bee_params=(
  "bee.path"
  "bee.actn_dir"
)

props["bee.path"]="/automation-platform"
if [ -z "$action_directory" ]; then
   props["bee.actn_dir"]="/automation-platform/default_bito_ad/bito_modules"
else
   props["bee.actn_dir"]="/action_dir"
fi

# CRA Version
cra_version="latest"

# Docker pull command
docker_pull='docker pull bitoai/cra:${cra_version}'

# Construct the docker run command
docker_cmd='docker run --rm -it'
if [ ! -z "$action_directory" ]; then
    docker_cmd='docker run --rm -it -v $action_directory:/action_dir'
fi

required_params=("${required_params_cli[@]}")
optional_params=("${optional_params_cli[@]}")
mode="cli"
param_mode="mode"
validate_mode "${props[$param_mode]}"
if [ "${props[$param_mode]}" == "server" ]; then
    mode="server"
    required_params=("${required_params_server[@]}")
    optional_params=("${optional_params_server[@]}")
    # Append -p and -d parameter in docker command
    docker_cmd+=' -p ${server_port}:${server_port} -d'
fi
echo "Bito Code Review Agent is running as: ${mode}"
echo ""
#echo Required Parameters: "${required_params[@]}"
#echo BEE Parameters: "${bee_params[@]}"
#echo Optional Parameters: "${optional_params[@]}"

# Append Docker Image and Tag Placeholder
docker_cmd+=' bitoai/cra:${cra_version}'

# Ask for required parameters if they are not set
for param in "${required_params[@]}"; do
  ask_for_param "$param" "True"
done

# Ask for optional parameters if they are not set
for param in "${optional_params[@]}"; do
  if [ "$param" == "dependency_check.snyk_auth_token" ] && [ "${props["dependency_check"]}" == "True" ]; then
      ask_for_param "$param" "False"
  elif [ "$param" != "dependency_check.snyk_auth_token" ]; then
      ask_for_param "$param" "False"
  fi
done

# Append parameters to the docker command
for param in "${required_params[@]}" "${bee_params[@]}" "${optional_params[@]}"; do

  #echo $param ${props[$param]}
  if [ -n "${props[$param]}" ]; then

    if [ "$param" == "cra_version" ]; then
        #assign docker image name
        cra_version="${props[$param]}"
    elif [ "$param" == "server_port" ]; then
        #assign docker port
        server_port="${props[$param]}"
        docker_cmd+=" --$param=${props[$param]}"
    elif [ "$param" == "pr_url" ]; then
        #validate the URL
        validate_url "${props[$param]}"
        docker_cmd+=" --$param=${props[$param]} review" 
    elif [ "$param" == "git.provider" ]; then
        #validate the URL
        validate_git_provider "${props[$param]}"
        docker_cmd+=" --$param=${props[$param]}" 
    elif [ "$param" == "static_analysis" ]; then
        #handle special case of static_analysis.fb_infer.enabled using static_analysis
        validate_boolean "${props[$param]}"
        docker_cmd+=" --static_analysis.fb_infer.enabled=${props[$param]}"
    elif [ "$param" == "dependency_check" ]; then
        #validate the dependency check boolean value
        validate_boolean "${props[$param]}"
        docker_cmd+=" --dependency_check.enabled=${props[$param]}" 
    elif [ "$param" == "mode" ]; then
        validate_mode "${props[$param]}"
        docker_cmd+=" --$param=${props[$param]}" 
    else
        docker_cmd+=" --$param=${props[$param]}"
    fi

  fi
done

param_bito_access_key="bito_cli.bito.access_key"
param_git_access_token="git.access_token"
if [ "$mode" == "server" ]; then
    if [ -n "${props[$param_bito_access_key]}" ] && [ -n "${props[$param_git_access_token]}" ]; then
        git_secret="${props[$param_bito_access_key]}@#~^${props[$param_git_access_token]}"

        echo "Use below as Gitlab and Github Webhook secret:"
        echo "$git_secret"
        echo
    fi
fi

# Execute the docker command
echo "Running command: $(eval echo $docker_pull)"
eval "$docker_pull"

if [ "$?" == 0 ]; then
	echo "Running command: $(eval echo $docker_cmd)"
	eval "$docker_cmd"
fi

