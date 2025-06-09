// Scroll back to leftmost margin if user scrolls within threshold
let lastScrollX = window.scrollX;
const initial_inner_width = window.innerWidth;
const threshold = 0.1;
// Initial client width + 10% threshold
const snapRange = initial_inner_width + (initial_inner_width * threshold);

const scroll_back_to_center = () => {
  // Target position: leftmost margin of body content
  const leftmost_margin = 0;

  // Only act if horizontal position actually changed
  if (Math.abs(window.scrollX - lastScrollX) < 1) {
    return; // No significant horizontal movement
  }

  // If user scrolls less than initial viewport width + 10%
  if (window.scrollX < snapRange) {
    window.scroll({
      left: leftmost_margin,
      // top: window.scrollY,
      behavior: "smooth",
    });
  }

  lastScrollX = window.scrollX;
};

window.addEventListener("scroll", scroll_back_to_center);
document.addEventListener("scrollend", scroll_back_to_center);
document.addEventListener("touchend", scroll_back_to_center);
