const initialViewportWidth = window.innerWidth;

const getPageLeft = () => window.visualViewport.pageLeft;

// Assuming the **entire** body content starts from leftmost margin where left is 0,
// snap the viewport to leftmost margin
const snapToLeftmostMargin = () =>
  window.scrollTo({ left: 0, behavior: "smooth" });

const scrollToLeftmostMargin = () => {
  // If page is scrolled by less than 14% (100-86) of viewport, scroll back to left = 0
  const threshold = initialViewportWidth - initialViewportWidth * 0.86;
  if (getPageLeft() < threshold) snapToLeftmostMargin();
};

const setupScrollEndHandler = (callback) => {
  if ("onscrollend" in window) {
    // Modern browsers with scrollend support
    window.addEventListener("scrollend", callback);
  } else {
    // Safari and older browsers fallback
    let scrollTimer;
    window.addEventListener(
      "scroll",
      function () {
        clearTimeout(scrollTimer);
        scrollTimer = setTimeout(callback, 120);
        // passive: true mandatory for smooth scroll on Safari (iOS)
      },
      { passive: true },
    );
  }
};

setupScrollEndHandler(scrollToLeftmostMargin);

const onLoad = () => {
  // registering click on document including empty spaces
  // mandatory false to prevent bubble phase capturing
  document.addEventListener("click", (_) => snapToLeftmostMargin(), false);
};

document.addEventListener("DOMContentLoaded", onLoad);
