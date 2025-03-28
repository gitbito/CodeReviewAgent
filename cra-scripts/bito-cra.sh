#!/usr/bin/env bash
#set -x

# Variables for temp files.
BITOAIDIR="$HOME/.bitoai"
mkdir -p $BITOAIDIR
BITOCRALOCKFILE=$BITOAIDIR/bitocra.lock
BITOCRACID=$BITOAIDIR/bitocra.cid

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
  local git_provider_val=$(echo "$1" | tr '[:lower:]' '[:upper:]')

  if [ "$git_provider_val" == "GITLAB" ] || [ "$git_provider_val" == "GITHUB" ] || [ "$git_provider_val" == "BITBUCKET" ]; then
    echo $git_provider_val
  else
    echo "Invalid git provider value. Please enter either GITLAB or GITHUB or BITBUCKET."
    exit 1
  fi
}

# Function to validate a boolean value i.e. string compare against "True" or "False"
validate_boolean() {
  local boolean_val="$(echo "$1" | awk '{print tolower($0)}')"
  if [ "$boolean_val" == "true" ]; then
    echo "True"
  elif [ "$boolean_val" == "false" ]; then
    echo "False"
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

# Function to validate a env value i.e. prod or staging
validate_env() {
  local env="$1"
  if [ "$env" == "prod" ] || [ "$env" == "staging" ] || [ "$env" == "preprod" ]; then
    #echo "Valid mode value"
    echo
  else
    echo "Invalid mode value. Please enter either prod or staging or preprod."
    exit 1
  fi
}

cr_event_type="automated"
validate_cr_event_type() {
  local cr_event_type_val="$1"
  if [ "$cr_event_type_val" == "manual" ]; then
    cr_event_type=$cr_event_type_val
    echo
  fi
}

posting_to_pr="True"
validate_posting_to_pr() {
  local boolean_val="$(echo "$1" | awk '{print tolower($0)}')"
  if [ "$boolean_val" == "true" ]; then
    posting_to_pr="True"
  elif [ "$boolean_val" == "false" ]; then
    posting_to_pr="False"
  fi
}

# Function to validate a review_comments vallue i.e. 1 mapped to "FULLPOST" or 2 mapped to "INLINE"
validate_review_comments() {
  local review_comments="$1"
  if [ "$review_comments" == "1" ]; then
    echo "FULLPOST"
  elif [ "$review_comments" == "2" ]; then
    echo "INLINE"
  else
    echo "Invalid review comments value. Please enter either 1 or 2."
    exit 1
  fi
}

# Function to display URL using IP address and port
# Run docker ps -l command and store the output
display_docker_url() {
  container_info=$(docker ps -l | tail -n +2)

  # Extract IP address and port number using awk
  ip_address=$(echo "$container_info" | awk 'NR>0 {print $(NF-1)}' | cut -d':' -f1)
  #container_id=$(echo "$container_info" | awk 'NR>0 {print $1}')
  #ip_address=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$container_id")
  #if [[ $(uname) == "Darwin" ]]; then
  #  ip_address=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}')
  #else
  #  ip_address=$(ip route get 1 | awk '{print $NF;exit}')
  #fi
  if [ "$ip_address" == "0.0.0.0" ]; then
    ip_address="127.0.0.1" 
  fi
  port_number=$(echo "$container_info" | awk 'NR>0 {print $(NF-1)}' | cut -d'-' -f1 | cut -d':' -f2)

  # Print the IP address and port number
  #echo "IP Address: $ip_address"
  #echo "Port Number: $port_number"

  if [ -n "$ip_address" ] && [ -n "$port_number" ]; then
    # Construct the URL
    url="http://${ip_address}:${port_number}/"

    # Print the URL
    echo ""
    echo "Code Review Agent URL: $url"
    echo "Note: Use above URL to configure GITLAB/GITHUB webhook by replacing IP adderss with the IP address or Domain Name of your server."
  fi
}

display_usage() {
  echo "Invalid command to execute Code Review Agent:"
  echo
  echo "Usage-1: $0 <path-to-properties-file>"
  echo "Usage-2: $0 service start | restart <path-to-properties-file>"
  echo "Usage-3: $0 service stop"
  echo "Usage-4: $0 service status"
  echo "Usage-5: $0 <path-to-properties-file> pr_url=<url-value>"
}

check_properties_file() {
  local prop_file="$1"
  if [ -z "$prop_file" ]; then
    echo "Properties file not provided!"
    return 1
  fi
  if [ ! -f "$prop_file" ]; then
    echo "Properties file not found!"
    return 1
  else
    echo $prop_file
    return 0
  fi
}

check_action_directory() {
  local action_dir="$1"
  if [ -z "$action_dir" ]; then
    echo "Action directory not provided!"
    return 1
  fi
  if [ ! -d "$action_dir" ]; then
    echo "Action directory not found!"
    return 1
  else
    echo $action_dir
    return 0
  fi
}

check_cli_directory() {
  local cli_dir="$1"
  if [ -z "$cli_dir" ]; then
    echo "cli directory not provided!"
    return 1
  fi
  if [ ! -d "$cli_dir" ]; then
    echo "cli directory not found!"
    return 1
  else
    echo $cli_dir
    return 0
  fi
}

check_output_directory() {
  local output_path="$1"
  if [ ! -d "$output_path" ]; then
    echo "output path directory not found!"
    return 1
  else
    echo "Output Path: $output_path"
    return 0
  fi
}

stop_cra() {
  if test -f "$BITOCRALOCKFILE"; then
    echo "Stopping the CRA..."
    source "$BITOCRALOCKFILE"
    docker stop "$CONTAINER_ID"
    RET_VAL=`echo $?`
    if [ $RET_VAL -ne 0 ]; then
      echo "Could not stop CRA"
      exit 1
    fi
    rm -rf "$BITOCRALOCKFILE"
  else
    echo "CRA is not running."
  fi
}

check_cra() {
  if test -f "$BITOCRALOCKFILE"; then
    echo "CRA is running."
  else
    echo "CRA is not running."
  fi
}

# Check if a properties file is provided as an argument
if [ "$#" -lt 1 ]; then
  display_usage
  exit 1
fi

properties_file=
action_directory=
force_mode=
pr_url_arg=

process_pr_url_or_action_dir_param() {
  local param="$1"

  if [[ "$param" == pr_url=* ]]; then
    pr_url_arg="${param#*=}"
  else
    action_directory=$(check_action_directory "$param")
    if [ $? -ne 0 ]; then
      echo "Action directory not found!"
      exit 1
    fi
  fi
}

if [ "$#" -gt 1 ]; then
  if [ "$1" == "service" ]; then
    case "$2" in
      start)
        force_mode="server"
        properties_file=$(check_properties_file "$3")
        if [ $? -ne 0 ]; then
          echo "Properties file not found!"
          exit 1
        fi
        if test -f "$BITOCRALOCKFILE"; then
          echo "CRA is already running."
          exit 0
        fi

        echo "Starting the CRA..."

        # Note down the hidden parameter for action directory
        if [ "$#" -eq 4 ]; then
          action_directory=$(check_action_directory "$4")
          if [ $? -ne 0 ]; then
            echo "Action directory not found!"
            exit 1
          fi
          #echo "Action Diretory: $action_directory"
        fi
        ;;
      stop)
        stop_cra
        exit 0
        ;;
      restart)
        force_mode="server"
        properties_file=$(check_properties_file "$3")
        if [ $? -ne 0 ]; then
          echo "Properties file not found!"
          exit 1
        fi

        stop_cra
        echo "Starting the CRA..."

        # Note down the hidden parameter for action directory
        if [ "$#" -eq 4 ]; then
          action_directory=$(check_action_directory "$4")
          if [ $? -ne 0 ]; then
            echo "Action directory not found!"
            exit 1
          fi
          #echo "Action Diretory: $action_directory"
        fi
        ;;
      status)
        echo "Checking the CRA..."
        check_cra
        exit 0
        ;;
      *)
        display_usage
        exit 1
        ;;
    esac
  else
    # Load properties from file
    properties_file=$(check_properties_file "$1")
    if [ $? -ne 0 ]; then
      echo "Properties file not found!"
      exit 1
    fi

    # Note down the hidden parameter for action directory
    if [ "$#" -eq 2 ]; then
      #check if 2nd argument is like pr_url=<value> then extract value else check the action_directory
      process_pr_url_or_action_dir_param "$2"
    fi

    if [ "$#" -eq 3 ]; then
      #check if 2nd argument is like pr_url=<value> then extract value else check the action_directory
      process_pr_url_or_action_dir_param "$2"

      #check if 3rd argument is like pr_url=<value> then extract value else check the action_directory
      process_pr_url_or_action_dir_param "$3"
    fi
  fi
