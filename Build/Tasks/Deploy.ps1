Task 'Deploy' -Depends 'Init' {
    $lines

    # Load the module, read the exported functions, update the psd1 FunctionsToExport
    Set-ModuleFunctions -Name $env:BHPSModuleManifest

    if (Test-Path $StagingModuleManifestPath) {
        Set-ModuleFunctions -Name $StagingModuleManifestPath

        $env:BHStagingModulePath = $StagingModulePath
    }
    else {
        Write-Warning "Staging module not found at [$StagingModulePath] -- run the CombineFunctionsAndStage task first. Falling back to publishing directly from source."
    }

    $ChangeLogPath = "$ProjectRoot/CHANGELOG.md"
    $ChangeLog = if (Test-Path $ChangeLogPath) { Get-Content $ChangeLogPath }

    if (-not ($ChangeLog -contains '## !Deploy')) {
        if ($ChangeLog) {
            Write-Host 'CHANGELOG.md did not contain ## !Deploy. Skipping deployment.'
        }
        else {
            Write-Host "$ChangeLogPath not found. Skipping deployment."
        }
        return
    }

    # Bump the module version
    try {
        $Version = Get-NextPSGalleryVersion -Name $env:BHProjectName -ErrorAction 'Stop'

        # Ensure the next deploy is at least 1.1.0. Once the Gallery has a 1.1.0+ release published, Get-NextPSGalleryVersion will always be >= this floor
        # on its own, so this check becomes a no-op and doesn't need to be removed later.
        $MinimumVersion = [Version]'1.1.0'
        if ($Version -lt $MinimumVersion) { $Version = $MinimumVersion }

        # A [Breaking] entry in the unreleased ('!Deploy') CHANGELOG section marks this as a breaking release,
        # so bump the major version instead of the usual patch bump Get-NextPSGalleryVersion applies.
        $ChangeLogContent = Get-Content $ChangeLogPath -Raw

        if ($ChangeLogContent -match '(?s)## !Deploy(.*?)(\n## |\z)' -and $Matches[1] -match '\[Breaking\]') {
            $Version = [Version]::new($Version.Major + 1, 0, 0)
            Write-Host "CHANGELOG contains a [Breaking] entry - bumping the major version to $Version instead" -ForegroundColor 'Yellow'
        }

        Update-Metadata -Path $env:BHPSModuleManifest -PropertyName 'ModuleVersion' -Value $Version -ErrorAction 'Stop'
    }
    catch {
        throw "Failed to update version for '$env:BHProjectName': $_.`n"
    }

    # deploy.psdeploy.ps1 publishes the combined module built by CombineFunctionsAndStage, not the source --
    # its manifest was copied from source before this task bumped the version above, so it needs the same
    # updates applied to it directly too.
    if (Test-Path $StagingModuleManifestPath) {
        Update-Metadata -Path $StagingModuleManifestPath -PropertyName 'ModuleVersion' -Value $Version -ErrorAction 'Stop'
    }

    $Params = @{
        Path    = "$ProjectRoot/Build/deploy.psdeploy.ps1"
        Force   = $true
        Recurse = $false
    }

    Invoke-PSDeploy @Verbose @Params

    # Update ChangeLog with deployment version and date
    $ChangeLog = $ChangeLog -replace '## !Deploy', "## [$Version] - $(Get-Date -Format 'yyyy-MM-dd')"
    Set-Content -Path $ChangeLogPath -Value $ChangeLog

    # Signal to the pipeline that a real deploy happened, so the GitHubRelease step (which runs as a later,
    # separate step in the same job) knows to run. Only set when actually running in GitHub Actions.
    if ($env:GITHUB_OUTPUT) {
        "DidDeploy=true" | Out-File -FilePath $env:GITHUB_OUTPUT -Append
    }
}
