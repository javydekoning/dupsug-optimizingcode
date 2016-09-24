function Get-CommentCoverage {
  Param
  (
    [Parameter(Mandatory)]
    $literalpath
  )

  if (Test-Path $literalpath) {
    #Read file (-raw returns a single string rather than an array of lines)
    $script   = Get-Content -LiteralPath $literalpath -raw
    
    #Remove Multi-line comments / descriptive help from the count 
    $script   = $script -replace '\<#[\S\s]*?#\>'

    #Split to array, and remove any blank lines
    $script   = $script -split '\n' | Where-Object {
      (-not([string]::IsNullOrWhiteSpace($_)))
    }
    
    #Calculate 'comment ratio'
    $comments = $script | Where-Object {$_ -match '^\s*#'}
    return [double]$($comments.count / $script.count * 100)
  }  
}