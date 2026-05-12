param(
	[string]$Suite = "fast",
	[string[]]$Tests = @(),
	[string[]]$ChangedFiles = @(),
	[string]$Godot = "godot",
	[switch]$List,
	[switch]$KeepGoing
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

function New-TestSpec {
	param(
		[string]$Path,
		[string]$Slice = ""
	)
	[pscustomobject]@{
		Path = ($Path -replace "\\", "/")
		Slice = $Slice
	}
}

function Add-UniqueSpec {
	param(
		[System.Collections.ArrayList]$Specs,
		[psobject]$Spec
	)
	$key = "$($Spec.Path)|$($Spec.Slice)"
	foreach ($existing in $Specs) {
		if ("$($existing.Path)|$($existing.Slice)" -eq $key) {
			return
		}
	}
	[void]$Specs.Add($Spec)
}

function Get-AllTestSpecs {
	Get-ChildItem -Path (Join-Path $Root "tests") -Filter "test_*.gd" |
		Sort-Object Name |
		ForEach-Object { New-TestSpec "tests/$($_.Name)" }
}

function Get-FastSpecs {
	$heavy = @(
		"tests/test_character_creator2d_recipe.gd",
		"tests/test_character_creator2d_visual_regression.gd"
	)
	Get-AllTestSpecs | Where-Object { $heavy -notcontains $_.Path }
}

function Get-CreatorFastSpecs {
	@(
		$(New-TestSpec "tests/test_character_creation.gd"),
		$(New-TestSpec "tests/test_character_creator2d_import.gd"),
		$(New-TestSpec "tests/test_character_creator2d_recipe.gd" "recipe"),
		$(New-TestSpec "tests/test_character_creator2d_recipe.gd" "manager"),
		$(New-TestSpec "tests/test_character_creator2d_recipe.gd" "metadata")
	)
}

function Get-CreatorHeavySpecs {
	@(
		$(New-TestSpec "tests/test_character_creator2d_recipe.gd" "bake"),
		$(New-TestSpec "tests/test_character_creator2d_recipe.gd" "studio"),
		$(New-TestSpec "tests/test_character_creator2d_visual_regression.gd")
	)
}

function Resolve-ChangedSpecs {
	param([string[]]$Files)
	$specs = [System.Collections.ArrayList]::new()
	foreach ($file in $Files) {
		$normalized = ($file -replace "\\", "/").ToLowerInvariant()
		switch -Regex ($normalized) {
			"(^|/)scripts/ui/character_select\.gd$|(^|/)scenes/ui/characterselect\.tscn$" {
				Add-UniqueSpec $specs (New-TestSpec "tests/test_character_creation.gd")
				continue
			}
			"(^|/)scripts/ui/main\.gd$" {
				Add-UniqueSpec $specs (New-TestSpec "tests/test_main_title_menu.gd")
				continue
			}
			"(^|/)scripts/character_creator/|(^|/)resources/character_creator_2d/|(^|/)tools/cc2d_export_cli\.gd$" {
				Add-UniqueSpec $specs (New-TestSpec "tests/test_character_creator2d_import.gd")
				Add-UniqueSpec $specs (New-TestSpec "tests/test_character_creator2d_recipe.gd" "recipe")
				Add-UniqueSpec $specs (New-TestSpec "tests/test_character_creator2d_recipe.gd" "manager")
				if ($normalized -match "bake|export|preview|studio|animation|sprite|visual") {
					Add-UniqueSpec $specs (New-TestSpec "tests/test_character_creator2d_recipe.gd" "bake")
					Add-UniqueSpec $specs (New-TestSpec "tests/test_character_creator2d_recipe.gd" "studio")
				}
				continue
			}
			"(^|/)scripts/core/save_manager\.gd$|(^|/)scripts/core/game_state\.gd$" {
				Add-UniqueSpec $specs (New-TestSpec "tests/test_save_manager.gd")
				Add-UniqueSpec $specs (New-TestSpec "tests/test_character_creation.gd")
				continue
			}
			"(^|/)scripts/core/party_manager\.gd$|(^|/)scripts/world/party_shrine\.gd$" {
				Add-UniqueSpec $specs (New-TestSpec "tests/test_sakuramori_services.gd")
				Add-UniqueSpec $specs (New-TestSpec "tests/test_shadow_recruitment.gd")
				Add-UniqueSpec $specs (New-TestSpec "tests/test_witch_recruitment.gd")
				continue
			}
			"(^|/)scripts/player/" {
				Add-UniqueSpec $specs (New-TestSpec "tests/test_player_movement.gd")
				Add-UniqueSpec $specs (New-TestSpec "tests/test_player_combat.gd")
				Add-UniqueSpec $specs (New-TestSpec "tests/test_player_respawn.gd")
				continue
			}
			"(^|/)scripts/enemies/" {
				Add-UniqueSpec $specs (New-TestSpec "tests/test_enemy_behavior.gd")
				Add-UniqueSpec $specs (New-TestSpec "tests/test_enemy_contact_damage.gd")
				continue
			}
		}
	}
	if ($specs.Count -eq 0) {
		foreach ($spec in Get-FastSpecs) {
			Add-UniqueSpec $specs $spec
		}
	}
	$specs
}

function Resolve-SuiteSpecs {
	if ($Tests.Count -gt 0) {
		return $Tests | ForEach-Object { New-TestSpec $_ }
	}

	switch ($Suite.ToLowerInvariant()) {
		"fast" { return Get-FastSpecs }
		"creator-fast" { return Get-CreatorFastSpecs }
		"creator-heavy" { return Get-CreatorHeavySpecs }
		"creator" { return (Get-CreatorFastSpecs) + (Get-CreatorHeavySpecs) }
		"creator-recipe" { return @(New-TestSpec "tests/test_character_creator2d_recipe.gd" "recipe") }
		"creator-manager" { return @(New-TestSpec "tests/test_character_creator2d_recipe.gd" "manager") }
		"creator-bake" { return @(New-TestSpec "tests/test_character_creator2d_recipe.gd" "bake") }
		"creator-studio" { return @(New-TestSpec "tests/test_character_creator2d_recipe.gd" "studio") }
		"creator-metadata" { return @(New-TestSpec "tests/test_character_creator2d_recipe.gd" "metadata") }
		"full" { return Get-AllTestSpecs }
		"changed" { return Resolve-ChangedSpecs $ChangedFiles }
		default { throw "Unknown test suite '$Suite'." }
	}
}

function Format-SpecName {
	param([psobject]$Spec)
	if ([string]::IsNullOrWhiteSpace($Spec.Slice)) {
		return $Spec.Path
	}
	"$($Spec.Path)[$($Spec.Slice)]"
}

function Quote-CmdArg {
	param([string]$Value)
	'"' + ($Value -replace '"', '""') + '"'
}

$selectedSpecs = @(Resolve-SuiteSpecs)
if ($selectedSpecs.Count -eq 0) {
	throw "No tests selected for suite '$Suite'."
}

if ($List) {
	foreach ($spec in $selectedSpecs) {
		Write-Output (Format-SpecName $spec)
	}
	exit 0
}

$failures = [System.Collections.ArrayList]::new()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

foreach ($spec in $selectedSpecs) {
	$name = Format-SpecName $spec
	Write-Output "==> $name"
	$testTimer = [System.Diagnostics.Stopwatch]::StartNew()
	$previousSlice = [Environment]::GetEnvironmentVariable("CC2D_RECIPE_TEST_SLICE", "Process")
	try {
		if ([string]::IsNullOrWhiteSpace($spec.Slice)) {
			Remove-Item Env:\CC2D_RECIPE_TEST_SLICE -ErrorAction SilentlyContinue
		} else {
			$env:CC2D_RECIPE_TEST_SLICE = $spec.Slice
		}
		$commandLine = (Quote-CmdArg $Godot) + " --headless --path . --script " + (Quote-CmdArg $spec.Path)
		$testOutput = & cmd /d /c $commandLine 2>&1
		foreach ($line in $testOutput) {
			Write-Output $line
		}
		$lastExitCodeVariable = Get-Variable LASTEXITCODE -ErrorAction SilentlyContinue
		if ($null -eq $lastExitCodeVariable) {
			$exitCode = 0
		} else {
			$exitCode = $lastExitCodeVariable.Value
		}
		if ($exitCode -eq 0) {
			foreach ($line in $testOutput) {
				if ([string]$line -match "SCRIPT ERROR|Parse Error|Compile Error|Failed to load script|ERROR: Failed") {
					$exitCode = 1
					break
				}
			}
		}
	} finally {
		if ($null -eq $previousSlice) {
			Remove-Item Env:\CC2D_RECIPE_TEST_SLICE -ErrorAction SilentlyContinue
		} else {
			$env:CC2D_RECIPE_TEST_SLICE = $previousSlice
		}
	}
	$testTimer.Stop()
	if ($exitCode -eq 0) {
		Write-Output ("PASS {0} ({1:n1}s)" -f $name, $testTimer.Elapsed.TotalSeconds)
	} else {
		Write-Output ("FAIL {0} ({1:n1}s, exit {2})" -f $name, $testTimer.Elapsed.TotalSeconds, $exitCode)
		[void]$failures.Add($name)
		if (-not $KeepGoing) {
			break
		}
	}
}

$stopwatch.Stop()

if ($failures.Count -gt 0) {
	Write-Output ("FAILED {0}/{1} tests in {2:n1}s" -f $failures.Count, $selectedSpecs.Count, $stopwatch.Elapsed.TotalSeconds)
	exit 1
}

Write-Output ("PASSED {0} tests in {1:n1}s" -f $selectedSpecs.Count, $stopwatch.Elapsed.TotalSeconds)
exit 0
