const initialViewportWidth = window.innerWidth;

const getPageLeft = () => window.visualViewport.pageLeft;

// Assuming the body content has `min-width: calc(500px + 100vw)` **set**, we scroll to
// half of 500 i.e. 500/2 = 250 to the left
// If you change hardcoded 500px in css, the new half should reflect here.
const snapToCenter = () => {
  window.scrollTo({ left: 250, behavior: "smooth" });
};

const scrollToCenter = () => {
  // `if` clause below provide enbales the page to scroll back to center
  // if the page is scrolled up to certain extent.
  // The **extent** is calculated by taking scrollable width excluding viewport and
  // diving by two that represents equal empty space on both sides of the `body` content
  const emptySpace = (document.body.scrollWidth - initialViewportWidth) / 2;
  // threshold is 60% of the empty space
  const threshold = emptySpace * 0.6;
  if (
    getPageLeft() > emptySpace - threshold &&
    getPageLeft() < emptySpace + threshold
  )
    snapToCenter();
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

setupScrollEndHandler(scrollToCenter);

const onLoad = () => {
  // mandatory false to prevent bubble phase capturing
  snapToCenter();

  // registering click on document that includes empty spaces
  document.addEventListener("click", (_) => snapToCenter(), false);
};

document.addEventListener("DOMContentLoaded", onLoad);
