const MOBILE_MAX_WIDTH = 900;
const MOBILE_MAIN_COLUMMN_WIDTH = '100vw';
const MOBILE_MAIN_COLUMMN_PADDING = '0 2rem';
const DESKTOP_MAIN_COLUMMN_WIDTH = 1200;
const DESKTOP_MAIN_COLUMMN_PADDING = '0 0';

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
  
  let widthValue;
  
  if (screenWidth <= MOBILE_MAX_WIDTH) {
    // mobile
    widthValue = MOBILE_MAIN_COLUMMN_WIDTH;
  } else {
    // desktop
    widthValue = DESKTOP_MAIN_COLUMMN_WIDTH;
  }
  return widthValue;
};

const computeOuterWellWidth = () => {
  const screenWidth = window.innerWidth;

  let widthValue;

  if (screenWidth <= MOBILE_MAX_WIDTH) {
    // mobile
    widthValue = window.innerWidth;
  } else {
    // desktop
    widthValue = Math.round(DESKTOP_MAIN_COLUMMN_WIDTH * 0.9);
  }
  
  return widthValue;
}

const setMainColumnWidth = (value) => {
    const root = document.documentElement;
    const cssValue = typeof value === "number" ? `${value}px` : value;
    root.style.setProperty('--main-column-width', cssValue);
};

const setOuterWellWidth = (value) => {
  const root = document.documentElement;
  const cssValue = typeof value === "number" ? `${value}px` : value;
  root.style.setProperty('--outer-well-width', cssValue);
};

const onLoad = () => {
  handleResize();
};

const handleResize = () => {
  console.log("Handle Resize");
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

document.addEventListener("DOMContentLoaded", onLoad);
window.addEventListener("resize", handleResize);
document.addEventListener("click", smoothRecenter);
document.addEventListener("scrollend", onScrollEnd);
document.addEventListener("touchend", onTouchEnd);

const onImgClick = (e) => {
  const image = e.srcElement;
  if (image.classList.contains("constrained")) {
    image.classList.remove("constrained");
  } else {
    image.classList.add("constrained");
  }
};
