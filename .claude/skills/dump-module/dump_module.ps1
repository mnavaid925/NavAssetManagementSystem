## dump_module.ps1
##
## Generates a consolidated <NN>_<slug>.txt file in temp/ containing all backend
## (apps/<name>/) and frontend (templates/<name>/) code for one NavAssetManagementSystem module.
##
## NavAssetManagementSystem is a multi-tenant Asset Management System (Django 5.1 + Tailwind/HTMX/Chart.js/Lucide,
## MySQL/MariaDB via PyMySQL, DB nav_ams). Module 0 (apps/tenants) is the flagship COMPLETE module; the
## foundation apps accounts/core/dashboard are also built. Modules 1-20 are roadmap
## placeholders built on demand by the /next-module skill — until then the script prints
## "(no backend folder found ...)" for them, which is expected.
##
## Usage:
##   pwsh .claude\skills\dump-module\dump_module.ps1 -Module tenants
##   pwsh .claude\skills\dump-module\dump_module.ps1 -Module 0
##   pwsh .claude\skills\dump-module\dump_module.ps1 -Module "procurement"
##   pwsh .claude\skills\dump-module\dump_module.ps1 -Module all      # regenerates every module

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Module,

    [string]$RepoRoot = 'C:\xampp\htdocs\NavAssetManagementSystem'
)

$ErrorActionPreference = 'Stop'

# -------- Module registry --------
# key = output file slug; value = @(<apps_folder>, <templates_folder>, <human title>)
# Built today: tenants (Module 0) + the foundation apps accounts/core/dashboard.
# Modules 1-20 are FORWARD-COMPATIBLE entries matching the /next-module roadmap app slugs;
# their apps/<slug> + templates/<slug> folders do not exist until /next-module builds them.
$registry = [ordered]@{
    # --- Module 0 (COMPLETE) + foundation apps ---
    '00_tenants'        = @('tenants',        'tenants',        '0. Tenant & Subscription Management')
    'accounts'          = @('accounts',       'accounts',       'Foundation: Accounts (Users, Roles, Auth)')
    'core'              = @('core',           'core',           'Foundation: Core (Tenant, Audit, Navigation)')
    'dashboard'         = @('dashboard',      'dashboard',      'Foundation: Dashboard (KPI aggregation)')
    # --- Modules 1-20 (roadmap; built on demand by /next-module) ---
    '01_procurement'    = @('procurement',    'procurement',    '1. Asset Procurement & Acquisition')
    '02_inventory'      = @('inventory',      'inventory',      '2. Asset Inventory & Tracking')
    '03_classification' = @('classification', 'classification', '3. Asset Classification & Categorization')
    '04_depreciation'   = @('depreciation',   'depreciation',   '4. Depreciation & Financial Management')
    '05_maintenance'    = @('maintenance',    'maintenance',    '5. Maintenance & Repair Management')
    '06_performance'    = @('performance',    'performance',    '6. Asset Performance & Utilization')
    '07_reliability'    = @('reliability',    'reliability',    '7. Asset Reliability & Condition Monitoring')
    '08_warranty'       = @('warranty',       'warranty',       '8. Warranty & Insurance Management')
    '09_disposal'       = @('disposal',       'disposal',       '9. Asset Disposal & Retirement')
    '10_leasing'        = @('leasing',        'leasing',        '10. Lease & Rental Management')
    '11_compliance'     = @('compliance',     'compliance',     '11. Compliance & Regulatory Management')
    '12_risk'           = @('risk',           'risk',           '12. Asset Risk Management')
    '13_mobile'         = @('mobile',         'mobile',         '13. Mobile Asset Management')
    '14_analytics'      = @('analytics',      'analytics',      '14. Asset Analytics & Business Intelligence')
    '15_integrations'   = @('integrations',   'integrations',   '15. Integration & API Hub')
    '16_documents'      = @('documents',      'documents',      '16. Document & Knowledge Management')
    '17_facilities'     = @('facilities',     'facilities',     '17. Space & Facility Asset Management')
    '18_itam'           = @('itam',           'itam',           '18. IT Asset Management (ITAM)')
    '19_fleet'          = @('fleet',          'fleet',          '19. Fleet & Vehicle Management')
    '20_administration' = @('administration', 'administration', '20. System Administration & Security')
}

