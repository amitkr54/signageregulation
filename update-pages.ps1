# PowerShell script to update existing HTML pages with SEO-friendly header/footer system

Write-Host "SignageWorks HTML Page Updater" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green

# Get all HTML files in current directory
$htmlFiles = Get-ChildItem -Path "." -Filter "*.html" | Where-Object { 
    $_.Name -notlike "*template*" -and 
    $_.Name -notlike "*example*" -and
    $_.Name -ne "update-pages.ps1"
}

Write-Host "Found $($htmlFiles.Count) HTML files to process:" -ForegroundColor Yellow
$htmlFiles | ForEach-Object { Write-Host "  - $($_.Name)" }

$proceed = Read-Host "`nDo you want to proceed? This will backup your files first (Y/N)"

if ($proceed -ne "Y" -and $proceed -ne "y") {
    Write-Host "Operation cancelled." -ForegroundColor Red
    exit
}

# Create backup directory
$backupDir = "backup-$(Get-Date -Format 'yyyy-MM-dd-HHmm')"
New-Item -ItemType Directory -Path $backupDir -Force
Write-Host "`nCreated backup directory: $backupDir" -ForegroundColor Green

foreach ($file in $htmlFiles) {
    Write-Host "`nProcessing: $($file.Name)" -ForegroundColor Cyan
    
    # Create backup
    Copy-Item $file.FullName -Destination "$backupDir\$($file.Name)"
    Write-Host "  ✓ Backup created" -ForegroundColor Green
    
    # Read current content
    $content = Get-Content $file.FullName -Raw
    
    # Check if file already has placeholders
    if ($content -match 'header-placeholder' -or $content -match 'footer-placeholder') {
        Write-Host "  ⚠ File already has placeholders, skipping..." -ForegroundColor Yellow
        continue
    }
    
    Write-Host "  → File needs updating" -ForegroundColor White
    Write-Host "    Please manually update this file with:" -ForegroundColor White
    Write-Host "    1. Add unique SEO meta tags in <head>" -ForegroundColor White
    Write-Host "    2. Add <div id='header-placeholder'></div> after <body>" -ForegroundColor White
    Write-Host "    3. Add <div id='footer-placeholder'></div> before </body>" -ForegroundColor White
    Write-Host "    4. Add <script src='js/includes.js'></script> before </body>" -ForegroundColor White
    Write-Host "    5. Add <link rel='stylesheet' href='css/navigation.css'>" -ForegroundColor White
}

Write-Host "`n" + "="*50 -ForegroundColor Green
Write-Host "SUMMARY:" -ForegroundColor Green
Write-Host "- Backups created in: $backupDir" -ForegroundColor Green
Write-Host "- Use 'seo-example-index.html' as a reference for SEO meta tags" -ForegroundColor Green
Write-Host "- Use 'template.html' as a reference for structure" -ForegroundColor Green
Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "1. Customize header.html and footer.html with your content" -ForegroundColor White
Write-Host "2. Update each HTML file with unique SEO meta tags" -ForegroundColor White
Write-Host "3. Add header/footer placeholders to each page" -ForegroundColor White
Write-Host "4. Test locally, then deploy to Cloudflare Pages" -ForegroundColor White

Write-Host "`nPress any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
