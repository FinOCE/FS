<#
.SYNOPSIS
  Starts all services to run the entire bot locally.
.DESCRIPTION
  This script starts all services to run the entire bot locally. All startup
  scripts are called to open terminal tabs for each service to effectively
  monitor logs and not need to run any services off the cloud.
#>

Function Launch-TerminalTab {
  Param(
    # The path to where the terminal tab should be opened.
    [Parameter(Mandatory=$false)]
    [string] $Path = '.',

    # The command to run in the terminal tab.
    [Parameter(Mandatory=$true)]
    [string] $Command
  )

  wt -w 0 -d $Path -p "Windows PowerShell" cmd /k $Command
}

Function Start-FunctionApp {
  Param(
    # The path to the function app to start.
    [Parameter(Mandatory=$true)]
    [string] $Path
  )

  Launch-TerminalTab -Path $Path -Command "func start"
  Write-Host "Started function app at $Path"
}

Start-FunctionApp -Path '.\InteractionGateway\InteractionGateway'
