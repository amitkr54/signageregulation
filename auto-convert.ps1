# Automated HTML Page Converter for SignageWorks
# This script will automatically add header/footer placeholders to your existing HTML files

Write-Host "🔄 SignageWorks Automatic HTML Converter" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green

# Get all HTML files except templates and examples
$htmlFiles = Get-ChildItem -Path "." -Filter "*.html" | Where-Object { 
    $_.Name -notlike "*template*" -and 
    $_.Name -notlike "*example*" -and 
    $_.Name -notlike "*test*" -and
    $_.Name -ne "auto-convert.ps1"
}

if ($htmlFiles.Count -eq 0) {
    Write-Host "❌ No HTML files found to convert." -ForegroundColor Red
    exit
}

Write-Host "📋 Found $($htmlFiles.Count) HTML files to convert:" -ForegroundColor Yellow
$htmlFiles | ForEach-Object { Write-Host "  • $($_.Name)" -ForegroundColor White }

$proceed = Read-Host "`n❓ Do you want to proceed with automatic conversion? (Y/N)"

if ($proceed -ne "Y" -and $proceed -ne "y") {
    Write-Host "❌ Operation cancelled." -ForegroundColor Red
    exit
}

# Create backup directory
$backupDir = "backup-$(Get-Date -Format 'yyyy-MM-dd-HHmm')"
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
Write-Host "`n📁 Created backup directory: $backupDir" -ForegroundColor Green

# SEO templates for different page types
$seoTemplates = @{
    "index.html" = @{
        title = "SignageWorks | Professional Signage Solutions `& Compliance Standards India"
        description = "Leading provider of professional signage solutions in India. Expert guidance on BIS-IS standards, NBCC guidelines, fire safety signage `& compliance requirements."
        keywords = "signage solutions India, BIS-IS standards, NBCC guidelines, fire safety signage, emergency signage, compliance signage"
    }
    "about-compliance.html" = @{
        title = "About Signage Compliance - SignageWorks | BIS-IS `& NBCC Standards"
        description = "Learn about signage compliance requirements in India. Comprehensive guide to BIS-IS standards, NBCC guidelines and regulatory requirements for professional signage."
        keywords = "signage compliance, BIS-IS standards, NBCC compliance, signage regulations India, building code signage"
    }
    "industry-standards.html" = @{
        title = "Industry Standards for Signage - SignageWorks | Professional Guidelines"
        description = "Complete guide to industry standards for professional signage in India. BIS-IS specifications, NBCC requirements and compliance guidelines for commercial signage."
        keywords = "industry standards signage, BIS-IS specifications, professional signage guidelines, commercial signage standards"
    }
    "government-guidelines.html" = @{
        title = "Government Guidelines for Signage - SignageWorks | Official Standards"
        description = "Official government guidelines and regulations for signage in India. Latest updates on BIS-IS standards, NBCC codes and regulatory compliance requirements."
        keywords = "government signage guidelines, official signage standards, BIS regulations, NBCC signage codes"
    }
    "downloads.html" = @{
        title = "Downloads - Signage Standards `& Guidelines | SignageWorks Resources"
        description = "Download official signage standards, BIS-IS specifications, NBCC guidelines and compliance resources. Free access to professional signage documentation."
        keywords = "signage standards download, BIS-IS documents, NBCC guidelines PDF, signage compliance resources"
    }
}

# Default SEO template for other pages
$defaultSeoTemplate = @{
    title = "PLACEHOLDER_TITLE - SignageWorks | Professional Signage Solutions"
    description = "PLACEHOLDER_DESCRIPTION - Professional signage solutions and compliance guidance from SignageWorks."
    keywords = "signage, compliance, standards, BIS, NBCC, professional signage solutions"
}

function Get-PageTitle($filename, $content) {
    # Extract existing title if present
    if ($content -match '(?s)<title[^>]*>(.*?)</title>') {
        $existingTitle = $matches[1].Trim()
        if ($existingTitle -and $existingTitle -notlike "*Untitled*") {
            return $existingTitle
        }
    }
    
    # Use predefined title or generate from filename
    if ($seoTemplates.ContainsKey($filename)) {
        return $seoTemplates[$filename].title
    }
    
    $pageName = [System.IO.Path]::GetFileNameWithoutExtension($filename) -replace '-', ' '
    $pageName = (Get-Culture).TextInfo.ToTitleCase($pageName.ToLower())
    return "$pageName - SignageWorks | Professional Signage Solutions"
}

function Get-PageDescription($filename, $content) {
    # Extract existing meta description if present
    if ($content -match '(?s)<meta\s+name=""description""\s+content=""([^""]*)"">') {
        $existingDesc = $matches[1].Trim()
        if ($existingDesc -and $existingDesc.Length -gt 50) {
            return $existingDesc
        }
    }
    
    # Use predefined description or generate from filename
    if ($seoTemplates.ContainsKey($filename)) {
        return $seoTemplates[$filename].description
    }
    
    $pageName = [System.IO.Path]::GetFileNameWithoutExtension($filename) -replace '-', ' '
    return "Professional guidance on $pageName from SignageWorks. Expert signage solutions and compliance standards for Indian market."
}

function Get-PageKeywords($filename) {
    if ($seoTemplates.ContainsKey($filename)) {
        return $seoTemplates[$filename].keywords
    }
    return $defaultSeoTemplate.keywords
}

