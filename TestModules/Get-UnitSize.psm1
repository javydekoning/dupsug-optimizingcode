Function Get-UnitSize {
  Param
  (
    [Parameter(Mandatory)]
    $literalpath
  )

  if (Test-Path $literalpath) {
    #Read file (-raw returns a single string rather than an array of lines)
    $content  = Get-Content $literalpath -Raw
    
    #Extract functions using multiline regex:
    $functions = $content | Select-String '(?smi)function.*?^}' -AllMatches | ForEach-Object {$_.Matches.value} 
    
    $functions | ForEach-Object {
      [pscustomobject]@{
        #Extract Function Name
        Name = $_ | Select-String -Pattern 'function\s([a-zA-Z\-0-9:]+)' | ForEach-Object{ $_.matches.groups[1].value}; 
        
        #Count lines that are not blank
        Size = ( $_ -split '\n' | Where-Object {(-not([string]::IsNullOrWhiteSpace($_)))} ).count
      }
    }
  }
}