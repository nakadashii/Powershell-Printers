[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true)]
    $PrinterName,
    [Parameter(Mandatory=$true)]
    $InfPath,
    [Parameter(Mandatory=$true)]
    $DriverName,
    [Parameter(Mandatory=$true)]
    $PrinterIP,
    [Parameter(Mandatory=$false)]
    $OldPrinterIP
)

function Configure-Printer($Printer, [String]$Name) {
    if(-Not($null -eq $Printer)) {
        $PrinterConfiguration = Get-PrintConfiguration -PrinterName $Printer.Name
        if($PrinterConfiguration.Color -NotLike $false) {
            Set-PrintConfiguration -PrinterName $Printer.Name -Color $false
        }
        if($PrinterConfiguration.DuplexingMode -NotLike "TwoSidedLongEdge") {
            Set-PrintConfiguration -PrinterName $Printer.Name -DuplexingMode TwoSidedLongEdge
        }
        if($Printer.Name -NotLike $Name) {
            Rename-Printer -InputObject $Printer -NewName $Name
        }
    }
}

if($OldPrinterIP) {
    Get-Printer | Where-Object { $_.PortName -Like "*$($OldPrinterIP)*" } | Remove-Printer

    Get-PrinterPort | Where-Object { $_.Name -Like "*$($OldPrinterIP)*" } | Remove-PrinterPort
}

Invoke-Command { pnputil.exe /a $InfPath }

Add-PrinterDriver -Name $DriverName

Add-PrinterPort -Name "IP_$($PrinterIP)" -PrinterHostAddress $PrinterIP

Add-Printer -Name $PrinterName -DriverName $DriverName -PortName "IP_$($PrinterIP)"

$Printer | Configure-Printer $_ $PrinterName