import "@hotwired/turbo-rails"
import "controllers"
import "channels"
import "bootstrap"
import "material-dashboard"
import jQuery from "jquery"
window.jQuery = jQuery
window.$ = jQuery

// Add Turbo confirmation handler
document.addEventListener("turbo:before-fetch-request", (event) => {
    if (event.detail.fetchOptions.method === "delete") {
        const confirmMessage = event.target.getAttribute("data-turbo-confirm")
        if (confirmMessage && !window.confirm(confirmMessage)) {
        event.preventDefault()
        }
    }
})

// $(document).ready(function() {
//   const loadingScreen = document.querySelector('.loading-screen');
//   const body = document.body;
//   let isLoading = true;
  
//   function hideLoadingScreen() {
//     isLoading = false;
//     loadingScreen.style.display = 'none';
//     loadingScreen.style.zIndex = '-1';
//     body.style.overflow = '';
//   }

//   function showLoadingScreen() {
//     isLoading = true;
//     loadingScreen.style.zIndex = '99999';
//     loadingScreen.style.display = 'flex';
//     body.style.overflow = 'hidden';
//   }
  
//   if (loadingScreen && isLoading) {
//     // Hide loading screen after document is ready
//     hideLoadingScreen();

//     // Handle Turbo navigation
//     document.addEventListener('turbo:before-visit', showLoadingScreen);
//     document.addEventListener('turbo:load', hideLoadingScreen);

//     // Fallback
//     setTimeout(() => {
//       if (isLoading) {
//         hideLoadingScreen();
//       }
//     }, 5000);
//   }
// });