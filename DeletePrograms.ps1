Param(
  [Parameter(Mandatory=$True,Position=1)]
  [string]$ProgramName
)


$app = Get-WmiObject -Class Win32_Product | Where-Object { 
    $_.Name -match $ProgramName 
}

$app.Uninstall()