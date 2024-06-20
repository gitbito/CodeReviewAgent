# Variables for temp files.
$BITOAIDIR = Join-Path $HOME ".bitoai"
if (-not (Test-Path $BITOAIDIR)) {
    New-Item -ItemType Directory -Path $BITOAIDIR
}
$BITOCRALOCKFILE = Join-Path $BITOAIDIR "bitocra.lock"
$BITOCRACID = Join-Path $BITOAIDIR "bitocra.cid"

# Function to validate Docker version 
function Validate-DockerVersion {
    # Get the Docker version
    $dockerVersion = docker version --format '{{.Server.Version}}'
    # Extract the major version number
    $majorVersion = ($dockerVersion -split '\.')[0]
    # Check if the Docker version is less than 20.x
    if ($majorVersion -lt 20) {
        Write-Host "Docker version $dockerVersion is not supported. Please upgrade to Docker 20.x or higher."
        exit 1
    }
}

# Function to validate PowerShell version 
function Validate-PowerShellVersion {
    # Get the PowerShell version
    $psVersion = $PSVersionTable.PSVersion
    # Extract the major version number
    $majorVersion = $psVersion.Major
    # Check if the PowerShell version is less than 4.x
    if ($majorVersion -lt 5) {
        Write-Host "PowerShell version $($psVersion.ToString()) is not supported. Please upgrade to PowerShell 5.x or higher."
        exit 1
    }
}

# Function to validate a URL (basic validation)
function Validate-Url {
    param($url)
    if (-not($url -match "^https?://")) {
        Write-Host "Invalid URL. Please enter a valid URL."
        exit 1
    }
}

# Function to validate a git provider value i.e. either GITLAB or GITHUB
function Validate-GitProvider {
    param($git_provider_val)

    # Convert the input to uppercase 
    $git_provider_val = $git_provider_val.ToUpper()

    # Check if the converted value is either "GITLAB" or "GITHUB"
    if ($git_provider_val -ne "GITLAB" -and $git_provider_val -ne "GITHUB") {
        Write-Host "Invalid git provider value. Please enter either GITLAB or GITHUB."
        exit 1
    }

    # Return the properly cased value
    return $git_provider_val
}

# Function to validate a boolean value i.e. string compare against "True" or "False"
function Validate-Boolean {
    param($boolean_val)
    # Convert the input to title case (first letter uppercase, rest lowercase)
    $boolean_val = $boolean_val.Substring(0,1).ToUpper() + $boolean_val.Substring(1).ToLower()

    # Check if the converted value is either "True" or "False"
    if ($boolean_val -ne "True" -and $boolean_val -ne "False") {
        Write-Host "Invalid boolean value. Please enter either True or False."
        exit 1
    }

    # Return the properly cased boolean value
    return $boolean_val
}

# Function to validate a mode value i.e. cli or server
function Validate-Mode {
    param($mode_val)
    if ($mode_val -ne "cli" -and $mode_val -ne "server") {
        Write-Host "Invalid mode value. Please enter either cli or server."
        exit 1
    }
}

# Function to validate an environment value i.e. prod or staging
function Validate-Env {
    param($env_val)

    if ($env_val -ne "prod" -and $env_val -ne "staging") {
      Write-Host "Invalid env value. Please enter either prod or staging."
      exit 1
    }
}

# Function to validate a review_comments vallue i.e. 1 mapped to "FULLPOST" or 2 mapped to "INLINE"
function Validate-ReviewComments {
    param($reviewcomments_val)

    # Check if the provided value is either "1" or "2"
    if ($reviewcomments_val -ne "1" -and $reviewcomments_val -ne "2") {
        Write-Host "Invalid review comments value. Please enter either 1 or 2."
        exit 1
    }

    if ($reviewcomments_val -eq "1") {
        return "FULLPOST"
    }

    if ($reviewcomments_val -eq "2") {
        return "INLINE"
    }
}

$crEventType = "automated"
function ValidateCrEventType {
    param($crEventTypeVal)
    if ($crEventTypeVal -eq "manual"){
        return "manual"
    }else {
        return "automated"
    }
}

