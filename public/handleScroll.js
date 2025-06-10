const initialViewportWidth = window.innerWidth;

const getPageLeft = () => window.visualViewport.pageLeft;

const scrollToCenter = () => {
  // If page is scrolled by less than 8% (100-92) of viewport, scroll back to left = 0
  const threshold = initialViewportWidth - initialViewportWidth * 0.92;
  if(getPageLeft() < threshold) {
    window.scrollTo({ left: 0, behavior: 'smooth' });
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

setupScrollEndHandler(scrollToCenter);
