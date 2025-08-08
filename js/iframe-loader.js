// Iframe Loading Utility for View Collection Pages
// SignageWorks.co.in - 2025

function handleFrameLoad() {
    const iframe = document.getElementById('contentFrame');
    const loading = document.getElementById('loading');
    const fallback = document.getElementById('fallback');
    
    try {
        // Hide loading message
        loading.style.display = 'none';
        
        // Try to access iframe content and resize
        if (iframe.contentDocument && iframe.contentDocument.body) {
            iframe.style.height = iframe.contentDocument.body.scrollHeight + 'px';
        } else {
            // Set a reasonable default height if can't access content
            iframe.style.height = '1200px';
        }
        
        // Show fallback link after a delay to give iframe time to load content
        setTimeout(function() {
            fallback.style.display = 'block';
        }, 2000);
        
    } catch (e) {
        console.log('Iframe access restricted, using fallback');
        loading.style.display = 'none';
        fallback.style.display = 'block';
        iframe.style.height = '1200px';
    }
}

// Initialize iframe loading on page load
document.addEventListener('DOMContentLoaded', function() {
    const loading = document.getElementById('loading');
    const fallback = document.getElementById('fallback');
    
    // Show loading initially
    if (loading) {
        loading.style.display = 'block';
    }
    
    // Show fallback after 5 seconds if iframe doesn't load
    setTimeout(function() {
        if (fallback && fallback.style.display === 'none') {
            fallback.style.display = 'block';
        }
    }, 5000);
});