foreach ($file in $htmlFiles) {
    Write-Host "`n🔄 Processing: $($file.Name)" -ForegroundColor Cyan
    
    # Create backup
    Copy-Item $file.FullName -Destination "$backupDir\$($file.Name)"
    Write-Host "  ✅ Backup created" -ForegroundColor Green
    
    # Read current content
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    
    # Check if already converted
    if ($content -match 'header-placeholder' -or $content -match 'footer-placeholder') {
        Write-Host "  ⚠️ File already converted, skipping..." -ForegroundColor Yellow
        continue
    }
    
    # Extract or generate SEO data
    $pageTitle = Get-PageTitle $file.Name $content
    $pageDescription = Get-PageDescription $file.Name $content
    $pageKeywords = Get-PageKeywords $file.Name
    $canonicalUrl = "https://signageworks.co.in/$($file.Name)"
    
    # Build the new HTML structure
    $newContent = $content
    
    # Add navigation CSS if not present
    if ($newContent -notmatch 'navigation\.css') {
        $cssInsert = "`n    <link rel=`"stylesheet`" href=`"css/navigation.css`">"
        if ($newContent -match '(\s*</head>)') {
            $newContent = $newContent -replace '(\s*</head>)', "$cssInsert`$1"
        }
    }
    
    # Update or add SEO meta tags
    $seoSection = @"
    
    <!-- SEO Meta Tags - $($file.Name.ToUpper()) -->
    <title>$pageTitle</title>
    <meta name="description" content="$pageDescription">
    <meta name="keywords" content="$pageKeywords">
    <meta name="author" content="SignageWorks">
    
    <!-- Open Graph Meta Tags -->
    <meta property="og:title" content="$pageTitle">
    <meta property="og:description" content="$pageDescription">
    <meta property="og:image" content="https://signageworks.co.in/images/og-image.jpg">
    <meta property="og:url" content="$canonicalUrl">
    <meta property="og:type" content="website">
    
    <!-- Twitter Card Meta Tags -->
    <meta name="twitter:card" content="summary_large_image">
    <meta name="twitter:title" content="$pageTitle">
    <meta name="twitter:description" content="$pageDescription">
    <meta name="twitter:image" content="https://signageworks.co.in/images/twitter-image.jpg">
    
    <!-- Canonical URL -->
    <link rel="canonical" href="$canonicalUrl">
"@

    # Remove existing title and meta description to avoid duplicates
    $newContent = $newContent -replace '<title[^>]*>.*?</title>', ''
    $newContent = $newContent -replace '<meta\s+name="description"[^>]*>', ''
    $newContent = $newContent -replace '<meta\s+name="keywords"[^>]*>', ''
    
    # Insert SEO section before </head>
    if ($newContent -match '(\s*</head>)') {
        $newContent = $newContent -replace '(\s*</head>)', "$seoSection`$1"
    }
    
    # Add header placeholder after <body>
    if ($newContent -match '(<body[^>]*>)') {
        $headerPlaceholder = "`$1`n    <!-- Header placeholder - Global navigation -->`n    <div id=`"header-placeholder`"></div>`n"
        $newContent = $newContent -replace '(<body[^>]*>)', $headerPlaceholder
    }
    
    # Add footer placeholder and script before </body>
    if ($newContent -match '(\s*</body>)') {
        $footerSection = "`n    <!-- Footer placeholder - Global footer -->`n    <div id=`"footer-placeholder`"></div>`n`n    <!-- Global includes script -->`n    <script src=`"js/includes.js`"></script>`$1"
        $newContent = $newContent -replace '(\s*</body>)', $footerSection
    }
    
    # Write the updated content
    $newContent | Out-File -FilePath $file.FullName -Encoding UTF8 -NoNewline
    
    Write-Host "  ✅ Converted successfully!" -ForegroundColor Green
    Write-Host "    📝 Title: $($pageTitle.Substring(0, [Math]::Min(60, $pageTitle.Length)))..." -ForegroundColor Gray
}

Write-Host "`n" + "="*60 -ForegroundColor Green
Write-Host "🎉 CONVERSION COMPLETE!" -ForegroundColor Green
Write-Host "="*60 -ForegroundColor Green

Write-Host "`n📊 Summary:" -ForegroundColor Yellow
Write-Host "✅ Processed: $($htmlFiles.Count) files" -ForegroundColor Green
Write-Host "📁 Backups saved in: $backupDir" -ForegroundColor Green
Write-Host "🔧 Added: Global header/footer placeholders" -ForegroundColor Green
Write-Host "📱 Added: Mobile-responsive navigation CSS" -ForegroundColor Green
Write-Host "🎯 Added: Unique SEO meta tags for each page" -ForegroundColor Green

Write-Host "`n🧪 Next Steps:" -ForegroundColor Yellow
Write-Host "1. Test by visiting: http://localhost/signageworks.co.in/test-page.html" -ForegroundColor White
Write-Host "2. Check your converted pages work correctly" -ForegroundColor White
Write-Host "3. Customize includes/header.html and includes/footer.html" -ForegroundColor White
Write-Host "4. Deploy to Cloudflare Pages when ready" -ForegroundColor White

Write-Host "`n🎯 Test URLs:" -ForegroundColor Yellow
foreach ($file in $htmlFiles[0..2]) {  # Show first 3 files
    Write-Host "   http://localhost/signageworks.co.in/$($file.Name)" -ForegroundColor Cyan
}
if ($htmlFiles.Count -gt 3) {
    Write-Host "   ... and $($htmlFiles.Count - 3) more files" -ForegroundColor Gray
}

Write-Host "`nPress any key to continue..." -ForegroundColor Green
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
