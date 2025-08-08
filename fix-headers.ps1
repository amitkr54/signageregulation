# Remove Duplicate Headers Script
# This script removes ONLY the inline <header> navigation sections
# It PRESERVES all SEO meta tags and <head> content

Write-Host "🔄 Fixing Duplicate Headers (Preserving SEO Meta Tags)" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Green

# Get HTML files that might have duplicate headers
$htmlFiles = Get-ChildItem *.html | Where-Object { 
    $_.Name -notlike "*template*" -and 
    $_.Name -notlike "*example*" -and 
    $_.Name -notlike "*test*" -and
    $_.Name -notlike "*dropdown*" -and
    $_.Name -ne "index.html"
}

Write-Host "Found $($htmlFiles.Count) files to check:" -ForegroundColor Yellow
$htmlFiles | ForEach-Object { Write-Host "  - $($_.Name)" }

$confirm = Read-Host "`nRemove duplicate headers? (Y/N)"
if ($confirm -ne "Y" -and $confirm -ne "y") {
    Write-Host "Cancelled." -ForegroundColor Red
    exit
}

# Create backup
$backupFolder = "header-fix-backup-$(Get-Date -Format 'yyyyMMdd-HHmm')"
New-Item -ItemType Directory -Path $backupFolder -Force | Out-Null
Write-Host "`nBackup folder created: $backupFolder" -ForegroundColor Green

$processed = 0

foreach ($file in $htmlFiles) {
    Write-Host "`nProcessing $($file.Name)..." -ForegroundColor Cyan
    
    # Backup original
    Copy-Item $file.FullName -Destination "$backupFolder\$($file.Name)"
    
    # Read content
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    
    # Check for both placeholder and inline header
    $hasPlaceholder = $content -like "*header-placeholder*"
    $hasInlineHeader = $content -match "<header>"
    
    if ($hasPlaceholder -and $hasInlineHeader) {
        Write-Host "  Found duplicate header - removing inline version..." -ForegroundColor Yellow
        
        # Remove everything from <header> to </header> (including the tags)
        $pattern = "(?s)\s*<header>.*?</header>\s*"
        $newContent = $content -replace $pattern, "`n"
        
        # Also check for duplicate footer
        if ($newContent -match "<footer>" -and $newContent -like "*footer-placeholder*") {
            Write-Host "  Found duplicate footer - removing inline version..." -ForegroundColor Yellow
            $footerPattern = "(?s)\s*<footer>.*?</footer>\s*"
            $newContent = $newContent -replace $footerPattern, "`n"
        }
        
        # Clean up extra blank lines
        $newContent = $newContent -replace "\n\n\n+", "`n`n"
        
        # Save the cleaned content
        $newContent | Out-File -FilePath $file.FullName -Encoding UTF8 -NoNewline
        
        Write-Host "  ✅ Cleaned successfully!" -ForegroundColor Green
        $processed++
        
    } elseif ($hasPlaceholder) {
        Write-Host "  ✅ Already using global header only" -ForegroundColor Green
        
    } else {
        Write-Host "  ⚠️ No header placeholder found - may need manual conversion" -ForegroundColor Yellow
    }
}

Write-Host "`n🎉 Cleanup Complete!" -ForegroundColor Green
Write-Host "Processed: $processed files" -ForegroundColor Green
Write-Host "Backup saved in: $backupFolder" -ForegroundColor Green
Write-Host "`nTest your pages now at: http://localhost/signageworks.co.in/" -ForegroundColor Cyan

Read-Host "`nPress Enter to continue..."
