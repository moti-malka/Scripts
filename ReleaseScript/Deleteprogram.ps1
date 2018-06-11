$app = Get-WmiObject -Class Win32_Product | Where-Object { 
    $_.Name -match "ContactSync"
}

$app.Uninstall()