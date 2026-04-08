/**
 * Dark Mode Toggle
 * 
 * Manages light/dark theme preference and persists it to localStorage.
 */

(function () {
    const html = document.documentElement;
    const toggleBtn = document.getElementById('theme-toggle');
    const themeKey = 'theme';

    /**
     * Get the current theme from storage or system preference
     */
    function getTheme() {
        const stored = localStorage.getItem(themeKey);
        if (stored) return stored;

        if (window.matchMedia('(prefers-color-scheme: dark)').matches) {
            return 'dark';
        }
        return 'light';
    }

    /**
     * Set the theme and update the DOM
     */
    function setTheme(theme) {
        localStorage.setItem(themeKey, theme);
        html.setAttribute('data-theme', theme);
        updateToggleIcon();
    }

    /**
     * Toggle between light and dark theme
     */
    function toggleTheme() {
        const current = html.getAttribute('data-theme') || 'light';
        const next = current === 'dark' ? 'light' : 'dark';
        setTheme(next);
    }

    /**
     * Update the toggle button icon based on current theme
     */
    function updateToggleIcon() {
        const current = html.getAttribute('data-theme') || 'light';
        if (toggleBtn) {
            // Sun icon for light mode, Moon icon for dark mode
            toggleBtn.textContent = current === 'dark' ? '☀️' : '🌙';
        }
    }

    // Initialize theme on load
    function init() {
        const theme = getTheme();
        html.setAttribute('data-theme', theme);
        updateToggleIcon();

        if (toggleBtn) {
            toggleBtn.addEventListener('click', toggleTheme);
        }
    }

    // Run initialization when DOM is ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();
