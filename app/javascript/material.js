import { MDCDrawer } from '@material/drawer';
import { MDCTopAppBar } from '@material/top-app-bar';
import { MDCRipple } from '@material/ripple';
import { MDCSnackbar } from '@material/snackbar';

document.addEventListener('turbo:load', () => {
  // Initialize drawer
  const drawerElement = document.querySelector('.mdc-drawer');
  const drawer = MDCDrawer.attachTo(drawerElement);

  // Initialize top app bar and its menu button
  const topAppBarElement = document.querySelector('.mdc-top-app-bar');
  const topAppBar = MDCTopAppBar.attachTo(topAppBarElement);

  // Add click handler to menu button
  document.querySelector('.mdc-top-app-bar__navigation-icon').addEventListener('click', () => {
    drawer.open = !drawer.open;
  });

  // Close drawer when clicking outside
  document.querySelector('.main-content').addEventListener('click', () => {
    if (drawer.open) {
      drawer.open = false;
    }
  });

  // Initialize ripples
  document.querySelectorAll('.mdc-button, .mdc-icon-button, .mdc-list-item').forEach((element) => {
    const ripple = new MDCRipple(element);
    if (element.classList.contains('mdc-icon-button')) {
      ripple.unbounded = true;
    }
  });

  // Initialize snackbars
  document.querySelectorAll('.mdc-snackbar').forEach((element) => {
    const snackbar = new MDCSnackbar(element);
    snackbar.timeoutMs = 5000;
    snackbar.open();
  });

  // Handle responsive behavior
  const handleResize = () => {
    if (window.innerWidth < 768) { // Mobile breakpoint
      drawer.open = false;
    }
  };

  window.addEventListener('resize', handleResize);
  handleResize(); // Initial check
}); 