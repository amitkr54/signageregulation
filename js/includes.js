// Global includes loader for static HTML pages - Compatible with XAMPP and Cloudflare Pages
class HTMLIncludes {
    static async loadComponent(elementId, filePath) {
        const element = document.getElementById(elementId);
        if (!element) {
            console.warn(`Element with ID '${elementId}' not found`);
            return;
        }

        try {
            // Try XMLHttpRequest first (works better with XAMPP)
            const xhr = new XMLHttpRequest();
            xhr.open('GET', filePath, true);
            
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4) {
                    if (xhr.status === 200 || xhr.status === 0) { // 0 for file:// protocol
                        element.innerHTML = xhr.responseText;
                        console.log(`✓ Loaded: ${filePath}`);
                        
                        // Trigger custom event when component is loaded
                        const event = new CustomEvent('componentLoaded', { 
                            detail: { elementId, filePath } 
                        });
                        document.dispatchEvent(event);
                    } else {
                        throw new Error(`Failed to load ${filePath}: ${xhr.status}`);
                    }
                }
            };
            
            xhr.onerror = function() {
                // Fallback to fetch API
                console.log(`XMLHttpRequest failed for ${filePath}, trying fetch...`);
                HTMLIncludes.loadWithFetch(elementId, filePath);
            };
            
            xhr.send();
            
        } catch (error) {
            console.error('Error with XMLHttpRequest:', error);
            // Fallback to fetch
            HTMLIncludes.loadWithFetch(elementId, filePath);
        }
    }
    
    static async loadWithFetch(elementId, filePath) {
        try {
            const response = await fetch(filePath);
            if (!response.ok) {
                throw new Error(`Failed to load ${filePath}: ${response.status}`);
            }
            const content = await response.text();
            const element = document.getElementById(elementId);
            if (element) {
                element.innerHTML = content;
                console.log(`✓ Loaded with fetch: ${filePath}`);
            }
        } catch (error) {
            console.error('Error loading component with fetch:', error);
            // Show fallback message
            const element = document.getElementById(elementId);
            if (element) {
                element.innerHTML = `<div style="padding: 1rem; background: #f8f9fa; border: 1px solid #dee2e6; text-align: center;">⚠️ Could not load ${filePath}</div>`;
            }
        }
    }

    static init() {
        console.log('🔄 Initializing HTMLIncludes...');
        
        // Load header and footer
        this.loadComponent('header-placeholder', 'includes/header.html');
        this.loadComponent('footer-placeholder', 'includes/footer.html');
        
        // Set active navigation item after components load
        let loadedComponents = 0;
        const totalComponents = 2;
        
        document.addEventListener('componentLoaded', () => {
            loadedComponents++;
            if (loadedComponents === totalComponents) {
                this.setActiveNavItem();
                this.initMobileMenu();
            }
        });
    }

    static setActiveNavItem() {
        // Get current page filename
        const currentPage = window.location.pathname.split('/').pop() || 'index.html';
        
        // Find and mark active navigation item
        setTimeout(() => {
            const navLinks = document.querySelectorAll('nav a');
            navLinks.forEach(link => {
                const href = link.getAttribute('href');
                if (href === currentPage || 
                    (currentPage === 'index.html' && href === '/') ||
                    (currentPage === '' && href === 'index.html')) {
                    link.classList.add('active');
                    console.log(`✓ Set active: ${href}`);
                }
            });
        }, 200);
    }
    
    static initMobileMenu() {
        // Initialize mobile menu toggle
        setTimeout(() => {
            const mobileToggle = document.querySelector('.mobile-menu-toggle');
            const navMenu = document.querySelector('.nav-menu');
            
            if (mobileToggle && navMenu) {
                // Add mobile toggle button if it doesn't exist
                if (!mobileToggle.innerHTML) {
                    mobileToggle.innerHTML = '<span></span><span></span><span></span>';
                }
                
                mobileToggle.addEventListener('click', () => {
                    navMenu.classList.toggle('active');
                    mobileToggle.classList.toggle('active');
                });
                
                // Close mobile menu when clicking on non-dropdown links
                const navLinks = navMenu.querySelectorAll('a:not(.nav-link)');
                navLinks.forEach(link => {
                    link.addEventListener('click', () => {
                        navMenu.classList.remove('active');
                        mobileToggle.classList.remove('active');
                    });
                });
                
                // Handle dropdown toggles on mobile
                const dropdownLinks = navMenu.querySelectorAll('.nav-link');
                dropdownLinks.forEach(link => {
                    link.addEventListener('click', (e) => {
                        if (window.innerWidth <= 768) {
                            e.preventDefault();
                            const dropdown = link.closest('.dropdown');
                            dropdown.classList.toggle('active');
                        }
                    });
                });
                
                // Close mobile menu when clicking outside
                document.addEventListener('click', (e) => {
                    if (!e.target.closest('nav') && navMenu.classList.contains('active')) {
                        navMenu.classList.remove('active');
                        mobileToggle.classList.remove('active');
                    }
                });
                
                console.log('✓ Mobile menu initialized');
            }
        }, 250);
    }
}

// Auto-load when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
    console.log('✅ DOM Content Loaded - Starting HTMLIncludes');
    HTMLIncludes.init();
});

// Also try to load if DOM is already loaded
if (document.readyState === 'loading') {
    // Do nothing, DOMContentLoaded will fire
} else {
    // DOM is already loaded
    console.log('✅ DOM Already Loaded - Starting HTMLIncludes');
    HTMLIncludes.init();
}