# Friendly aliases -> registry key
$aliases = @{
    # --- Module 0 + foundation ---
    '0'   = '00_tenants'
    '00'  = '00_tenants'
    'tenants'        = '00_tenants'
    'tenant'         = '00_tenants'
    'subscription'   = '00_tenants'
    'subscriptions'  = '00_tenants'
    'billing'        = '00_tenants'
    'invoice'        = '00_tenants'
    'invoices'       = '00_tenants'
    'accounts'       = 'accounts'
    'account'        = 'accounts'
    'users'          = 'accounts'
    'user'           = 'accounts'
    'roles'          = 'accounts'
    'auth'           = 'accounts'
    'core'           = 'core'
    'audit'          = 'core'
    'navigation'     = 'core'
    'dashboard'      = 'dashboard'
    'kpi'            = 'dashboard'
    'home'           = 'dashboard'
    # --- Modules 1-20 numeric ---
    '1'   = '01_procurement'
    '01'  = '01_procurement'
    '2'   = '02_inventory'
    '02'  = '02_inventory'
    '3'   = '03_classification'
    '03'  = '03_classification'
    '4'   = '04_depreciation'
    '04'  = '04_depreciation'
    '5'   = '05_maintenance'
    '05'  = '05_maintenance'
    '6'   = '06_performance'
    '06'  = '06_performance'
    '7'   = '07_reliability'
    '07'  = '07_reliability'
    '8'   = '08_warranty'
    '08'  = '08_warranty'
    '9'   = '09_disposal'
    '09'  = '09_disposal'
    '10'  = '10_leasing'
    '11'  = '11_compliance'
    '12'  = '12_risk'
    '13'  = '13_mobile'
    '14'  = '14_analytics'
    '15'  = '15_integrations'
    '16'  = '16_documents'
    '17'  = '17_facilities'
    '18'  = '18_itam'
    '19'  = '19_fleet'
    '20'  = '20_administration'
    # --- Modules 1-20 app folder names + friendly keywords (asset terms) ---
    'procurement'    = '01_procurement'
    'acquisition'    = '01_procurement'
    'purchase'       = '01_procurement'
    'requisition'    = '01_procurement'
    'rfq'            = '01_procurement'
    'po'             = '01_procurement'
    'grn'            = '01_procurement'
    'inventory'      = '02_inventory'
    'asset'          = '02_inventory'
    'assets'         = '02_inventory'
    'tracking'       = '02_inventory'
    'register'       = '02_inventory'
    'movement'       = '02_inventory'
    'classification' = '03_classification'
    'category'       = '03_classification'
    'categorization' = '03_classification'
    'taxonomy'       = '03_classification'
    'criticality'    = '03_classification'
    'depreciation'   = '04_depreciation'
    'financial'      = '04_depreciation'
    'finance'        = '04_depreciation'
    'valuation'      = '04_depreciation'
    'capitalization' = '04_depreciation'
    'maintenance'    = '05_maintenance'
    'repair'         = '05_maintenance'
    'workorder'      = '05_maintenance'
    'pm'             = '05_maintenance'
    'spare'          = '05_maintenance'
    'performance'    = '06_performance'
    'utilization'    = '06_performance'
    'oee'            = '06_performance'
    'uptime'         = '06_performance'
    'energy'         = '06_performance'
    'reliability'    = '07_reliability'
    'condition'      = '07_reliability'
    'predictive'     = '07_reliability'
    'fmea'           = '07_reliability'
    'calibration'    = '07_reliability'
    'rcm'            = '07_reliability'
    'warranty'       = '08_warranty'
    'insurance'      = '08_warranty'
    'claim'          = '08_warranty'
    'policy'         = '08_warranty'
    'disposal'       = '09_disposal'
    'retirement'     = '09_disposal'
    'resale'         = '09_disposal'
    'salvage'        = '09_disposal'
    'scrap'          = '09_disposal'
    'leasing'        = '10_leasing'
    'lease'          = '10_leasing'
    'rental'         = '10_leasing'
    'compliance'     = '11_compliance'
    'regulatory'     = '11_compliance'
    'license'        = '11_compliance'
    'permit'         = '11_compliance'
    'risk'           = '12_risk'
    'continuity'     = '12_risk'
    'mitigation'     = '12_risk'
    'mobile'         = '13_mobile'
    'field'          = '13_mobile'
    'scan'           = '13_mobile'
    'geofence'       = '13_mobile'
    'analytics'      = '14_analytics'
    'intelligence'   = '14_analytics'
    'bi'             = '14_analytics'
    'forecast'       = '14_analytics'
    'lcc'            = '14_analytics'
    'integrations'   = '15_integrations'
    'integration'    = '15_integrations'
    'api'            = '15_integrations'
    'connector'      = '15_integrations'
    'webhook'        = '15_integrations'
    'documents'      = '16_documents'
    'document'       = '16_documents'
    'knowledge'      = '16_documents'
    'sop'            = '16_documents'
    'manual'         = '16_documents'
    'facilities'     = '17_facilities'
    'facility'       = '17_facilities'
    'space'          = '17_facilities'
    'floor'          = '17_facilities'
    'hvac'           = '17_facilities'
    'itam'           = '18_itam'
    'it'             = '18_itam'
    'hardware'       = '18_itam'
    'software'       = '18_itam'
    'cmdb'           = '18_itam'
    'fleet'          = '19_fleet'
    'vehicle'        = '19_fleet'
    'vehicles'       = '19_fleet'
    'fuel'           = '19_fleet'
    'telematics'     = '19_fleet'
    'administration' = '20_administration'
    'admin'          = '20_administration'
    'security'       = '20_administration'
}