# Function to display URL using IP address and port
# Run docker ps -l command and store the output
function Display-DockerUrl {

    # Run docker ps -l command and store the output
    $containerInfo = docker ps -l | Select-Object -Skip 1

    # Extract IP address and port number using regex
    $ipAddress = $containerInfo -replace '.*(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}):(\d+)->\d+/\w+.*', '$1'
    # Set IP address to 127.0.0.1 if it's 0.0.0.0
    if ($ipAddress -eq "0.0.0.0") {
        $ipAddress = "127.0.0.1"
    }
    $portNumber = $containerInfo -replace '.*\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}:(\d+)->\d+/\w+.*', '$1'

    # Print the IP address and port number
    #Write-Host "IP Address: $ipAddress"
    #Write-Host "Port Number: $portNumber"
    
    if ($ipAddress -ne '' -and $portNumber -ne '') {
        $url = "http://${ipAddress}:${portNumber}/"
        Write-Host ""
        Write-Host "Code Review Agent URL: $url"
        Write-Host "Note: Use the above URL to configure GITLAB/GITHUB webhook by replacing the IP address with the IP address or Domain Name of your server."
    }
}

function Display-Usage {
    Write-Host "Invalid command to execute Code Review Agent:"
    Write-Host ""
    Write-Host "Usage-1: $PSCommandPrefix <path-to-properties-file>"
    Write-Host "Usage-2: $PSCommandPrefix service start | restart <path-to-properties-file>"
    Write-Host "Usage-3: $PSCommandPrefix service stop"
    Write-Host "Usage-4: $PSCommandPrefix service status"
}

function Check-PropertyFile {
    param($prop_file)
    if (-not $prop_file) {
        Write-Host "Properties file not provided!"
        exit 1
    }
    if (-not(Test-Path $prop_file)) {
        Write-Host "Properties file not found!"
        exit 1
    }

    #return valid properties file
    return $prop_file
}

function Check-ActionDirectory {
    param($action_dir)
    if (-not $action_dir) {
        Write-Host "Action directory not provided!"
        exit 1
    }
    if (-not(Test-Path $action_dir -PathType Container)) {
        Write-Host "Action directory not found!"
        exit 1
    }

    #return valid action directory
    return $action_dir
}

# Function to check if the CLI directory exists
function Check-CliDirectory {
    param($cli_dir)

    if (-not $cli_dir) {
        Write-Host "CLI directory not provided!"
        exit 1
    }

    if (-not (Test-Path -Path $cli_dir -PathType Container)) {
        Write-Host "CLI directory not found!"
        exit 1
    }

    #return valid cli directory
    return $cli_dir
}

# Function to check if the output path directory exists
function Check-OutputDirectory {
    param($output_path)

    if (-not (Test-Path -Path $output_path -PathType Container)) {
        Write-Host "Output path directory not found!"
        exit 1
    }

    #return valid cli directory
    return $output_path
}

function Stop-CRA {
    if (Test-Path "$BITOCRALOCKFILE") {
        Write-Host "Stopping the CRA..."
        $fileContent = Get-Content -Path "$BITOCRALOCKFILE"
        $containerIdLine = $fileContent | Where-Object { $_ -like 'export CONTAINER_ID=*' }
        $containerId = $containerIdLine -replace 'export CONTAINER_ID=', ''
        docker stop $containerId
        $RET_VAL = $LASTEXITCODE
        if ($RET_VAL -ne 0) {
            Write-Host "Could not stop CRA"
            exit 1
        }
        Remove-Item -Path "$BITOCRALOCKFILE" -Force
    }
    else {
        Write-Host "CRA is not running."
    }
}

function Check-CRA {
    if (Test-Path "$BITOCRALOCKFILE") {
        Write-Host "CRA is running."
    }
    else {
        Write-Host "CRA is not running."
    }
}

# Check if a properties file is provided as an argument
if ($args.Count -lt 1) {
    $PSCommandPrefix = $MyInvocation.InvocationName
    Display-Usage
    exit 1
}

