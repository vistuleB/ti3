const initialViewportWidth = window.innerWidth;

const getPageLeft = () => window.visualViewport.pageLeft;

// Assuming the **entire** body content starts from leftmost margin where left is 0,
// snap the viewport to leftmost margin
const snapToLeftmostMargin = () => window.scrollTo({ left: 0, behavior: 'smooth' });

const scrollToLeftmostMargin = () => {
  // If page is scrolled by less than 8% (100-92) of viewport, scroll back to left = 0
  const threshold = initialViewportWidth - initialViewportWidth * 0.92;
  if (getPageLeft() < threshold) {
    window.scrollTo({ left: 0, behavior: 'smooth' });
    //snapToLeftmostMargin();
  }
}

const setupScrollEndHandler = (callback) => {
    if ('onscrollend' in window) {
        // Modern browsers with scrollend support
        window.addEventListener('scrollend', callback);
    } else {
        // Safari and older browsers fallback
        let scrollTimer;
        window.addEventListener('scroll', function() {
            clearTimeout(scrollTimer);
            scrollTimer = setTimeout(callback, 120);
            // passive: true mandatory for smooth scroll on Safari (iOS)
        }, { passive: true });
    }
}

const testOnClick = () => {
  console.log("I have been clicked!");
}

setupScrollEndHandler(scrollToLeftmostMargin);

// const onLoad = () => {
//   document.body.addEventListener("click", (_) => testOnClick());
// }

// document.addEventListener("DOMContentLoaded", onLoad);