# -------- Resolve which keys to process --------
$targetKeys = @()
$lookup = $Module.Trim().ToLower()

if ($lookup -eq 'all' -or $lookup -eq '*') {
    $targetKeys = @($registry.Keys)
}
elseif ($registry.Contains($Module)) {
    $targetKeys = @($Module)
}
elseif ($aliases.ContainsKey($lookup)) {
    $targetKeys = @($aliases[$lookup])
}
else {
    # last-chance fuzzy: contains match against title
    foreach ($k in $registry.Keys) {
        $title = $registry[$k][2].ToLower()
        if ($title -like "*$lookup*") {
            $targetKeys = @($k)
            break
        }
    }
}

if ($targetKeys.Count -eq 0) {
    Write-Error @"
Unknown module: '$Module'.

Valid identifiers:
  Number:       0..20  (or 00..20)
  App folder:   tenants, accounts, core, dashboard,
                procurement, inventory, classification, depreciation, maintenance, performance,
                reliability, warranty, disposal, leasing, compliance, risk, mobile, analytics,
                integrations, documents, facilities, itam, fleet, administration
  Special:      all   (regenerate every module)

Examples:
  pwsh .claude\skills\dump-module\dump_module.ps1 -Module tenants
  pwsh .claude\skills\dump-module\dump_module.ps1 -Module 0
  pwsh .claude\skills\dump-module\dump_module.ps1 -Module procurement
  pwsh .claude\skills\dump-module\dump_module.ps1 -Module all
"@
    exit 1
}

# -------- Ensure temp/ exists --------
$outDir = Join-Path $RepoRoot 'temp'
if (-not (Test-Path $outDir)) {
    New-Item -ItemType Directory -Path $outDir -Force | Out-Null
}

# -------- Helpers --------
function Add-Section {
    param([string]$OutFile, [string]$Header)
    $banner = ('=' * 100)
    Add-Content -Path $OutFile -Value "`r`n$banner`r`n$Header`r`n$banner`r`n" -Encoding UTF8
}

function Add-FileBlock {
    param([string]$OutFile, [System.IO.FileInfo]$File, [string]$RelPath)
    $sub = ('-' * 100)
    Add-Content -Path $OutFile -Value "`r`n$sub`r`nFILE: $RelPath`r`n$sub" -Encoding UTF8
    $content = [System.IO.File]::ReadAllText($File.FullName)
    Add-Content -Path $OutFile -Value $content -Encoding UTF8
}

# -------- Generate --------
foreach ($key in $targetKeys) {
    $appsFolder, $tplFolder, $title = $registry[$key]
    $outFile = Join-Path $outDir "$key.txt"

    Set-Content -Path $outFile -Value "" -Encoding UTF8

    $banner = ('#' * 100)
    Add-Content -Path $outFile -Value "$banner`r`n# MODULE $title`r`n# Backend:  apps\$appsFolder\`r`n# Frontend: templates\$tplFolder\`r`n# Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`r`n$banner" -Encoding UTF8

    # Backend
    $appsPath = Join-Path $RepoRoot "apps\$appsFolder"
    if (Test-Path $appsPath) {
        Add-Section -OutFile $outFile -Header "BACKEND  (apps\$appsFolder\)"
        $files = Get-ChildItem -Path $appsPath -Recurse -File `
            | Where-Object { $_.FullName -notmatch '__pycache__' } `
            | Where-Object { $_.Extension -in '.py', '.txt', '.md', '.json', '.yml', '.yaml', '.cfg', '.ini' } `
            | Sort-Object FullName
        foreach ($f in $files) {
            $rel = $f.FullName.Substring($RepoRoot.Length + 1)
            Add-FileBlock -OutFile $outFile -File $f -RelPath $rel
        }
    } else {
        Add-Content -Path $outFile -Value "`r`n(no backend folder found at apps\$appsFolder\)`r`n" -Encoding UTF8
    }

    # Frontend
    $tplPath = Join-Path $RepoRoot "templates\$tplFolder"
    if (Test-Path $tplPath) {
        Add-Section -OutFile $outFile -Header "FRONTEND  (templates\$tplFolder\)"
        $files = Get-ChildItem -Path $tplPath -Recurse -File `
            | Where-Object { $_.Extension -in '.html', '.htm', '.js', '.css', '.txt' } `
            | Sort-Object FullName
        foreach ($f in $files) {
            $rel = $f.FullName.Substring($RepoRoot.Length + 1)
            Add-FileBlock -OutFile $outFile -File $f -RelPath $rel
        }
    } else {
        Add-Content -Path $outFile -Value "`r`n(no frontend folder found at templates\$tplFolder\)`r`n" -Encoding UTF8
    }

    $size = (Get-Item $outFile).Length
    Write-Output ("OK  {0,-45} {1,12:N0} bytes  ->  temp\{0}.txt" -f $key, $size)
}
