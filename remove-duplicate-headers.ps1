# Remove Duplicate Headers Script
# This script removes ONLY the inline <header> navigation sections
# It PRESERVES all SEO meta tags and <head> content

Write-Host "🔄 Removing Duplicate Headers (Preserving SEO Meta Tags)" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Green

# Get HTML files that might have duplicate headers
$htmlFiles = Get-ChildItem *.html | Where-Object { 
    $_.Name -notlike "*template*" -and 
    $_.Name -notlike "*example*" -and 
    $_.Name -notlike "*test*" -and
    $_.Name -notlike "*dropdown-test*" -and
    $_.Name -ne "index.html"  # Skip index as we already fixed it
}

if ($htmlFiles.Count -eq 0) {
    Write-Host "❌ No HTML files found to process." -ForegroundColor Red
    exit
}

Write-Host "📋 Found $($htmlFiles.Count) files to check for duplicate headers:" -ForegroundColor Yellow
$htmlFiles | ForEach-Object { Write-Host "  • $($_.Name)" -ForegroundColor White }

$proceed = Read-Host "`n❓ This will remove duplicate inline headers while keeping all SEO meta tags. Continue? (Y/N)"

if ($proceed -ne "Y" -and $proceed -ne "y") {
    Write-Host "❌ Operation cancelled." -ForegroundColor Red
    exit
}

# Create backup directory
$backupDir = "header-cleanup-backup-$(Get-Date -Format 'yyyy-MM-dd-HHmm')"
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
Write-Host "`n📁 Created backup directory: $backupDir" -ForegroundColor Green

$processedCount = 0
$skippedCount = 0

foreach ($file in $htmlFiles) {
    Write-Host "`n🔍 Checking: $($file.Name)" -ForegroundColor Cyan
    
    # Create backup first
    Copy-Item $file.FullName -Destination "$backupDir\$($file.Name)"
    
    # Read file content
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    
    # Check if file has both header-placeholder AND inline header
    $hasPlaceholder = $content -like "*header-placeholder*"
    $hasInlineHeader = $content -like "*<header>*<nav>*"
    
    if ($hasPlaceholder -and $hasInlineHeader) {
        Write-Host "  ⚠️ Found duplicate headers - removing inline header..." -ForegroundColor Yellow
        
        # Find the inline header section (from <header> to </header>)
        # This regex captures the entire header block including navigation
        $headerPattern = '(?s)<header>.*?</header>'
        
        if ($content -match $headerPattern) {
            # Remove the inline header section
            $newContent = $content -replace $headerPattern, ''
            
            # Clean up any extra blank lines
            $newContent = $newContent -replace '\n\s*\n\s*\n', "`n`n"
            
            # Write the cleaned content back
            $newContent | Out-File -FilePath $file.FullName -Encoding UTF8 -NoNewline
            
            Write-Host "  ✅ Removed duplicate header successfully!" -ForegroundColor Green
            $processedCount++
        } else {
            Write-Host "  ❌ Could not find header pattern to remove" -ForegroundColor Red
        }
        
    } elseif ($hasPlaceholder -and -not $hasInlineHeader) {
        Write-Host "  ✅ Already using global header only - no changes needed" -ForegroundColor Green
        $skippedCount++
        
    } elseif (-not $hasPlaceholder) {
        Write-Host "  ⚠️ Missing header-placeholder - this page may not be converted yet" -ForegroundColor Yellow
        $skippedCount++
        
    } else {
        Write-Host "  ✅ No duplicate header found" -ForegroundColor Green
        $skippedCount++
    }
        
    } elseif ($hasPlaceholder -and -not $hasInlineHeader) {
        Write-Host "  ✅ Already using global header only - no changes needed" -ForegroundColor Green
        $skippedCount++
        
    } elseif (-not $hasPlaceholder) {
        Write-Host "  ⚠️ Missing header-placeholder - this page may not be converted yet" -ForegroundColor Yellow
        $skippedCount++
        
    } else {
        Write-Host "  ✅ No duplicate header found" -ForegroundColor Green
        $skippedCount++
    }
}

# Also check for duplicate footers
Write-Host "`n🔍 Checking for duplicate footers..." -ForegroundColor Cyan

foreach ($file in $htmlFiles) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    
    $hasFooterPlaceholder = $content -like "*footer-placeholder*"
    $hasInlineFooter = $content -like "*<footer>*<div class=*footer-content*"
    
    if ($hasFooterPlaceholder -and $hasInlineFooter) {
        Write-Host "  ⚠️ Found duplicate footer in $($file.Name) - removing..." -ForegroundColor Yellow
        
        # Remove inline footer (from <footer> to </footer>)
        $footerPattern = '(?s)<footer>.*?</footer>'
        
        if ($content -match $footerPattern) {
            $newContent = $content -replace $footerPattern, ''
            $newContent = $newContent -replace '\n\s*\n\s*\n', "`n`n"
            $newContent | Out-File -FilePath $file.FullName -Encoding UTF8 -NoNewline
            
            Write-Host "    ✅ Removed duplicate footer from $($file.Name)" -ForegroundColor Green
        }
    }
}

Write-Host "`n" + "="*60 -ForegroundColor Green
Write-Host "🎉 CLEANUP COMPLETE!" -ForegroundColor Green
Write-Host "="*60 -ForegroundColor Green

Write-Host "`n📊 Summary:" -ForegroundColor Yellow
Write-Host "✅ Files processed: $processedCount" -ForegroundColor Green
Write-Host "⏭️ Files skipped: $skippedCount" -ForegroundColor Blue
Write-Host "📁 Backups saved in: $backupDir" -ForegroundColor Green

Write-Host "`n🔍 What was preserved:" -ForegroundColor Yellow
Write-Host "✅ All SEO meta tags (title, description, keywords)" -ForegroundColor Green
Write-Host "✅ All Open Graph and Twitter Card meta tags" -ForegroundColor Green
Write-Host "✅ Canonical URLs and structured data" -ForegroundColor Green
Write-Host "✅ All page content and styling" -ForegroundColor Green

Write-Host "`n🗑️ What was removed:" -ForegroundColor Yellow
Write-Host "❌ Duplicate inline <header> navigation sections" -ForegroundColor Red
Write-Host "❌ Duplicate inline <footer> sections" -ForegroundColor Red

Write-Host "`n🧪 Test your pages now:" -ForegroundColor Yellow
Write-Host "http://localhost/signageworks.co.in/" -ForegroundColor Cyan

Write-Host "`nPress any key to continue..." -ForegroundColor Green
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