$properties_file = $null
$action_directory = $null
$force_mode = $null
if ($args.Count -gt 1) {
    if ($args[0] -eq "service") {
        switch ($args[1]) {
            "start" {
                $force_mode = "server"
                $properties_file = Check-PropertyFile $args[2]

                if (Test-Path "$BITOCRALOCKFILE") {
                    Write-Host "CRA is already running."
                    exit 0
                }

                Write-Host "Starting the CRA..."
                # Note down the hidden parameter for action directory
                if ($args.Count -eq 4) {
                    $action_directory = Check-ActionDirectory $args[3]
                    # Write-Host "Action Directory: $action_directory"
                }
            }
            "stop" {
                Stop-CRA
                exit 0
            }
            "restart" {
                $force_mode = "server"
                $properties_file = Check-PropertyFile $args[2]

                Stop-CRA
                Write-Host "Starting the CRA..."

                # Note down the hidden parameter for action directory
                if ($args.Count -eq 4) {
                    $action_directory = Check-ActionDirectory $args[3]
                    # Write-Host "Action Directory: $action_directory"
                }
            }
            "status" {
                Write-Host "Checking the CRA..."
                Check-CRA
                exit 0
            }
            default {
                $PSCommandPrefix = $MyInvocation.InvocationName
                Display-Usage
                exit 1
            }
        }
    }
    else {
        # Load properties from file
        $properties_file = Check-PropertyFile $args[0]

        # Note down the hidden parameter for action directory
        if ($args.Count -eq 2) {
            $action_directory = Check-ActionDirectory $args[1]
        }
    }
}
else {
    # Load properties from file
    $properties_file = Check-PropertyFile $args[0]
}

#validate the PowerShell version and docker version
Validate-PowerShellVersion
Validate-DockerVersion

# Read properties into a hashtable
$props = @{}
Get-Content $properties_file | ForEach-Object {
    $line = $_
    if (-not ($line -match '^#')) {
        $key, $value = $line -split '=', 2
        $props[$key.Trim()] = $value.Trim()
    }
}

# Function to ask for missing parameters
function Ask-For-Param {
    param($param_name, $exit_on_empty)
    $param_value = $props[$param_name]

    if ([string]::IsNullOrEmpty($param_value)) {
        $param_value = Read-Host "Enter value for $param_name"
        if ([string]::IsNullOrEmpty($param_value) -and $exit_on_empty) {
            Write-Host "No input provided for $param_name. Exiting."
            exit 1
        } else {
            $props[$param_name] = $param_value
        }
    }
}

# Parameters that are required/optional in mode cli
$required_params_cli = @(
    "mode",
    "pr_url",
    "git.provider",
    "git.access_token",
    "bito_cli.bito.access_key",
    "code_feedback"
)

$optional_params_cli = @(
    "review_comments",
    "static_analysis",
    "static_analysis_tool",
    "review_scope",
    "exclude_branches",
    "exclude_files",
    "exclude_draft_pr",
    "dependency_check",
    "dependency_check.snyk_auth_token",
    "cra_version",
    "env",
    "cli_path",
    "output_path"
    "git.domain"
    "code_context"
    "cr_event_type"
)

# Parameters that are required/optional in mode server
$required_params_server = @(
    "mode",
    "code_feedback"
)

$optional_params_server = @(
    "git.provider",
    "git.access_token",
    "bito_cli.bito.access_key",
    "review_comments",
    "static_analysis",
    "static_analysis_tool",
    "review_scope",
    "exclude_branches",
    "exclude_files",
    "exclude_draft_pr",
    "dependency_check",
    "dependency_check.snyk_auth_token",
    "server_port",
    "cra_version"
    "env"
    "cli_path"
    "git.domain"
    "code_context"
    "cr_event_type"
)

$bee_params = @(
    "bee.path",
    "bee.actn_dir"
)

$props["bee.path"] = "/automation-platform"
if ([string]::IsNullOrEmpty($action_directory)) {
    $props["bee.actn_dir"] = "/automation-platform/default_bito_ad/bito_modules"
} else {
    $props["bee.actn_dir"] = "/action_dir"
}

# CRA Version
$cra_version = "latest"
$param_cra_version = "cra_version"
if ($props[$param_cra_version] -ne '') {
    $cra_version = $props[$param_cra_version]
}

# Docker pull command
$docker_pull = "docker pull bitoai/cra:${cra_version}"

