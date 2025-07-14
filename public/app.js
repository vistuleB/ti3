const MOBILE_MAX_WIDTH = 900;
const MOBILE_MAIN_COLUMMN_WIDTH = '100vw';
const MOBILE_MAIN_COLUMMN_PADDING = '0 2rem';
const DESKTOP_MAIN_COLUMMN_WIDTH = 1200;
const DESKTOP_MAIN_COLUMMN_PADDING = '0 0';
const MOBILE_OUTER_WELL_WIDTH = '100vw';
const DESKTOP_OUTER_WELL_WIDTH = DESKTOP_MAIN_COLUMMN_WIDTH * 0.9;

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

const setMainColumn = () => {
    const screenWidth = window.innerWidth;
    const root = document.documentElement;

    let widthValue;
    let paddingValue;

    if (screenWidth <= MOBILE_MAX_WIDTH) {
      // mobile
      widthValue = MOBILE_MAIN_COLUMMN_WIDTH;
      paddingValue = MOBILE_MAIN_COLUMMN_PADDING;
    } else {
      // desktop
      widthValue = `${DESKTOP_MAIN_COLUMMN_WIDTH}px`;
      paddingValue = DESKTOP_OUTER_WELL_WIDTH;
    }

    root.style.setProperty('--main-column-width', widthValue);
    root.style.setProperty('--main-column-padding', paddingValue);
};

const setOuterWellWidth = () => {
    const screenWidth = window.innerWidth;
    const root = document.documentElement;

    let widthValue;

    if (screenWidth <= MOBILE_MAX_WIDTH) {
      // mobile
      widthValue = MOBILE_OUTER_WELL_WIDTH;
    } else {
      // desktop
      widthValue = `${Math.round(DESKTOP_OUTER_WELL_WIDTH)}px`;
    }

    root.style.setProperty('--outer-well-width', widthValue);
};

const onLoad = () => {
  instantRecenter();
  setMainColumn();
  setOuterWellWidth();
};

const handleResize = () => {
  instantRecenter();
  setMainColumn();
  setOuterWellWidth();
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
