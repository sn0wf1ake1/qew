<#
Name: qew (Qiuck Event VieW)
Version 0.1

Quick and dirty command line script to generate an overview of Windows Event Log errors and warnings.
This is not intended to maintain any status or logs, but just as a simple command to give an overview.

Usage:
qew [default last day]
qew 2 [shows past two days]
qew s [last day summary]

References:
https://docs.microsoft.com/en-us/powershell/module/Microsoft.PowerShell.Management/Get-EventLog?view=powershell-5.1
https://www.nextofwindows.com/10-examples-to-check-event-log-on-local-and-remote-computer-using-powershell

# Basic example.
$Events = Get-EventLog -LogName System -Newest 1000
$Events | Group-Object -Property Source -NoElement | Sort-Object -Property Count -Descending

# Latest with sorting.
Get-EventLog -LogName System -Newest 1000 | Where-Object {$_.EntryType -like 'Error' -or $_.EntryType -like 'Warning'} | Sort-Object Source

# List of events.
Get-EventLog -LogName System -Newest 1000 | Where-Object {$_.EntryType -like 'Error' -or $_.EntryType -like 'Warning' -and $_.Index -lt "{0:yyyyMMdd}" -f (get-date).AddDays(-1)} | Sort-Object Source
#>

Param([Parameter(Mandatory=$False)] $qew_view)

if($qew_view -and $qew_view.GetType().IsValueType -eq $true) {
    $qew_date = [DateTime]::Today.AddDays(-1*$qew_view)
    } else {
    $qew_date = [DateTime]::Today.AddDays(-1)
}

if($qew_view -like 's') {
    # Summary of the number of errors.
    $Events = Get-EventLog -LogName System -After $qew_date | Where-Object {$_.EntryType -like 'Error' -or $_.EntryType -like 'Warning'} | Sort-Object Source
    $Events | Group-Object -Property Source -NoElement | Sort-Object -Property Count -Descending | Format-Table -Wrap -AutoSize
    } else {
    # List of events.
    Get-EventLog -LogName System -After $qew_date | Where-Object {$_.EntryType -like 'Error' -or $_.EntryType -like 'Warning'} | Sort-Object Source
}