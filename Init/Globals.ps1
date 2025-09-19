
# Global variables

# Global cache of ApiCredentials.
#   Dictionary of project Collections
#       of Projects
#           of ApiCredentials
[hashtable] $global:ApiCredentialsCache = @{ }

# Global cache of ApiCollections.
[hashtable] $global:ApiCollectionsCache = @{ }

# Global cache of Projects. Used to resolve Uris.
[hashtable] $global:ApiProjectsCache = @{ }

# Global retry configuration
[hashtable] $global:AzureDevOpsApi_RetryConfig = @{
    RetryCount = 3
    RetryDelay = 1.0
    DisableRetry = $false
    MaxRetryDelay = 30.0
    UseExponentialBackoff = $true
    UseJitter = $true
}

# Global cache for WorkItemRelationDescriptors
[Array] $script:WorkItemRelationDescriptorsCache = $null
