/**
 * Code Copy Button
 * 
 * Adds a copy button to all code blocks.
 */

(function () {
    /**
     * Create a copy button element
     */
    function createCopyButton() {
        const button = document.createElement('button');
        button.className = 'code-copy-btn';
        button.innerHTML = '📋 Copy';
        button.type = 'button';
        button.ariaLabel = 'Copy code';
        return button;
    }

    /**
     * Get text content from a code block
     */
    function getCodeContent(codeEl) {
        return codeEl.textContent || codeEl.innerText;
    }

    /**
     * Copy text to clipboard and show feedback
     */
    async function copyToClipboard(text, button) {
        try {
            await navigator.clipboard.writeText(text);

            // Show feedback
            const originalText = button.innerHTML;
            button.innerHTML = '✓ Copied!';
            button.classList.add('copied');

            setTimeout(() => {
                button.innerHTML = originalText;
                button.classList.remove('copied');
            }, 2000);
        } catch (err) {
            console.error('Failed to copy:', err);
            button.innerHTML = '✗ Failed';
            setTimeout(() => {
                button.innerHTML = '📋 Copy';
            }, 2000);
        }
    }

    /**
     * Initialize code copy buttons
     */
    function init() {
        // Find all pre > code blocks
        const codeBlocks = document.querySelectorAll('pre > code');

        codeBlocks.forEach((codeEl) => {
            const preEl = codeEl.parentElement;

            // Skip if button already exists
            if (preEl.querySelector('.code-copy-btn')) return;

            // Create wrapper for positioning
            if (!preEl.style.position) {
                preEl.style.position = 'relative';
            }

            // Create and attach copy button
            const button = createCopyButton();
            button.addEventListener('click', () => {
                const text = getCodeContent(codeEl);
                copyToClipboard(text, button);
            });

            preEl.appendChild(button);
        });
    }

    // Initialize when DOM is ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }

    // Also watch for dynamically added code blocks
    const observer = new MutationObserver(init);
    observer.observe(document.body, {
        childList: true,
        subtree: true
    });
})();
