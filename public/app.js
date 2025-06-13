const initialViewportWidth = window.innerWidth;

const getPageLeft = () => window.visualViewport.pageLeft;

// Assuming the body content is larger than vw (viewwidth), we scroll to the center of the content.
// center is calculated by subracting innerWidfth from scrollWidth and whatever remains
// is the accumulated spaces (equal measure) on both sides. Divice by two to get empty space
// on one side.

const snapToCenter = () => {
  const scrollLeft = (document.body.scrollWidth - window.innerWidth) / 2;
  window.scrollTo({
    left: scrollLeft,
    top: window.scrollY,
    behavior: "smooth",
  });
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
  const scrollLeft = (document.body.scrollWidth - window.innerWidth) / 2;
  window.scrollTo({
    left: scrollLeft,
    top: window.scrollY,
    behavior: "instant",
  });

  // registering click on document that includes empty spaces
  // mandatory false to prevent bubble phase capturing
  document.addEventListener("click", (_) => snapToCenter(), false);
};

document.addEventListener("DOMContentLoaded", onLoad);
