Get-ChildItem $PSScriptRoot/private/*.ps1 | % { . $_.FullName}
Get-ChildItem $PSScriptRoot/public/*.ps1 | % { . $_.FullName}

$defaults = [ordered]@{
  AUTO_CD         = $true
  CD_PATH         = @()
  CDABLE_VARS     = $false
  NOARG_CD        = '~'
  MenuCompletion  = $null -ne (Get-Module PSReadline)
  DirCompletions  = @('Push-Location', 'Set-Location', 'Get-ChildItem')
  PathCompletions = @()
  FileCompletions = @()
}

if ((Test-Path variable:cde) -and $cde -is [System.Collections.IDictionary]) {
  $global:cde = New-Object PSObject -Property $global:cde
}
else {
  $global:cde = New-Object PSObject -Property $defaults
}

# account for any properties missing in user supplied hash
$defaults.GetEnumerator() | % {
  if (-not (Get-Member -InputObject $global:cde -Name $_.Name)) {
    Add-Member -InputObject $cde $_.Name $_.Value
  }
}

# some set up happens in Set-Option so make sure to call it here
Set-CdExtrasOption -Option 'AUTO_CD' -Value $global:cde.AUTO_CD

$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = {
  $ExecutionContext.InvokeCommand.PostCommandLookupAction = $null
  $ExecutionContext.SessionState.InvokeCommand.CommandNotFoundAction = $null
  Remove-Variable cde -Scope Global -ErrorAction Ignore
}
