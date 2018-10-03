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
    #Get any instances of the old printer and delete them
    Get-Printer | Where-Object { $_.PortName -Like "*$($OldPrinterIP)*" } | Remove-Printer

    #Get any instances of the old printer port and delete them
    Get-PrinterPort | Where-Object { $_.Name -Like "*$($OldPrinterIP)*" } | Remove-PrinterPort
}

#Use pnputil to install the printer driver into the Windows Driver store
Invoke-Command { pnputil.exe /a $InfPath }

#Install the printer driver onto the computer
Add-PrinterDriver -Name $DriverName

#Add a printer port for the new IP
Add-PrinterPort -Name "IP_$($PrinterIP)" -PrinterHostAddress $PrinterIP

#Add the new Melbourne Tenancy 2 printer use the specified driver and IP
Add-Printer -Name $PrinterName -DriverName $DriverName -PortName "IP_$($PrinterIP)"

# Get printer
$Printer = Get-Printer | Where-Object { $_.PortName -Like "*$($PrinterIP)*" -Or $_.Name -Like "$($PrinterName)" }

# Configure settings on printer
$Printer | Configure-Printer $_ $PrinterName