else
  # Load properties from file
  properties_file=$(check_properties_file "$1")
  if [ $? -ne 0 ]; then
    echo "Properties file not found!"
    exit 1
  fi
fi

#validate the bash versions and docker version
validate_bash_version
validate_docker_version

# Read properties into an associative array
declare -A props
while IFS='=' read -r key value; do
    # Skip lines starting with #
    if [[ "$key" != \#* ]]; then
        props["$key"]="$value"
    fi
done < "$properties_file"

# Override pr_url if provided as an argument
if [ -n "$pr_url_arg" ]; then
  props["pr_url"]="$pr_url_arg"
fi

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
  "acceptable_suggestions_enabled"
  "review_comments"
  "static_analysis"
  "static_analysis_tool"
  "linters_feedback"
  "secret_scanner_feedback"
  "review_scope"
  "enable_default_branch"
  "exclude_branches"
  "include_branches"
  "exclude_files"
  "exclude_draft_pr"
  "dependency_check"
  "dependency_check.snyk_auth_token"
  "cra_version"
  "env"
  "cli_path"
  "output_path"
  "git.domain"
  "code_context"
  "nexus_url"
  "cr_event_type"
  "posting_to_pr"
  "custom_rules.configured_ws_ids"
  "custom_rules.aws_access_key_id"
  "custom_rules.aws_secret_access_key"
  "custom_rules.region_name"
  "custom_rules.bucket_name"
  "custom_rules.aes_key"
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
  "acceptable_suggestions_enabled"
  "review_comments"
  "static_analysis"
  "static_analysis_tool"
  "linters_feedback"
  "secret_scanner_feedback"
  "review_scope"
  "enable_default_branch"
  "exclude_branches"
  "include_branches"
  "exclude_files"
  "exclude_draft_pr"
  "dependency_check"
  "dependency_check.snyk_auth_token"
  "server_port"
  "cra_version"
  "env"
  "cli_path"
  "git.domain"
  "code_context"
  "nexus_url"
  "cr_event_type"
  "custom_rules.configured_ws_ids"
  "custom_rules.aws_access_key_id"
  "custom_rules.aws_secret_access_key"
  "custom_rules.region_name"
  "custom_rules.bucket_name"
  "custom_rules.aes_key"
  "output_path"
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
nexus_url=

# Construct the docker run command
docker_init_cmd='docker run --rm -it'
if [ ! -z "$action_directory" ]; then
    docker_init_cmd='docker run --rm -it -v $action_directory:/action_dir'
fi

required_params=("${required_params_cli[@]}")
optional_params=("${optional_params_cli[@]}")
mode="cli"
param_mode="mode"
command="review"
docker_cmd=""
#handle if CRA is starting in server mode using start command.
if [ -n "$force_mode" ]; then
  props[$param_mode]="$force_mode"
fi
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
docker_repo="bitoai/cra"
docker_cmd+=' ${docker_repo}:${cra_version}'


# Ask for required parameters if they are not set
for param in "${required_params[@]}"; do
  ask_for_param "$param" "True"
done

# Ask for optional parameters if they are not set
for param in "${optional_params[@]}"; do
  if [ "$param" == "dependency_check.snyk_auth_token" ] && [ "${props["dependency_check"]}" == "True" ]; then
      ask_for_param "$param" "False"
  elif [ "$param" != "acceptable_suggestions_enabled" ] && [ "$param" != "dependency_check.snyk_auth_token" ] && [ "$param" != "env" ] && [ "$param" != "cli_path" ] && [ "$param" != "output_path" ] && [ "$param" != "static_analysis_tool" ]  && [ "$param" != "linters_feedback" ] && [ "$param" != "secret_scanner_feedback" ] && [ "$param" != "enable_default_branch" ] && [ "$param" != "git.domain" ] && [ "$param" != "review_scope" ] && [ "$param" != "exclude_branches" ] && [ "$param" != "include_branches" ] && [ "$param" != "nexus_url" ] && [ "$param" != "exclude_files" ] && [ "$param" != "exclude_draft_pr" ] && [ "$param" != "cr_event_type" ] && [ "$param" != "posting_to_pr" ] && [ "$param" != "custom_rules.configured_ws_ids" ] && [ "$param" != "custom_rules.aws_access_key_id" ] && [ "$param" != "custom_rules.aws_secret_access_key" ] && [ "$param" != "custom_rules.region_name" ] && [ "$param" != "custom_rules.bucket_name" ] && [ "$param" != "custom_rules.aes_key" ] && [ "$param" != "code_context_config.partial_timeout" ] && [ "$param" != "code_context_config.max_depth" ] && [ "$param" != "code_context_config.kill_timeout_sec" ]; then
      ask_for_param "$param" "False"
  fi
done

# Append parameters to the docker command
for param in "${required_params[@]}" "${bee_params[@]}" "${optional_params[@]}"; do

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
        trimmed_url=$(echo "${props[$param]}" | sed 's/^[ \t]*//;s/[ \t]*$//')
        validate_url $trimmed_url
        docker_cmd+=" --$param=${trimmed_url} --command='${command}' rest"
    elif [ "$param" == "git.provider" ]; then
        #validate the URL
        props[$param]=$(validate_git_provider "${props[$param]}")
        docker_cmd+=" --$param=${props[$param]}" 
    elif [ "$param" == "static_analysis" ]; then
        #handle special case of static_analysis.fb_infer.enabled using static_analysis
        props[$param]=$(validate_boolean "${props[$param]}")
        docker_cmd+=" --static_analysis.fb_infer.enabled=${props[$param]}"
    elif [ "$param" == "static_analysis_tool" ]; then
        docker_cmd+=" --static_analysis_tool=${props[$param]}"
    elif [ "$param" == "linters_feedback" ]; then
        props[$param]=$(validate_boolean "${props[$param]}")
        docker_cmd+=" --linters_feedback=${props[$param]}"
    elif [ "$param" == "secret_scanner_feedback" ]; then
        props[$param]=$(validate_boolean "${props[$param]}")
        docker_cmd+=" --secret_scanner_feedback=${props[$param]}"
    elif [ "$param" == "acceptable_suggestions_enabled" ]; then
        props[$param]=$(validate_boolean "${props[$param]}")
        docker_cmd+=" --acceptable_suggestions_enabled=${props[$param]}"
    elif [ "$param" == "review_scope" ]; then
        scopes=$(echo ${props[$param]} | sed 's/, */,/g')
        docker_cmd+=" --review_scope='[$scopes]'"
    elif [ "$param" == "enable_default_branch" ]; then
        props[$param]=$(validate_boolean "${props[$param]}")
        docker_cmd+=" --enable_default_branch=${props[$param]}"
    elif [ "$param" == "exclude_branches" ]; then
        docker_cmd+=" --exclude_branches='${props[$param]}'"
    elif [ "$param" == "include_branches" ]; then
        docker_cmd+=" --include_branches='${props[$param]}'"
    elif [ "$param" == "exclude_files" ]; then
        docker_cmd+=" --exclude_files='${props[$param]}'"
    elif [ "$param" == "exclude_draft_pr" ]; then
        docker_cmd+=" --exclude_draft_pr=${props[$param]}"
    elif [ "$param" == "dependency_check" ]; then
        #validate the dependency check boolean value
        props[$param]=$(validate_boolean "${props[$param]}")
        docker_cmd+=" --dependency_check.enabled=${props[$param]}" 
    elif [ "$param" == "code_feedback" ]; then
        #validate the code feedback boolean value
        props[$param]=$(validate_boolean "${props[$param]}")
        docker_cmd+=" --$param=${props[$param]}"
    elif [ "$param" == "code_context" ]; then
        #validate the code context boolean value
        props[$param]=$(validate_boolean "${props[$param]}")
        docker_cmd+=" --$param=${props[$param]}"
    elif [ "$param" == "mode" ]; then
        validate_mode "${props[$param]}"
        docker_cmd+=" --$param=${props[$param]}"
    elif [ "$param" == "env" ]; then
        validate_env "${props[$param]}"
        docker_cmd+=" --$param=${props[$param]}"
    elif [ "$param" == "cli_path" ]; then
        check_cli_directory "${props[$param]}"
        cli_dir=${props[$param]}
        docker_init_cmd+='  -v $cli_dir:/cli_dir'
    elif [ "$param" == "output_path" ]; then
        if [ -n "${props[$param]}" ]; then
          check_output_directory "${props[$param]}"
          return_val=$? # Capture the return value of the check output directory
          if [ $return_val -eq 0 ]; then
            output_path=${props[$param]}
            docker_init_cmd+=' -v "$output_path":/output_path'
            docker_cmd+=" --$param=/output_path"
          fi
        fi
    elif [ "$param" == "review_comments" ]; then
        #validate the review comments value
        props[$param]=$(validate_review_comments "${props[$param]}")
        return_val=$? # Capture the return value of the check output directory
        if [ $return_val -eq 0 ]; then
          docker_cmd+=" --$param=${props[$param]}"
        else 
          echo "Invalid value provided for review_comments. Exiting."
          exit 1
        fi
    elif [ "$param" == "nexus_url" ]; then
        nexus_url=$(echo "${props[$param]}" | sed 's/^[ \t]*//;s/[ \t]*$//')
    elif [ "$param" == "cr_event_type" ]; then
        validate_cr_event_type "${props[$param]}"
    elif [ "$param" == "posting_to_pr" ]; then
        validate_posting_to_pr "${props[$param]}"
    else
        docker_cmd+=" --$param=${props[$param]}"
    fi

  fi
done
docker_cmd+=" --cr_event_type=${cr_event_type}"
docker_cmd+=" --posting_to_pr=${posting_to_pr}"
docker_cmd=$docker_init_cmd$docker_cmd
docker_cmd+=' ${docker_enc_params}'

# Function to encrypt text
encrypt_git_secret() {
  local key=$1
  local plaintext=$2

  # Convert key to hex
  local hex_key=$(echo -n "$key" | xxd -p -c 256)

  # Generate IV (Initialization Vector)
  local iv=$(openssl rand -base64 16)
  iv="$(echo -n "$iv" | base64 -d | xxd -p -c 256)"

  # Encrypt plaintext
  local ciphertext=$(echo -n "$plaintext" | openssl enc -aes-256-cfb -a -K "$hex_key" -iv "$iv" -base64)

  # Concatenate IV and ciphertext and encode with base64
  local iv_ciphertext=$(echo -n "$iv")$(echo -n "$ciphertext")

  # Encode the concatenated result with base64
  local encrypted_text=$(echo -n "$iv_ciphertext" | tr -d '\n')

  echo "$encrypted_text"
}

param_bito_access_key="bito_cli.bito.access_key"
param_git_access_token="git.access_token"

docker_enc_params=
if [ "$mode" == "server" ]; then
    if [ -n "${props[$param_bito_access_key]}" ] && [ -n "${props[$param_git_access_token]}" ]; then
        git_secret="${props[$param_bito_access_key]}@#~^${props[$param_git_access_token]}"
        encryption_key=$(openssl rand -base64 32)
        git_secret=$(encrypt_git_secret "$encryption_key" "$git_secret")
        docker_enc_params=" --git.secret=$git_secret --encryption_key=$encryption_key"
        
        echo "Use below as Gitlab and Github Webhook secret:"
        echo "$git_secret"
        echo
    fi

    docker_cmd+=" > \"$BITOCRACID\""
fi

# Execute the docker command
echo "Running command: $(eval echo $docker_pull)"
eval "$docker_pull"


if [ "$?" == 0 ] ; then
  echo "Docker image pulled successfully."
else
  if [[ -n "$nexus_url" ]]; then
    nexus_pull='docker pull ${nexus_url}/cra:${cra_version}'
    echo "Running command: $(eval echo $nexus_pull)"
    eval "$nexus_pull"
    if [ "$?" == 0 ]; then
      docker_repo='${nexus_url}/cra'
      docker_repo=$(eval echo "$docker_repo")
      echo "Successfully pulled docker image from Nexus."
    else
      echo "Failed to pull docker image from Nexus."
    fi
  fi
fi


if [ "$?" == 0 ]; then
	echo "Running command: $(echo eval $docker_cmd)"
	eval "$docker_cmd"

        if [ "$?" == 0 ] && [ "$mode" == "server" ]; then
            display_docker_url
            printf "export CONTAINER_ID=" > "$BITOCRALOCKFILE"
            cat "$BITOCRACID" >> "$BITOCRALOCKFILE"
            rm -rf "$BITOCRACID"
        fi
fi

