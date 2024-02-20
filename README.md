# FS

A Discord gateway bot built for the cloud running on Azure's serverless platform.

## Setup

This project relies on powershell for some local development tools, and has only been tested on Windows. All runtimes used are compatible with other operating systems, however using these scripts relies on powershell support on them matching Windows.

This bot uses Azure Cosmos DB, so you need to start an emulator for it in order to run the bot locally. This can be done using the Azure Cosmos DB Emulator for Windows, running in a Docker container, or provisioning an instance on Azure directly.

After cloning the repository, run the following command with variables specific to your local environment:

```powershell
.\Setup-Local -CosmosDbConnectionString "???"
```

### Running Locally

1. Start your Azure Cosmos DB Emulator
2. Run the `.\Run-Local` script
