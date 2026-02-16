$tick = [char]0x2714

function Get-LocalOsLifecycleStatus {
    [CmdletBinding()]
    param()

    $serverEol = @{
        'Windows Server 2012'    = [datetime]'2023-10-10'  
        'Windows Server 2012 R2' = [datetime]'2023-10-10'  
        'Windows Server 2016'    = [datetime]'2027-01-12'
        'Windows Server 2019'    = [datetime]'2029-01-09'
        'Windows Server 2022'    = [datetime]'2031-10-14'
        'Windows Server 2025'    = [datetime]'2034-10-10'
    }


    $win10Eol = [datetime]'2025-10-14'  


    $win11HomePro = @{
        '23H2' = [datetime]'2025-11-11'
        '24H2' = [datetime]'2026-10-13'
        '25H2' = [datetime]'2027-10-12'
        '26H1' = [datetime]'2028-03-14'  
    }
   
    $win11EntEdu = @{
        '23H2' = [datetime]'2026-11-10'
        '24H2' = [datetime]'2027-10-12'
        '25H2' = [datetime]'2028-10-10'
        '26H1' = [datetime]'2029-03-13'
    }

    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    $caption  = $os.Caption            
    $version  = $os.Version            
    $build    = $os.BuildNumber
    $isServer = ($os.ProductType -ne 1)

    $now    = Get-Date
    $eol    = $null
    $status = 'Unbekannt'
    $note   = $null
    $feat   = $null

    if ($isServer) {
        $key =
            if ($caption -match '2012 R2') {'Windows Server 2012 R2'}
            elseif ($caption -match '2012') {'Windows Server 2012'}
            elseif ($caption -match '2016') {'Windows Server 2016'}
            elseif ($caption -match '2019') {'Windows Server 2019'}
            elseif ($caption -match '2022') {'Windows Server 2022'}
            else { $null }

        if ($key -and $serverEol.ContainsKey($key)) {
            $eol = $serverEol[$key]
            if ($key -like 'Windows Server 2012*') {
                $note = 'EOL; ESU until 2026-10-13.'
            }
        }
    }
    else {
        if ($caption -match 'Windows 10') {
            $eol  = $win10Eol
            $note = 'Windows 10: EOL; optional Consumer‑ESU until 2026-10-13.'
        }
        elseif ($caption -match 'Windows 11') {
            $cvKey = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
            $displayVersion = (Get-ItemProperty -Path $cvKey -Name DisplayVersion -ErrorAction SilentlyContinue).DisplayVersion
            if (-not $displayVersion) {
                $displayVersion = (Get-ItemProperty -Path $cvKey -Name ReleaseId -ErrorAction SilentlyContinue).ReleaseId
            }
            $feat = $displayVersion
            $isEntEdu = ($caption -match 'Enterprise|Education|SE')

            if ($displayVersion) {
                if ($isEntEdu -and $win11EntEdu.ContainsKey($displayVersion)) {
                    $eol = $win11EntEdu[$displayVersion]
                }
                elseif ($win11HomePro.ContainsKey($displayVersion)) {
                    $eol = $win11HomePro[$displayVersion]
                }
                $note = "Windows 11 $displayVersion" + ($(if($isEntEdu){' (Enterprise/Education)'} else {' (Home/Pro)'}))
            }
            else {
                $note = 'Windows 11 (Feature-Version unknown, DisplayVersion unknown)'
            }
        }
    }

    if ($eol) {
        $status = if ($now -gt $eol) {'EOL'} else {'In Support'}
    }

    [pscustomobject]@{
        Product     = $caption
        NtVersion   = $version
        Build       = $build
        FeatureVer  = $feat
        EolDate     = $eol
        Status      = $status
        Notes       = $note
    }
}


Write-Host "
 ██████╗ ███████╗                               
██╔═══██╗██╔════╝                               
██║   ██║███████╗                               
██║   ██║╚════██║                               
╚██████╔╝███████║                               
 ╚═════╝ ╚══════╝                               
                                                
███████╗ ██████╗ █████╗ ███╗   ██╗              
██╔════╝██╔════╝██╔══██╗████╗  ██║              
███████╗██║     ███████║██╔██╗ ██║              
╚════██║██║     ██╔══██║██║╚██╗██║              
███████║╚██████╗██║  ██║██║ ╚████║              
╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═══╝              
                                                