# Construct the docker run command
$docker_init_cmd = "docker run --rm -it"
if (-not([string]::IsNullOrEmpty($action_directory))) {
    $docker_init_cmd = "docker run --rm -it -v ${action_directory}:/action_dir"
}

$required_params = $required_params_cli
$optional_params = $optional_params_cli
$mode = "cli"
$param_mode = "mode"
$server_port = "10051"
$param_server_port = "server_port"
$command = "review"
$docker_cmd = ""
# handle if CRA is starting in server mode using start command.
if ($force_mode) {
    $props[$param_mode] = $force_mode
}
Validate-Mode $props[$param_mode]
if ($props[$param_mode] -eq "server") {
    $mode = "server"
    if ($props[$param_server_port] -ne '') {
        $server_port = $props[$param_server_port]
    }
    $required_params = $required_params_server
    $optional_params = $optional_params_server
    # Append -p and -d parameter in docker command
    $docker_cmd += " -p ${server_port}:${server_port} -d"
}
Write-Host "Bito Code Review Agent is running as: $mode"
Write-Host ""

# Append Docker Image and Tag Placeholder
$docker_cmd += " bitoai/cra:${cra_version}"

# Ask for required parameters if they are not set
foreach ($param in $required_params) {
    Ask-For-Param $param $true
}

# Ask for optional parameters if they are not set
foreach ($param in $optional_params) {
    if ($param -eq "dependency_check.snyk_auth_token" -and $props["dependency_check"] -eq "True") {
        Ask-For-Param $param $false
    } elseif ($param -ne "dependency_check.snyk_auth_token" -and $param -ne "env" -and $param -ne "cli_path" -and $param -ne "output_path" -and $param -ne "static_analysis_tool" -and $param -ne "git.domain" -and $param -ne "review_scope" -and $param -ne "exclude_branches" -and $param -ne "exclude_files" -and $param -ne "exclude_draft_pr" -and $param -ne "cr_event_type") {
        Ask-For-Param $param $false
    }
}

# Append parameters to the docker command
foreach ($param in $required_params + $bee_params + $optional_params) {
    if (-not([string]::IsNullOrEmpty($props[$param]))) {
        if ($param -eq "cra_version") {
            $cra_version = $props[$param]
        } elseif ($param -eq "server_port") {
            #assign docker port
            $server_port = $props[$param]
            $docker_cmd += " --$param=$($props[$param])"
        } elseif ($param -eq "pr_url") {
            $trimmedUrl = $props[$param].Trim()
            Validate-Url $trimmedUrl
            $docker_cmd += " --$param=$($trimmedUrl) --command=$($command) rest"
        } elseif ($param -eq "git.provider") {
            $validated_gitprovider = Validate-GitProvider $props[$param]
            $docker_cmd += " --$param=$validated_gitprovider"
        } elseif ($param -eq "static_analysis") {
            $validated_boolean = Validate-Boolean $props[$param]
            $docker_cmd += " --static_analysis.fb_infer.enabled=$validated_boolean"
        } elseif ($param -eq "static_analysis_tool") {
            $docker_cmd += " --$param=$($props[$param])"
        } elseif ($param -eq "review_scope") {
            $scopes = $($props[$param]) -replace ',\s*', ','
            $docker_cmd += " --$param='[$scopes]'"
        } elseif ($param -eq "exclude_branches") {
            $docker_cmd += " --exclude_branches='$($props[$param])'"
        } elseif ($param -eq "exclude_files") {
            $docker_cmd += " --exclude_files='$($props[$param])'"
        } elseif ($param -eq "exclude_draft_pr") {
            $docker_cmd += " --exclude_draft_pr=$($props[$param])"
        } elseif ($param -eq "dependency_check") {
            $validated_boolean = Validate-Boolean $props[$param]
            $docker_cmd += " --dependency_check.enabled=$validated_boolean"
        } elseif ($param -eq "code_feedback") {
            $validated_boolean = Validate-Boolean $props[$param]
            $docker_cmd += " --$param=$validated_boolean"
        } elseif ($param -eq "code_context") {
            #validate the code context boolean value
            $validated_boolean = Validate-Boolean $props[$param]
            $docker_cmd += " --$param=$validated_boolean"
        } elseif ($param -eq "mode") {
            Validate-Mode $props[$param]
            $docker_cmd += " --$param=$($props[$param])"
        } elseif ($param -eq "env") {
            Validate-Env $props[$param]
            $docker_cmd += " --$param=$($props[$param])"
        } elseif ($param -eq "cli_path") {
            $cli_dir = Check-CliDirectory $($props[$param])
            $docker_init_cmd += " -v ${cli_dir}:/cli_dir"
        } elseif ($param -eq "output_path") {
            if ($($props[$param]) -ne $null -and $($props[$param]) -ne "") {
                $output_path = Check-OutputDirectory $($props[$param])
                if ($output_path -ne $null -and $output_path -ne "") {
                    $docker_init_cmd += " -v '${output_path}:/output_path'"
                    $docker_cmd += " --$param=/output_path"
                }
            }
        } elseif ($param -eq "review_comments") {
            $review_comments = Validate-ReviewComments $props[$param]
            $docker_cmd += " --$param=$review_comments"
        } elseif ($param -eq "cr_event_type") {
            $crEventType = ValidateCrEventType $props[$param]
        } else {
            $docker_cmd += " --$param=$($props[$param])"
        }
    }
}
$docker_cmd += " --cr_event_type=$crEventType"
$docker_cmd = $docker_init_cmd + $docker_cmd

