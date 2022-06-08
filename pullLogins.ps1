param(
    [string]$Email,
    [string]$RG="OHDeployRG"
)

Begin {
}

Process {
    $Containers = Get-AzContainerGroup -ResourceGroupName $RG
    $Results = @()
    ForEach ($Container in $Containers) {
        $Log = Get-AzContainerInstanceLog -ResourceGroupName $RG -ContainerName $Container.Name -ContainerGroupName $Container.Name -Tail 5
        If ($Log -match "tab\.(?<entries>.+)") {
            $Results += "Details for Challenge:"
            $Results += $Matches.entries -split "\</br\>"
        } else {
            Write-Error "Could not find login details, please reach out to support for assistance."
        }
    }
    $Results | ?{ $_.trim() -ne "" } | Write-Output
    If ($Email) {
        Send-MailMessage -To $Email -Subject "Login details for challenge" -Body ($Results -join "`n")
    }
}