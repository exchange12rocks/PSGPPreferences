# PSGPPreferences - AI Coding Agent Instructions

## Project Overview
PSGPPreferences is a PowerShell module that enables Windows system administrators to manage Active Directory Group Policy Preferences programmatically by working directly with GP preference XML files stored in AD. The module uses .NET DirectoryServices classes for AD access rather than the ActiveDirectory module.

## Architecture & Directory Structure

### Source Organization (`./src`)
- Functions organized by feature/domain area (e.g., `./src/Common/`, `./src/Filters/`)
- No explicit public/private filesystem separation; all functions potentially public
- Related functionality grouped together logically

### Tests (`./Tests`)
- Pester test files mirror source structure
- Named `*.Tests.ps1` convention
- Run locally before commits; not part of automated CI/CD

## Critical Developer Workflows

### Testing
```powershell
Invoke-Pester -Path "./Tests" -Verbose
```
- Run full test suite before commits
- Tests validate expected behavior
- Update tests alongside implementation

### Module Development
- Follow **Verb-Noun naming**: `Get-GPPreference`, `Set-GPPreference`, etc.
- Use parameter validation: `[ValidateNotNullOrEmpty()]`, `[ValidateSet()]`
- Document with comment-based help

## Code Patterns & Conventions

### PowerShell Best Practices
- Use `param()` blocks with type hints
- Use `Write-Verbose` for diagnostics
- Use `$PSCmdlet.ThrowTerminatingError()` for errors in functions with `[CmdletBinding()]`
- Avoid pipeline chaining; functions are called directly with explicit parameters

### AD Integration (No ActiveDirectory Module)
- Use **System.DirectoryServices.DirectoryEntry** for LDAP connections
- Example: See `Convert-GPONameToID.ps1` for domain DN retrieval and GPO lookup
- Pattern: Connect to RootDSE → get domain DN → search Policies container
- Access AD properties via `.Properties.<PropertyName>[0]` (ResultPropertyValueCollection indexing)
- GP Preferences stored as XML in AD; extract and parse XML directly from AD objects

### GP Preference XML Files
- Preferences stored as XML in AD groupPolicyContainer objects
- Functions parse/modify XML programmatically (System.Xml classes)
- Handle XML namespaces carefully (typical GP XML has default/custom namespaces)

### Current Branch: `filters-string`
- Feature work on string-based filtering for GP preferences
- Review existing filter functions in `./src` before modifications
- Maintain backward compatibility with current filter patterns

## Before Modifying Code
1. Check `./src` for similar patterns (especially AD queries and XML handling)
2. Run `Invoke-Pester -Path "./Tests"` to ensure no regressions
3. Add/update Pester tests in `./Tests` for new functionality
4. Run PSScriptAnalyzer locally: `Invoke-ScriptAnalyzer -Path "./src" -Recurse`
5. Update module manifest (`.psd1`) if adding public functions

## Key Integration Points
- System.DirectoryServices namespace for AD LDAP queries
- System.Xml namespace for GP preference XML parsing/modification
- Windows administrative context (requires elevated privileges, domain-joined)