function Encrypt-GitSecret {
    param (
        [string]$key,
        [string]$plaintext
    )

    # Convert key to hex
    $hexKey = [BitConverter]::ToString([Text.Encoding]::UTF8.GetBytes($key)).Replace("-", "").ToLower()

    # Generate IV (Initialization Vector)
    $ivBytes = New-Object byte[] 16
    [Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($ivBytes)
    $iv = [Convert]::ToBase64String($ivBytes)
    $ivHex = [BitConverter]::ToString($ivBytes).Replace("-", "").ToLower()

    $ciphertext = "$plaintext" | openssl enc -aes-256-cfb -a -K "$hexKey" -iv "$ivHex" -base64

    # Concatenate IV and ciphertext and encode with base64
    $encryptedText = $ivHex + "$ciphertext" -replace " ", "" -replace "`r`n", "" -replace "`n", "" -replace "`r", ""

    # Output the encrypted text
    return $encryptedText
}

$docker_run_command_log = $docker_cmd
$param_bito_access_key = "bito_cli.bito.access_key"
$param_git_access_token = "git.access_token"
$docker_enc_params=

if ($mode -eq "server") {
    if (-not([string]::IsNullOrEmpty($props[$param_bito_access_key])) -and -not([string]::IsNullOrEmpty($props[$param_git_access_token]))) {
        $git_secret = "$($props[$param_bito_access_key])@#~^$($props[$param_git_access_token])"
        $encryption_key = [System.Convert]::ToBase64String((1..32 | ForEach-Object { [byte](Get-Random -Minimum 0 -Maximum 256) }))
        $git_secret_encrypted = Encrypt-GitSecret -key $encryption_key -plaintext $git_secret
        $docker_enc_params=" --git.secret=$git_secret_encrypted --encryption_key=$encryption_key"
        $docker_cmd += " ${docker_enc_params}"
        
        Write-Host "Use below as Gitlab and Github Webhook secret:"
        Write-Host $git_secret_encrypted
        Write-Host
    }

    $docker_cmd += " > ""$BITOCRACID"""
}

# Execute the docker command
Write-Host "Running command: $($docker_pull)"
Invoke-Expression $docker_pull

if ($LASTEXITCODE -eq 0) {
    Write-Host "Running command: $($docker_run_command_log)"
    Invoke-Expression $docker_cmd

    if ($LASTEXITCODE -eq 0 -and $mode -eq "server") {
        Display-DockerUrl
        $continerIdLine = "export CONTAINER_ID="
        $continerIdLine += (Get-Content "$BITOCRACID")
        Set-Content -Path "$BITOCRALOCKFILE" -Value "$continerIdLine"
        Remove-Item -Path "$BITOCRACID" -Force
    }
}

