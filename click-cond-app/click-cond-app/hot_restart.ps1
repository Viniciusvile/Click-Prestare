$wshell = New-Object -ComObject WScript.Shell;
$processes = Get-Process | Where-Object { $_.MainWindowTitle -like "*Flutter*" -or $_.MainWindowTitle -like "*click-cond-app*" };
if ($processes) {
    foreach ($p in $processes) {
        Write-Host "Ativando janela: $($p.MainWindowTitle)"
        $wshell.AppActivate($p.Id);
        Start-Sleep -Seconds 1;
        $wshell.SendKeys('+R');
        Write-Host "Shift+R enviado."
    }
} else {
    Write-Host "Nenhum terminal Flutter ou VS Code encontrado com título esperado."
}
