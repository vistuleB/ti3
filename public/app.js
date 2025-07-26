const WELL_100VW_MAX_WIDTH = 550;
const WELL_100VW_MINUS_PADDING_MAX_WIDTH = 700;
const MAIN_COLUMN_100VW_MAX_WIDTH = 1400;
const WIDE_SCREEN_MAIN_COLUMN_WIDTH = 1100;
const TOTAL_X_PADDING_IN_PX = 64;
const DIFF_BETWEEN_WELL_AND_MAIN_COLUMN_WHEN_WELL_IS_INSET = 100;

window.history.scrollRestoration = "manual";

const marginWidth = () => {
  return (document.body.scrollWidth - window.visualViewport.width) / 2;
};

const recenter = (behavior) => {
  window.scroll({
    left: marginWidth(),
    behavior: behavior,
  });
};

const smoothRecenter = () => {
  recenter("smooth");
};

const instantRecenter = () => {
  recenter("instant");
};

const computeMainColumnWidth = () => {
  const screenWidth = window.innerWidth;
  if (screenWidth <= MAIN_COLUMN_100VW_MAX_WIDTH) return screenWidth;
  return WIDE_SCREEN_MAIN_COLUMN_WIDTH;
};

const computeOuterWellWidth = () => {
  const screenWidth = window.innerWidth;
  if (screenWidth <= WELL_100VW_MAX_WIDTH) return screenWidth;
  if (screenWidth <= WELL_100VW_MINUS_PADDING_MAX_WIDTH) return screenWidth - TOTAL_X_PADDING_IN_PX;
  return computeMainColumnWidth() - 2 * DIFF_BETWEEN_WELL_AND_MAIN_COLUMN_WHEN_WELL_IS_INSET;
}

const setMainColumnWidth = (value) => {
    const root = document.documentElement;
    const cssValue = `${value}px`;
    root.style.setProperty('--main-column-width', cssValue);
};

const setOuterWellWidth = (value) => {
  const root = document.documentElement;
  const cssValue = `${value}px`;
  root.style.setProperty('--outer-well-width', cssValue);
};

const body = () => {
  console.log("body triggered");
  document.querySelectorAll('pre.numbered-pre').forEach(pre => {
    const lines = pre.textContent.split('\n');
    pre.innerHTML = lines
      .map((line, i) => `${i + 1}. ${line}`)
      .slice(0, -1)
      .join('\n');
  });
}

const onLoad = () => {
  handleResize();
  body();
};

const handleResize = () => {
  instantRecenter();
  setMainColumnWidth(computeMainColumnWidth());
  setOuterWellWidth(computeOuterWellWidth());
}

const smoothRecenterMaybe = (e) => {
  let theoretical_left = marginWidth();
  if (
    window.scrollX > theoretical_left - 200 &&
    window.scrollX < theoretical_left + 200
  ) {
    recenter("smooth");
  }
};

const onScrollEnd = (e) => {
  smoothRecenterMaybe();
};

const onTouchEnd = (e) => {
  smoothRecenterMaybe();
};

const onImgClick = (e) => {
  const image = e.srcElement;
  if (image.classList.contains("constrained")) {
    image.classList.remove("constrained");
  } else {
    image.classList.add("constrained");
  }
};

// chapter navigation functions
const navigateToChapter = (elementId) => {
  const element = document.getElementById(elementId);
  if (element && element.tagName === 'A' && element.href) {
    window.location.href = element.href;
  }
};

const onKeyDown = (e) => {
  // check if any input fields are focused to avoid interfering with typing
  const activeElement = document.activeElement;
  const isInputFocused = activeElement && (
    activeElement.tagName === 'INPUT' || 
    activeElement.tagName === 'TEXTAREA' || 
    activeElement.isContentEditable
  );
  
  if (isInputFocused) return;
  
  switch(e.key) {
    case 'ArrowLeft':
      e.preventDefault();
      navigateToChapter('prev-page');
      break;
    case 'ArrowRight':
      e.preventDefault();
      navigateToChapter('next-page');
      break;
  }
};

// event listeners
document.addEventListener("DOMContentLoaded", onLoad);
window.addEventListener("resize", handleResize);
document.addEventListener("click", smoothRecenter);
document.addEventListener("scrollend", onScrollEnd);
document.addEventListener("touchend", onTouchEnd);
document.addEventListener('keydown', onKeyDown);
