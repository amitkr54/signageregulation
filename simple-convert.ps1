# Simple HTML Converter for SignageWorks
# This script adds header/footer placeholders and basic SEO to your HTML files

Write-Host "Converting HTML files to use global header/footer..." -ForegroundColor Green

# Get HTML files to convert
$files = Get-ChildItem *.html | Where-Object { 
    $_.Name -notlike "*template*" -and 
    $_.Name -notlike "*example*" -and 
    $_.Name -notlike "*test*" 
}

if ($files.Count -eq 0) {
    Write-Host "No HTML files found to convert." -ForegroundColor Red
    exit
}

Write-Host "Found $($files.Count) files to convert:" -ForegroundColor Yellow
$files | ForEach-Object { Write-Host "  - $($_.Name)" }

$confirm = Read-Host "`nProceed with conversion? (Y/N)"
if ($confirm -ne "Y" -and $confirm -ne "y") {
    Write-Host "Cancelled." -ForegroundColor Red
    exit
}

# Create backup
$backupFolder = "backup-$(Get-Date -Format 'yyyyMMdd-HHmm')"
New-Item -ItemType Directory -Path $backupFolder -Force | Out-Null
Write-Host "`nBackup folder created: $backupFolder" -ForegroundColor Green

foreach ($file in $files) {
    Write-Host "Processing $($file.Name)..." -ForegroundColor Cyan
    
    # Backup original
    Copy-Item $file.FullName -Destination "$backupFolder\$($file.Name)"
    
    # Read content
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    
    # Skip if already converted
    if ($content -like "*header-placeholder*") {
        Write-Host "  Already converted, skipping." -ForegroundColor Yellow
        continue
    }
    
    # Generate page-specific SEO
    $fileName = $file.Name
    $pageTitle = switch ($fileName) {
        "index.html" { "SignageWorks | Professional Signage Solutions India" }
        "about-compliance.html" { "About Signage Compliance - SignageWorks" }
        "industry-standards.html" { "Industry Standards for Signage - SignageWorks" }
        "government-guidelines.html" { "Government Guidelines for Signage - SignageWorks" }
        "downloads.html" { "Downloads - Signage Standards - SignageWorks" }
        default { 
            $name = [System.IO.Path]::GetFileNameWithoutExtension($fileName) -replace '-', ' '
            $name = (Get-Culture).TextInfo.ToTitleCase($name)
            "$name - SignageWorks"
        }
    }
    
    $pageDesc = switch ($fileName) {
        "index.html" { "Leading provider of professional signage solutions in India. Expert guidance on BIS-IS standards, NBCC guidelines, and compliance requirements." }
        "about-compliance.html" { "Learn about signage compliance requirements in India. Guide to BIS-IS standards and NBCC guidelines for professional signage." }
        "industry-standards.html" { "Complete guide to industry standards for professional signage in India. BIS-IS specifications and compliance guidelines." }
        "government-guidelines.html" { "Official government guidelines for signage in India. Latest BIS-IS standards and NBCC codes for regulatory compliance." }
        "downloads.html" { "Download signage standards, BIS-IS specifications, and NBCC guidelines. Free access to professional signage documentation." }
        default { "Professional signage solutions and compliance guidance from SignageWorks. Expert standards for Indian market." }
    }
    
    # Add CSS link if not present
    if ($content -notlike "*navigation.css*") {
        $content = $content -replace '(\s*</head>)', "`n    <link rel=`"stylesheet`" href=`"css/navigation.css`">`$1"
    }
    
    # Update title if exists, or add before </head>
    if ($content -like "*<title>*") {
        $content = $content -replace '<title>.*?</title>', "<title>$pageTitle</title>"
    } else {
        $content = $content -replace '(\s*</head>)', "`n    <title>$pageTitle</title>`$1"
    }
    
    # Add meta description
    $metaTags = @"
`n    <meta name="description" content="$pageDesc">
    <meta name="keywords" content="signage, compliance, standards, BIS, NBCC">
    <meta name="author" content="SignageWorks">
"@
    
    $content = $content -replace '(\s*</head>)', "$metaTags`$1"
    
    # Add header placeholder after <body>
    $content = $content -replace '(<body[^>]*>)', "`$1`n    <div id=`"header-placeholder`"></div>`n"
    
    # Add footer and script before </body>
    $footerSection = @"
`n    <div id="footer-placeholder"></div>
    <script src="js/includes.js"></script>
"@
    
    $content = $content -replace '(\s*</body>)', "$footerSection`$1"
    
    # Save the updated file
    $content | Out-File -FilePath $file.FullName -Encoding UTF8 -NoNewline
    
    Write-Host "  Converted successfully!" -ForegroundColor Green
}

Write-Host "`nConversion complete!" -ForegroundColor Green
Write-Host "Backup saved in: $backupFolder" -ForegroundColor Yellow
Write-Host "`nTest your pages at:" -ForegroundColor Yellow
Write-Host "http://localhost/signageworks.co.in/" -ForegroundColor Cyan

Read-Host "`nPress Enter to continue..."
