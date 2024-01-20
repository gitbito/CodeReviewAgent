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
    if ($git_provider_val -ne "GITLAB" -and $git_provider_val -ne "GITHUB") {
        Write-Host "Invalid git provider value. Please enter either GITLAB or GITHUB."
        exit 1
    }
}

# Function to validate a boolean value i.e. string compare against "True" or "False"
function Validate-Boolean {
    param($boolean_val)
    if ($boolean_val -ne "True" -and $boolean_val -ne "False") {
        Write-Host "Invalid boolean value. Please enter either True or False."
        exit 1
    }
}

# Function to validate a mode value i.e. cli or server
function Validate-Mode {
    param($mode_val)
    if ($mode_val -ne "cli" -and $mode_val -ne "server") {
        Write-Host "Invalid mode value. Please enter either cli or server."
        exit 1
    }
}

# Check if a properties file is provided as an argument
if ($args.Count -lt 1) {
    Write-Host "Usage: $0 <path-to-properties-file>"
    exit 1
}

# Load properties from file
$properties_file = $args[0]
if (-not(Test-Path $properties_file)) {
    Write-Host "Properties file not found!"
    exit 1
}

#validate the PowerShell version and docker version
Validate-PowerShellVersion
Validate-DockerVersion

# Note down the hidden parameter for action directory
$action_directory = $null
if ($args.Count -eq 2) {
    $action_directory = $args[1]
    if (-not(Test-Path $action_directory -PathType Container)) {
        Write-Host "Action directory not found!"
        exit 1
    }
}

# Read properties into a hashtable
$props = @{}
Get-Content $properties_file | ForEach-Object {
    $key, $value = $_ -split '=', 2
    $props[$key] = $value
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
    "static_analysis",
    "dependency_check",
    "dependency_check.snyk_auth_token",
    "cra_version"
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
    "static_analysis",
    "dependency_check",
    "dependency_check.snyk_auth_token",
    "server_port",
    "cra_version"
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

# Docker pull command
$docker_pull = "docker pull bitoai/cra:${cra_version}"

# Construct the docker run command
$docker_cmd = "docker run --rm -it bitoai/cra:${cra_version}"
if (-not([string]::IsNullOrEmpty($action_directory))) {
    $docker_cmd = "docker run --rm -it -v ${action_directory}:/action_dir bitoai/cra:${cra_version}"
}

$required_params = $required_params_cli
$optional_params = $optional_params_cli
$mode = "cli"
$param_mode = "mode"
Validate-Mode $props[$param_mode]
if ($props[$param_mode] -eq "server") {
    $mode = "server"
    $required_params = $required_params_server
    $optional_params = $optional_params_server
}
Write-Host "Bito Code Review Agent is running as: $mode"
Write-Host ""

# Ask for required parameters if they are not set
foreach ($param in $required_params) {
    Ask-For-Param $param $true
}

# Ask for optional parameters if they are not set
foreach ($param in $optional_params) {
    if ($param -eq "dependency_check.snyk_auth_token" -and $props["dependency_check"] -eq "True") {
        Ask-For-Param $param $false
    } elseif ($param -ne "dependency_check.snyk_auth_token") {
        Ask-For-Param $param $false
    }
}

# Append parameters to the docker command
foreach ($param in $required_params + $bee_params + $optional_params) {
    if (-not([string]::IsNullOrEmpty($props[$param]))) {
        if ($param -eq "cra_version") {
            $cra_version = $props[$param]
        } elseif ($param -eq "pr_url") {
            Validate-Url $props[$param]
            $docker_cmd += " --$param=$($props[$param]) review"
        } elseif ($param -eq "git.provider") {
            Validate-GitProvider $props[$param]
            $docker_cmd += " --$param=$($props[$param])"
        } elseif ($param -eq "static_analysis") {
            Validate-Boolean $props[$param]
            $docker_cmd += " --static_analysis.fb_infer.enabled=$($props[$param])"
        } elseif ($param -eq "dependency_check") {
            Validate-Boolean $props[$param]
            $docker_cmd += " --dependency_check.enabled=$($props[$param])"
        } elseif ($param -eq "mode") {
            Validate-Mode $props[$param]
            $docker_cmd += " --$param=$($props[$param])"
        } else {
            $docker_cmd += " --$param=$($props[$param])"
        }
    }
}

$param_bito_access_key = "bito_cli.bito.access_key"
$param_git_access_token = "git.access_token"
if ($mode -eq "server") {
    if (-not([string]::IsNullOrEmpty($props[$param_bito_access_key])) -and -not([string]::IsNullOrEmpty($props[$param_git_access_token]))) {
        $git_secret = "$($props[$param_bito_access_key])@#~^$($props[$param_git_access_token])"

        Write-Host "Use below as Gitlab and Github Webhook secret:"
        Write-Host $git_secret
        Write-Host
    }
}

# Execute the docker command
Write-Host "Running command: $($docker_pull)"
Invoke-Expression $docker_pull

if ($LASTEXITCODE -eq 0) {
    Write-Host "Running command: $($docker_cmd)"
    Invoke-Expression $docker_cmd
}

