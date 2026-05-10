Get-Process | Where-Object { $_.MainWindowTitle } | Select-Object Id, MainWindowTitle, ProcessName | Format-Table -AutoSize
