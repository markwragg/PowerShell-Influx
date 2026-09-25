@{
    # Defaults for all dependencies
    PSDependOptions  = @{
        Target     = 'CurrentUser'
        Parameters = @{
            # Use a local repository for offline support
            Repository         = 'PSGallery'
            SkipPublisherCheck = $true
        }
    }

    # Common modules
    BuildHelpers     = '2.0.1'
    Pester           = '6.1.0'
    PlatyPS          = '0.12.0'
    psake            = '4.9.0'
    PSDeploy         = '1.0.1'
    PSScriptAnalyzer = '1.21.0'
}
