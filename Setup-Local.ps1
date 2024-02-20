<#
.SYNOPSIS
  Generate settings files for local development.
.DESCRIPTION
  This script generates settings files for local development. This is run when
  a new local environment needs to be setup for development.
#>
Param(
  # The connection string to the database. For local development, all services
  # share the same database. This is not the same as in production.
  [Parameter(Mandatory=$true)]
  [string] $CosmosDbConnectionString
)

Function New-LocalSettings {
  Param(
    # The path where the local.settings.json file will be created.
    [Parameter(Mandatory=$true)]
    [string] $Path,

    # The runtime that the function app runs on.
    [Parameter(Mandatory=$true)]
    [string] $Runtime,

    # The environment variables to add, supplied as a hashtable.
    [Parameter(Mandatory=$false)]
    [hashtable] $Variables = @{}
  )

  $Path = Join-Path $Path 'local.settings.json'

  $hashtable = @{
    'IsEncrypted' = $false
    'Values' = @{
      'AzureWebJobsStorage' = 'UseDevelopmentStorage=true'
      'FUNCTIONS_WORKER_RUNTIME' = $Runtime
    }
  }

  Foreach ($variable in $Variables.GetEnumerator()) {
    $hashtable['Values'][$variable.Key] = $variable.Value
  }

  ConvertTo-Json $hashtable | Out-File -FilePath $Path
}

New-LocalSettings -Path '.\InteractionGateway\InteractionGateway' -Runtime 'dotnet'
