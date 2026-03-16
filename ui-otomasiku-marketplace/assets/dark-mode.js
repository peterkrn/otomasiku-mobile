// Dark Mode Toggle Script
// This script handles dark mode toggle and persistence via localStorage

(function() {
  // Check for saved dark mode preference or default to false
  const isDarkMode = localStorage.getItem('darkMode') === 'true';

  // Apply dark mode if enabled
  if (isDarkMode) {
    document.documentElement.classList.add('dark');
  }

  // Toggle dark mode function
  window.toggleDarkMode = function() {
    const html = document.documentElement;
    const isCurrentlyDark = html.classList.contains('dark');

    if (isCurrentlyDark) {
      html.classList.remove('dark');
      localStorage.setItem('darkMode', 'false');
    } else {
      html.classList.add('dark');
      localStorage.setItem('darkMode', 'true');
    }

    // Update toggle button icon if it exists
    updateToggleIcon(!isCurrentlyDark);
  };

  // Update toggle button icon based on state
  function updateToggleIcon(isDark) {
    const toggleBtn = document.getElementById('darkModeToggle');
    if (toggleBtn) {
      const icon = toggleBtn.querySelector('i');
      if (icon) {
        if (isDark) {
          icon.classList.remove('fa-moon');
          icon.classList.add('fa-sun');
        } else {
          icon.classList.remove('fa-sun');
          icon.classList.add('fa-moon');
        }
      }
    }
  }

  // Initialize toggle button icon on page load
  document.addEventListener('DOMContentLoaded', function() {
    updateToggleIcon(isDarkMode);
  });
})();