██╗  ██╗███████╗██╗     ██████╗ ███████╗██████╗ 
██║  ██║██╔════╝██║     ██╔══██╗██╔════╝██╔══██╗
███████║█████╗  ██║     ██████╔╝█████╗  ██████╔╝
██╔══██║██╔══╝  ██║     ██╔═══╝ ██╔══╝  ██╔══██╗
██║  ██║███████╗███████╗██║     ███████╗██║  ██║
╚═╝  ╚═╝╚══════╝╚══════╝╚═╝     ╚══════╝╚═╝  ╚═╝
"

# Create directory and output file

$OutputFilePath = "C:\OSScanHelperFiles\OSScanOutput.txt"

if(-not(Test-Path -Path "C:\OSScanHelperFiles")){
    try{
        New-Item -Path "C:\" -Name OSScanHelperFiles -ItemType Directory -Force *>$null
        Write-Host "Created directory 'C:\OSScanHelperFiles'. $tick" -ForegroundColor Green
    } catch {
        Write-Host "Failed to create directory 'C:\OSScanHelperFiles'. $_" -ForegroundColor Red
    }
    
} else {
    Write-Host "Directory 'C:\OSScanHelperFiles' exists." -ForegroundColor Cyan
}

if(-not(Test-Path -Path "C:\OSScanHelperFiles\OSScanOutput.txt" -PathType Leaf)){
    try{
        New-Item -Path "C:\OSScanHelperFiles" -Name "OSScanOutput.txt" -ItemType File -Force *>$null 
        Write-Host "Created file 'C:\OSScanHelperFiles\OSScanOutput.txt'. $tick" -ForegroundColor Green
    } catch {
        Write-Host "Failed to create file 'C:\OSScanHelperFiles\OSScanOutput.txt'. $_" -ForegroundColor Red
    }
} else {
    Write-Host "File 'C:\OSScanHelperFiles\OSScanOutput.txt' exists." -ForegroundColor Cyan
}

# Collect data

try{
    $StorageInfo = Get-Volume
    $OSInfo = Get-LocalOsLifecycleStatus
    $Hostname = hostname
    $ExecutionTimeAndDate = Get-Date
} catch {
    Write-Host "Could not gather one or more information. $_" -ForegroundColor Red
}

# Print data to output file

try{
    Add-Content -Path $OutputFilePath -Value "####################################################################"
    Add-Content -Path $OutputFilePath -Value "# ===== Results from script execution on $ExecutionTimeAndDate ===== #"
    Add-Content -Path $OutputFilePath -Value "####################################################################"
} catch {

}

try{
    Add-Content -Path $OutputFilePath -Value "`n========== Hostname =========="
    $Hostname | Out-File -FilePath $OutputFilePath -Append -Encoding utf8
    Write-Host "`nHostname check completed. $tick `n"
} catch {
    Write-Host "Hostname check failed. $_" -ForegroundColor Yellow
}

try{
    Add-Content -Path $OutputFilePath -Value "`n========== Storage information =========="
    $StorageInfo | Out-File -FilePath $OutputFilePath -Append -Encoding utf8
    Write-Host "Storage check completed. $tick `n"
} catch {
    Write-Host "Storage check failed. $_" -ForegroundColor Yellow
}

try{
    Add-Content -Path $OutputFilePath -Value "`n========== OS information =========="
    $OSInfo | Out-File -FilePath $OutputFilePath -Append -Encoding utf8
    Write-Host "OS check completed. $tick `n"
} catch {
    Write-Host "OS check failed. $_" -ForegroundColor Yellow
}

# completion

if(Test-Path -Path $OutputFilePath -PathType Leaf){
    Write-Host "========== The script has finished. ========== " -ForegroundColor Green
    Write-Host "Please check 'C:\OSScanHelperFiles\OSScanOutput.txt' for results." -ForegroundColor Green
    Read-Host "Press enter to exit"
} else {
    Write-Host "========== The script has finished. ========== " -ForegroundColor Yellow
    Write-Host "Output file at 'C:\OSScanHelperFiles\OSScanOutput.txt' does not exist. Check permissions and re-run the script." -ForegroundColor Yellow
    Read-Host "Press enter to exit"
}
