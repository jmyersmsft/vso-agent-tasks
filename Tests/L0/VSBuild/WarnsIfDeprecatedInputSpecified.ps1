[CmdletBinding()]
param()

# Arrange.
. $PSScriptRoot\..\..\lib\Initialize-Test.ps1
$variableSets = @(
    @{ VSLocation = 'Some VS location' ; ExpectedWarning = '*VS*location*deprecated*' }
    @{ MSBuildLocation = 'Some MSBuild location' ; ExpectedWarning = '*MSBuild*location*deprecated*' }
    @{ MSBuildVersion = 'Some MSBuild version' ; ExpectedWarning = '*MSBuild*version*deprecated*' }
)
foreach ($variableSet in $variableSets) {
    Unregister-Mock Get-VstsInput
    Register-Mock Get-VstsInput { $false } -ArgumentsEvaluator { $args -contains '-AsBool' }
    Register-Mock Get-VstsInput { $variableSet.VSLocation } -- -Name VSLocation
    Register-Mock Get-VstsInput { $variableSet.MSBuildLocation } -- -Name MSBuildLocation
    Register-Mock Get-VstsInput { $variableSet.MSBuildVersion } -- -Name MSBuildVersion
}
Register-Mock Get-SolutionFiles
Register-Mock Select-VSVersion
Register-Mock Select-MSBuildLocation
Register-Mock Format-MSBuildArguments
Register-Mock Invoke-BuildTools { 'Some build output' }
Register-Mock Write-Warning

# Act.
$output = & $PSScriptRoot\..\..\..\Tasks\VSBuild\VSBuild_PS3.ps1

# Assert.
Assert-AreEqual 'Some build output' $output
Assert-WasCalled Write-Warning -Times 1 # Exactly once.
Assert-WasCalled Write-Warning -ArgumentsEvaluator { $args.Count -eq 1 -and $args[0] -like $variableSet.ExpectedWarning }
