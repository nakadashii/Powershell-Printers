$PrinterName = ""
$InfPath = ""
$DriverName = ""
$PrinterIP = ""
$OldPrinterIP = ""

if($OldPrinterIP) {
    Get-Printer | Where-Object { $_.PortName -Like "*$($OldPrinterIP)*" } | Remove-Printer

    Get-PrinterPort | Where-Object { $_.Name -Like "*$($OldPrinterIP)*" } | Remove-PrinterPort
}

Invoke-Command { pnputil.exe /a $InfPath }

Add-PrinterDriver -Name $DriverName

Add-PrinterPort -Name "IP_$($PrinterIP)" -PrinterHostAddress $PrinterIP

Add-Printer -Name $PrinterName -DriverName $DriverName -PortName "IP_$($PrinterIP)"