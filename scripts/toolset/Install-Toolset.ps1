#!/usr/bin/env pwsh

function Invoke-DownloadWithRetry {
    <#
    .SYNOPSIS
        Downloads a file from a given URL with retry functionality.

    .DESCRIPTION
        The Invoke-DownloadWithRetry function downloads a file from the specified URL
        to the specified path. It includes retry functionality in case the download fails.

    .PARAMETER Url
        The URL of the file to download.

    .PARAMETER Path
        The path where the downloaded file will be saved. If not provided, a temporary path
        will be used.

    .EXAMPLE
        Invoke-DownloadWithRetry -Url "https://example.com/file.zip" -Path "/usr/local/bin"
        Downloads the file from the specified URL and saves it to the specified path.

    .EXAMPLE
        Invoke-DownloadWithRetry -Url "https://example.com/file.zip"
        Downloads the file from the specified URL and saves it to a temporary path.

    .OUTPUTS
        The path where the downloaded file is saved.
    #>
    param(
        [Parameter(Mandatory)]
        [string] $Url,
        [Alias("Destination")]
        [string] $DestinationPath
    )

    if (-not $DestinationPath) {
        $invalidChars = [IO.Path]::GetInvalidFileNameChars() -join ''
        $re = "[{0}]" -f [RegEx]::Escape($invalidChars)
        $fileName = [IO.Path]::GetFileName($Url) -replace $re

        if ( [String]::IsNullOrEmpty($fileName)) {
            $fileName = [System.IO.Path]::GetRandomFileName()
        }
        $DestinationPath = Join-Path -Path "/tmp" -ChildPath $fileName
    }

    Write-Host "Downloading package from $Url to $DestinationPath..."

    $interval = 30
    $downloadStartTime = Get-Date
    for ($retries = 20; $retries -gt 0; $retries--) {
        try {
            $attemptStartTime = Get-Date
            Invoke-WebRequest -Uri $Url -Outfile $DestinationPath
            $attemptSeconds = [math]::Round(($( Get-Date ) - $attemptStartTime).TotalSeconds, 2)
            Write-Host "Package downloaded in $attemptSeconds seconds"
            break
        }
        catch {
            $attemptSeconds = [math]::Round(($( Get-Date ) - $attemptStartTime).TotalSeconds, 2)
            Write-Warning "Package download failed in $attemptSeconds seconds"
            Write-Warning $_.Exception.Message
        }

        if ($retries -eq 0) {
            $totalSeconds = [math]::Round(($( Get-Date ) - $downloadStartTime).TotalSeconds, 2)
            throw "Package download failed after $totalSeconds seconds"
        }

        Write-Warning "Waiting $interval seconds before retrying (retries left: $retries)..."
        Start-Sleep -Seconds $interval
    }

    return $DestinationPath
}

function Install-Asset {
    param(
        [Parameter(Mandatory = $true)]
        [object] $ReleaseAsset
    )

    Write-Host "Download $( $ReleaseAsset.filename )"
    $assetArchivePath = Invoke-DownloadWithRetry $ReleaseAsset.download_url

    Write-Host "Extract $( $ReleaseAsset.filename ) content..."
    $assetFolderPath = Join-Path "/tmp" "$( $ReleaseAsset.filename )-temp-dir"
    New-Item -ItemType Directory -Path $assetFolderPath | Out-Null
    tar -xzf $assetArchivePath -C $assetFolderPath

    Write-Host "Invoke installation script..."
    Push-Location -Path $assetFolderPath
    Invoke-Expression "bash ./setup.sh"
    Pop-Location
}

$ErrorActionPreference = "Stop"

# Get toolcache content from toolset
$toolsetJson = Get-Content -Path "$env:TOOLSET_CONF" -Raw
$tools = ConvertFrom-Json -InputObject $toolsetJson | Where-Object { $_.url -ne $null }

foreach ($tool in $tools) {
    # Get versions manifest for current tool
    $assets = Invoke-RestMethod $tool.url

    # Get github release asset for each version
    foreach ($toolVersion in $tool.versions) {
        $asset = $assets | Where-Object version -like $toolVersion `
            | Select-Object -ExpandProperty files `
            | Where-Object { ($_.platform -eq $tool.platform) -and ($_.arch -eq $tool.arch) -and ($_.platform_version -eq $tool.platform_version) } `
            | Select-Object -First 1

        if (-not $asset) {
            Write-Host "Asset for $( $tool.name ) $toolVersion $( $tool.arch ) not found in versions manifest"
            exit 1
        }

        Write-Host "Installing $( $tool.name ) $toolVersion $( $tool.arch )..."
        Install-Asset -ReleaseAsset $asset
    }

    chown -R "777" "$env:AGENT_TOOLSDIRECTORY/$( $tool.name )"
}