/**************************************************
 * the different layouts are characterized by:    *
 *                                                *
 * - MOBILE: edge of text in outer wells is       *
 *   flush with edge of main column of text       *
 *                                                *
 * - TABLET: edge of outer well (the well itself) *
 *   is flush with edge of main column of text,   *
 *                                                *
 *   main column of text;                         *
 * - LAPTOP: outer well is inset compared to      *
 *   see const LAPTOP_OUTER_WELL_INSET            *
 *                                                *
 * - DESKTOP: main column of text no longer       *
 *   takes up whole screen, outer well is flush   *
 *   again; see const DESKTOP_MAIN_COLUMN_WIDTH   *
 **************************************************/

const MOBILE_MAX_WIDTH = 550;
const TABLET_MAX_WIDTH = 900;
const LAPTOP_MAX_WIDTH = 1400;

const LAPTOP_OUTER_WELL_INSET = 150;
const DESKTOP_MAIN_COLUMN_WIDTH = 1050;

const CAROUSEL_ARROW_MAX_HEIGHT = 58;
const CAROUSEL_ARROW_MIN_HEIGHT = 35;
const CAROUSEL_ARROW_MAX_HEIGHT_CONTAINER_WIDTH = 2200;
const CAROUSEL_ARROW_MIN_HEIGHT_CONTAINER_WIDTH = 490;

const root = document.documentElement;

window.history.scrollRestoration = "manual";

let lastScrollY = 0;
let lastScrollYMoment = Date.now();
let menuHidden = false;
let menuElement = null;
let isPageCentered = true;
let screenWidth = -1;

const clamp01 = (x) => {
  return Math.max(Math.min(x, 1), 0);
};

const marginWidth = () => {
  return (document.body.scrollWidth - window.visualViewport.width) / 2;
};

const recenter = (behavior) => {
  window.scroll({
    left: marginWidth(),
    behavior: behavior,
  });

  isPageCentered = true;
};

const smoothRecenter = () => {
  recenter("smooth");
};

const instantRecenter = () => {
  recenter("instant");
};

const remInPx = () => {
  if (screenWidth <= MOBILE_MAX_WIDTH) return 17;
  return 16;
};

const inhaltsArrowsDisplay = () => {
  if (screenWidth <= LAPTOP_MAX_WIDTH) return "none";
  let prevPage = document.getElementById("prev-page");
  if (prevPage.getAttribute("href") != "./index.html") return "none";
  return "inline";
};

const menuPaddingXInRem = () => {
  if (screenWidth <= LAPTOP_MAX_WIDTH) return mainColumnPaddingXInRem();
  return 1.7;
};

const menuPaddingYInRem = () => {
  if (screenWidth <= MOBILE_MAX_WIDTH) return 1.6;
  if (screenWidth <= TABLET_MAX_WIDTH) return 1.6;
  return 1.4;
};

const menuBackgroundColor = () => {
  if (screenWidth <= LAPTOP_MAX_WIDTH) return "var(--body-background-color)";
  return "#0000";
};

const menuElementGapInRem = () => {
  if (screenWidth <= MOBILE_MAX_WIDTH) return 0.7;
  if (screenWidth <= TABLET_MAX_WIDTH) return 0.7;
  return 0.55;
};

const indexHeaderTitleFontSizeInRem = () => {
  return pageTitleFontSizeInRem();
};

const indexHeaderTitleLineHeightInRem = () => {
  if (screenWidth <= MOBILE_MAX_WIDTH) return 2.2;
  if (screenWidth <= TABLET_MAX_WIDTH) return 2.5;
  return 2.8;
};

const indexHeaderSubtitleFontSizeInRem = () => {
  if (screenWidth <= MOBILE_MAX_WIDTH) return 1.35;
  if (screenWidth <= TABLET_MAX_WIDTH) return 1.45;
  return 1.5;
};

const indexHeaderPaddingTopInPx = () => {
  if (screenWidth <= MOBILE_MAX_WIDTH) return 90;
  if (screenWidth <= TABLET_MAX_WIDTH) return 100;
  return 90;
};

const indexHeaderPaddingBottomInRem = () => {
  if (screenWidth <= MOBILE_MAX_WIDTH) return 2;
  if (screenWidth <= TABLET_MAX_WIDTH) return 3;
  return 4;
};

const indexTocMaxWidthInPx = () => {
  if (screenWidth <= TABLET_MAX_WIDTH)
    return screenWidth - 2 * mainColumnPaddingXInRem() * remInPx();
  return 580;
};

const indexTocPaddingBottomInRem = () => {
  if (screenWidth <= MOBILE_MAX_WIDTH) return 1.5;
  if (screenWidth <= TABLET_MAX_WIDTH) return 2;
  return 3;
};

const indexTocChapterLevelMarginInEm = () => {
  if (screenWidth <= MOBILE_MAX_WIDTH) return 0.6;
  if (screenWidth <= TABLET_MAX_WIDTH) return 0.6;
  return 0.5;
};

const indexTocSubchapterLevelMarginInEm = () => {
  if (screenWidth <= MOBILE_MAX_WIDTH) return 0.3;
  if (screenWidth <= TABLET_MAX_WIDTH) return 0.25;
  return 0.2;
};

const carouselMaxWidthInPx = () => {
  const adjustedScreenWidth = screenWidth * 0.9;
  const computeTabletMaxWidth = Math.min(
    adjustedScreenWidth,
    DESKTOP_MAIN_COLUMN_WIDTH,
  );
  const computeDesktopMaxWidth =
    screenWidth < DESKTOP_MAIN_COLUMN_WIDTH
      ? adjustedScreenWidth
      : DESKTOP_MAIN_COLUMN_WIDTH;

  if (screenWidth <= MOBILE_MAX_WIDTH) return screenWidth;
  if (screenWidth <= TABLET_MAX_WIDTH) return computeTabletMaxWidth;
  return computeDesktopMaxWidth;
};

const endOfPageMainColumnMarginBottomInRem = () => {
  if (screenWidth <= MOBILE_MAX_WIDTH) return 1.2;
  if (screenWidth <= TABLET_MAX_WIDTH) return 1.5;
  if (screenWidth <= LAPTOP_MAX_WIDTH) return 1.8;
  return 2.4;
};

const endOfPageWellMarginBottomInRem = () => {
  if (screenWidth <= MOBILE_MAX_WIDTH) return 0.8;
  if (screenWidth <= TABLET_MAX_WIDTH) return 1.9;
  return 2.2;
};

const mainColumnWidthInPx = () => {
  if (screenWidth <= LAPTOP_MAX_WIDTH) return screenWidth;
  return DESKTOP_MAIN_COLUMN_WIDTH;
};

const mainColumnPaddingXInRem = () => {
  if (screenWidth <= MOBILE_MAX_WIDTH) return 1.5;
  if (screenWidth <= TABLET_MAX_WIDTH) return 1.8;
  return 2;
};

const mainColumnToWellMarginInRem = () => {
  if (screenWidth <= MOBILE_MAX_WIDTH) return 0.8;
  if (screenWidth <= TABLET_MAX_WIDTH) return 1.6;
  if (screenWidth <= LAPTOP_MAX_WIDTH) return 1.7;
  return 1.8;
};

const outerWellWidthInPx = () => {
  if (screenWidth <= MOBILE_MAX_WIDTH) return screenWidth - 1.5 * remInPx();
  if (screenWidth <= TABLET_MAX_WIDTH)
    return screenWidth - 2 * mainColumnPaddingXInRem() * remInPx();
  if (screenWidth <= LAPTOP_MAX_WIDTH)
    return mainColumnWidthInPx() - 2 * LAPTOP_OUTER_WELL_INSET;
  return mainColumnWidthInPx() - 2 * mainColumnPaddingXInRem() * remInPx();
};

const pageTitleFontSizeInRem = () => {
  if (screenWidth <= MOBILE_MAX_WIDTH) return 1.8;
  if (screenWidth <= TABLET_MAX_WIDTH) return 2.1;
  return 2.25;
};

const pageTitleMarginTopInRem = () => {
  if (screenWidth <= MOBILE_MAX_WIDTH) return 7;
  if (screenWidth <= TABLET_MAX_WIDTH) return 7;
  if (screenWidth <= LAPTOP_MAX_WIDTH) return 6;
  return 3.6;
};

const topicAnnouncementFontSizeInRem = () => {
  if (screenWidth <= MOBILE_MAX_WIDTH) return pageTitleFontSizeInRem() * 0.85;
  if (screenWidth <= TABLET_MAX_WIDTH) return pageTitleFontSizeInRem() * 0.82;
  return pageTitleFontSizeInRem() * 0.78;
};

const subtopicAnnouncementFontSizeInRem = () => {
  if (screenWidth <= MOBILE_MAX_WIDTH)
    return topicAnnouncementFontSizeInRem() * 0.95;
  if (screenWidth <= TABLET_MAX_WIDTH)
    return topicAnnouncementFontSizeInRem() * 0.9;
  return topicAnnouncementFontSizeInRem() * 0.85;
};

const wellMarginYInRem = () => {
  if (screenWidth <= MOBILE_MAX_WIDTH) return 0.75;
  if (screenWidth <= TABLET_MAX_WIDTH) return 1.6;
  return 2;
};

const lastChildWellMarginBottomInRem = () => {
  if (screenWidth <= MOBILE_MAX_WIDTH) return 0;
  if (screenWidth <= TABLET_MAX_WIDTH) return 0.2;
  return 0.5;
};

const wellPaddingXInRem = () => {
  if (screenWidth <= MOBILE_MAX_WIDTH) return 0.75;
  if (screenWidth <= TABLET_MAX_WIDTH) return 1.3;
  return 2;
};

const wellPaddingYInRem = () => {
  if (screenWidth <= MOBILE_MAX_WIDTH) return 0.75;
  if (screenWidth <= TABLET_MAX_WIDTH) return 1.2;
  return 1.6;
};

const ulOlMarginLeftInRem = () => {
  if (screenWidth <= MOBILE_MAX_WIDTH) return 1;
  if (screenWidth <= TABLET_MAX_WIDTH) return 1.5;
  return 2;
};

const ulOlMarginRightInRem = () => {
  if (screenWidth <= MOBILE_MAX_WIDTH) return 1;
  if (screenWidth <= TABLET_MAX_WIDTH) return 1.5;
  return 2;
};

const nestedUlOlMarginLeftInRem = () => {
  return ulOlMarginLeftInRem();
};

const nestedUlOlMarginRightInRem = () => {
  if (screenWidth <= MOBILE_MAX_WIDTH) return 0;
  if (screenWidth <= TABLET_MAX_WIDTH) return 1;
  return 2;
};

const textfigurePaddingXInRem = () => {
  if (screenWidth <= MOBILE_MAX_WIDTH) return 2.5;
  if (screenWidth <= TABLET_MAX_WIDTH) return 3;
  if (screenWidth <= LAPTOP_MAX_WIDTH) return 5;
  return 6;
};

const mathBlockMaxWidthInPx = () => {
  if (screenWidth > LAPTOP_MAX_WIDTH) return Infinity;
  return mainColumnWidthInPx();
};

const resetScreenWidthDependentVars = () => {
  let set = (key, val, unit) => {
    root.style.setProperty(key, `${val()}` + unit);
  };

  set("--rem-font-size", remInPx, "px");
  set("--inhalts-arrows-display", inhaltsArrowsDisplay, "");
  set("--menu-padding-x", menuPaddingXInRem, "rem");
  set("--menu-padding-y", menuPaddingYInRem, "rem");
  set("--menu-element-gap", menuElementGapInRem, "rem");
  set("--menu-background-color", menuBackgroundColor, "");
  set("--index-header-title-font-size", indexHeaderTitleFontSizeInRem, "rem");
  set(
    "--index-header-title-line-height",
    indexHeaderTitleLineHeightInRem,
    "rem",
  );
  set(
    "--index-header-subtitle-font-size",
    indexHeaderSubtitleFontSizeInRem,
    "rem",
  );
  set("--index-header-padding-top", indexHeaderPaddingTopInPx, "px");
  set("--index-header-padding-bottom", indexHeaderPaddingBottomInRem, "rem");
  set("--index-toc-max-width", indexTocMaxWidthInPx, "px");
  set("--index-toc-padding-bottom", indexTocPaddingBottomInRem, "rem");
  set("--index-toc-chapter-level-margin", indexTocChapterLevelMarginInEm, "em");
  set(
    "--index-toc-subchapter-level-margin",
    indexTocSubchapterLevelMarginInEm,
    "em",
  );
  set("--carousel-max-width", carouselMaxWidthInPx, "px");
  set(
    "--end-of-page-main-column-margin-bottom",
    endOfPageMainColumnMarginBottomInRem,
    "rem",
  );
  set(
    "--end-of-page-well-margin-bottom",
    endOfPageWellMarginBottomInRem,
    "rem",
  );
  set("--main-column-width", mainColumnWidthInPx, "px");
  set("--main-column-padding-x", mainColumnPaddingXInRem, "rem");
  set("--main-column-to-well-margin", mainColumnToWellMarginInRem, "rem");
  set("--outer-well-width", outerWellWidthInPx, "px");
  set("--page-title-font-size", pageTitleFontSizeInRem, "rem");
  set("--page-title-margin-top", pageTitleMarginTopInRem, "rem");
  set("--topic-announcement-font-size", topicAnnouncementFontSizeInRem, "rem");
  set(
    "--subtopic-announcement-font-size",
    subtopicAnnouncementFontSizeInRem,
    "rem",
  );
  set("--well-margin-y", wellMarginYInRem, "rem");
  set("--last-child-well-margin-bottom", lastChildWellMarginBottomInRem, "rem");
  set("--well-padding-x", wellPaddingXInRem, "rem");
  set("--well-padding-y", wellPaddingYInRem, "rem");
  set("--ul-ol-margin-left", ulOlMarginLeftInRem, "rem");
  set("--ul-ol-margin-right", ulOlMarginRightInRem, "rem");
  set("--nested-ul-ol-margin-left", nestedUlOlMarginLeftInRem, "rem");
  set("--nested-ul-ol-margin-right", nestedUlOlMarginRightInRem, "rem");
  set("--textfigure-padding-x", textfigurePaddingXInRem, "rem");
  set("--math-block-max-width", mathBlockMaxWidthInPx, "px");
};

function getClosestVisibleCarousel() {
  const y0 = window.innerHeight / 2;
  let closestDistance = Infinity;
  let closestContainer = null;
  for (const container of visibleCarouselContainers) {
    const r = container.getBoundingClientRect();
    const y = r.y + r.height / 2;
    const distance = Math.abs(y - y0);
    if (distance < closestDistance) {
      closestDistance = distance;
      closestContainer = container;
    }
  }
  return closestContainer?.carousel || null;
}

function createCarouselObserver() {
  const options = {
    root: null,
    rootMargin: "0% 0% 0% 0%",
    threshold: 0.9,
  };

  const callback = (entries, _) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        visibleCarouselContainers.add(entry.target);
      } else {
        visibleCarouselContainers.delete(entry.target);
      }
    });
  };

  return new IntersectionObserver(callback, options);
}

const adjustMathAlignment = () => {
  // we do not apply alignment, unless it is wide screen
  const screenWidth = window.innerWidth;
  if (screenWidth <= MOBILE_MAX_WIDTH) return;

  document.querySelectorAll(".math-block").forEach((math_block) => {
    const svg = math_block.querySelector("svg");
    if (!svg) {
      // this happens throughout---it seems the mjx_container
      // momentarily only contains assistive content
      return;
    }
    const minWidth = window.getComputedStyle(svg).minWidth;
    if (!minWidth || !minWidth.endsWith("px")) {
      console.log("failed to get minWidth ending with 'px':", minWidth);
      return;
    }
    const minWidthInPx = parseFloat(minWidth);
    const mathBlockWidthInPx = math_block.getBoundingClientRect().width;
    if (minWidthInPx > mathBlockWidthInPx) {
      math_block.scroll({ left: 1000 });
    }
  });
};

const constrainFigureImage = (image) => {
  image.classList.remove("unconstrained");
  image.classList.add("constrained");
  let constrainerWidth = image.constrainer.getBoundingClientRect().width;
  image.style.width = `min(${constrainerWidth + "px"}, ${image.originalWidth})`;
};

const unconstrainFigureImage = (image) => {
  image.classList.remove("constrained");
  image.classList.add("unconstrained");
  image.style.width = image.originalWidth;
};

const toggleFigureImageZoom = (image) => {
  if (image.classList.contains("constrained")) {
    unconstrainFigureImage(image);
  } else {
    constrainFigureImage(image);
  }
};

const constrainableImgClick = (e) => {
  if (!isPageCentered) return;
  const image = e.srcElement;
  const carousel = image.closest(".carousel");
  if (carousel) {
    carousel.object.toggleZoom();
    return;
  }
  toggleFigureImageZoom(image);
};

const menuVisible = () => {
  return !menuHidden;
};

const setMenuVisibility = (viz) => {
  if (!menuElement) {
    menuElement = document.getElementById("menu");
  }

  if (viz) {
    menuElement?.classList.remove("menu--hidden");
    menuHidden = false;
  } else {
    menuElement?.classList.add("menu--hidden");
    menuHidden = true;
  }
};

const onScrollMenuDisplay = (e) => {
  const currentScrollY = window.scrollY;
  const currentScrollYMoment = Date.now();
  const velocity =
    (currentScrollY - lastScrollY) / (currentScrollYMoment - lastScrollYMoment);

  if (
    (velocity < -7 ||
      currentScrollY <= 10 ||
      (velocity < 0 && currentScrollY <= 200)) &&
    !menuVisible()
  ) {
    setMenuVisibility(true);
  } else if (
    currentScrollY > lastScrollY &&
    currentScrollY > 10 &&
    menuVisible()
  ) {
    setMenuVisibility(false);
  }

  lastScrollY = currentScrollY;
  lastScrollYMoment = currentScrollYMoment;
};

const smoothRecenterMaybe = (e) => {
  let theoretical_left = marginWidth();
  if (
    window.scrollX > theoretical_left - 200 &&
    window.scrollX < theoretical_left + 200
  ) {
    recenter("smooth");
  } else {
    isPageCentered = false;
  }
};

const onMobile = (callback) => {
  if (window.innerWidth <= MOBILE_MAX_WIDTH) return callback();
  return;
};

const onTouchscreenElse = (callback1, callback2) => {
  if (window.innerWidth <= TABLET_MAX_WIDTH) return callback1();
  return callback2();
};

const visibleCarouselContainers = new Set();

const setupMenuTooltips = () => {
  for (const id of ["prev-page-tooltip", "next-page-tooltip"]) {
    let tooltip = document.getElementById(id);
    if (!tooltip) continue;
    tooltip.visibility = false;
    tooltip.touchdevice = false;
    tooltip.parentNode.addEventListener("touchstart", () => {
      tooltip.touchdevice = true;
      tooltip.style.display = "none";
    });
    tooltip.parentNode.addEventListener("mouseover", () => {
      tooltip.visibility = true;
      setTimeout(() => {
        if (tooltip.visibility === true && !tooltip.touchdevice)
          tooltip.style.visibility = "visible";
      }, 50);
    });
    tooltip.parentNode.addEventListener("mouseout", () => {
      tooltip.visibility = false;
      tooltip.style.visibility = "hidden";
    });
  }
};

const setupNextPageTooltip = () => {
  let tooltip = document.getElementById("next-page-tooltip");
  if (!tooltip) return;
  tooltip.visibility = false;
  tooltip.parentNode.addEventListener("mouseover", () => {
    tooltip.visibility = true;
    setTimeout(() => {
      if (tooltip.visibility === true) tooltip.style.visibility = "visible";
    }, 250);
  });
  tooltip.parentNode.addEventListener("mouseout", () => {
    tooltip.visibility = false;
    tooltip.style.visibility = "hidden";
  });
};

let allFigureImages = new Array();
let allConstrainableImages = new Array();

const setupImages = () => {
  let images = document.querySelectorAll("img");
  for (const image of images) {
    if (!image.closest(".carousel") && !image.closest("figure")) {
      // setting image width that appears outside figure or carousel to 100%
      // so it expands as much as the parent width
      image.style.width = "100%";
      continue;
    }
    let s = window.getComputedStyle(image);
    image.originalWidth = s.width;
    image.originalHeight = s.height;
    image.originalWidthInPx = parseFloat(image.originalWidth);
    image.originalHeightInPx = parseFloat(image.originalHeight);
    image.style.width = "";
    image.style.height = "";
    if (!image.closest(".carousel")) {
      image.classList.add("constrained");
      image.figure = image.closest("figure");
      image.constrainer = image.figure.parentNode;
      image.figcaption = image.figure.querySelector("figcaption");
      allFigureImages.push(image);
    }
    allConstrainableImages.push(image);
    window.requestAnimationFrame(() => {
      image.classList.add("zoom-transition");
      image.addEventListener("click", constrainableImgClick);
    });
  }
};

let allCarouselObjects = new Array();

class Carousel {
  constructor(container) {
    if (!container.classList.contains("carousel__container")) {
      console.error(
        "'Carousel' constructor should be called on carousel__container!",
      );
      return;
    }

    this.container = container;
    this.carousel = container.querySelector(".carousel");
    this.carouselItems = container.querySelectorAll(".carousel__item");
    this.numItems = this.carouselItems.length;
    this.itemNumber = 1;
    this.holdInterval = null;
    this.holdTimeout = null;
    this.isHolding = false;
    this.constrained = true;

    container.carousel = this;
    this.carousel.object = this;

    this.imgs = Array.from(this.carouselItems)
      .map((item) => item.querySelector("img"))
      .filter((img) => img);

    this.maxOriginalWidthInPx = 0;
    for (const img of this.imgs) {
      if (img.originalWidthInPx > this.maxOriginalWidthInPx)
        this.maxOriginalWidthInPx = img.originalWidthInPx;
    }

    this.unconstrainedUIPrevBtn = (() => {
      const btn = document.createElement("button");
      btn.className = "carousel__nav-button carousel__nav-item--prev";
      btn.innerHTML = '<img src="./img/carousel-prev-icon.svg" alt="Previous">';
      btn.setAttribute("aria-label", "Previous slide");
      return btn;
    })();

    this.unconstrainedUINextBtn = (() => {
      const btn = document.createElement("button");
      btn.className = "carousel__nav-button carousel__nav-item--next";
      btn.innerHTML = '<img src="./img/carousel-next-icon.svg" alt="Next">';
      btn.setAttribute("aria-label", "Next slide");
      return btn;
    })();

    this.constrainedUIFstBtn = (() => {
      const btn = document.createElement("button");
      btn.className = "carousel__nav-button carousel__nav-item--first";
      btn.innerHTML =
        '<img src="./img/carousel-jump-to-start.svg" alt="First">';
      btn.setAttribute("aria-label", "First slide");
      btn.addEventListener("click", () => {
        this.setItemNumber(1);
      });
      return btn;
    })();

    this.constrainedUILstBtn = (() => {
      const btn = document.createElement("button");
      btn.className = "carousel__nav-button carousel__nav-item--last";
      btn.innerHTML = '<img src="./img/carousel-jump-to-end.svg" alt="Last">';
      btn.setAttribute("aria-label", "Last slide");
      btn.addEventListener("click", () => {
        this.setItemNumber(this.numItems);
      });
      return btn;
    })();

    this.constrainedUIPrevBtn = this.unconstrainedUIPrevBtn.cloneNode(true);
    this.constrainedUINextBtn = this.unconstrainedUINextBtn.cloneNode(true);

    this.doOnClickAndOnHold(this.constrainedUIPrevBtn, () => {
      this.nudgeCarouselItem(-1);
    });

    this.doOnClickAndOnHold(this.constrainedUINextBtn, () => {
      this.nudgeCarouselItem(1);
    });

    this.doOnClickAndOnHold(this.unconstrainedUIPrevBtn, () => {
      this.nudgeCarouselItem(-1);
    });

    this.doOnClickAndOnHold(this.unconstrainedUINextBtn, () => {
      this.nudgeCarouselItem(1);
    });

    this.indexCounter = (() => {
      const indexCounter = document.createElement("span");
      indexCounter.textContent = `${this.itemNumber}`;
      return indexCounter;
    })();

    this.progressCounter = (() => {
      const progressCounter = document.createElement("div");
      progressCounter.className = "carousel__constrained-progress-counter";

      const slash = (() => {
        const slash = document.createElement("span");
        slash.textContent = "/";
        return slash;
      })();

      const totalSlides = (() => {
        const totalSlides = document.createElement("span");
        totalSlides.textContent = `${this.numItems}`;
        return totalSlides;
      })();

      progressCounter.appendChild(this.indexCounter);
      progressCounter.appendChild(slash);
      progressCounter.appendChild(totalSlides);

      return progressCounter;
    })();

    this.constrainedNav = (() => {
      const constrainedNav = document.createElement("div");

      constrainedNav.className = "carousel__constrained-nav";
      constrainedNav.appendChild(this.constrainedUIFstBtn);
      constrainedNav.appendChild(this.constrainedUIPrevBtn);
      constrainedNav.appendChild(this.progressCounter);
      constrainedNav.appendChild(this.constrainedUINextBtn);
      constrainedNav.appendChild(this.constrainedUILstBtn);

      return constrainedNav;
    })();

    [this.indicators, this.indicator_dots] = (() => {
      const indicators = document.createElement("div");
      indicators.className = "carousel__indicators";
      const indicator_dots = new Array();
      for (let i = 1; i <= this.numItems; i++) {
        const indicator = document.createElement("button");
        indicator.className = "carousel__indicator_box";
        indicator.setAttribute("aria-label", `Go to slide ${i}`);
        indicator.addEventListener("click", () => this.setItemNumber(i));
        const circle = document.createElement("div");
        circle.className = "carousel__indicator_dot";
        indicator.appendChild(circle);
        indicators.appendChild(indicator);
        indicator_dots.push(circle);
      }
      return [indicators, indicator_dots];
    })();

    this.setItemNumber(1);
  }

  appendToContainer(thing) {
    if (!this.container.contains(thing)) {
      this.container.appendChild(thing);
    }
  }

  removeFromContainer(thing) {
    if (this.container.contains(thing)) {
      this.container.removeChild(thing);
    }
  }

  appendToCarousel(thing) {
    if (!this.carousel.contains(thing)) {
      this.carousel.appendChild(thing);
    }
  }

  prependToCarousel(thing) {
    if (!this.carousel.contains(thing)) {
      this.carousel.prepend(thing);
    }
  }

  removeFromCarousel(thing) {
    if (this.carousel.contains(thing)) {
      this.carousel.removeChild(thing);
    }
  }

  attachUnconstrainedNav() {
    this.prependToCarousel(this.unconstrainedUIPrevBtn);
    this.appendToCarousel(this.unconstrainedUINextBtn);
    this.appendToContainer(this.indicators);
  }

  removeUnconstrainedNav() {
    this.removeFromCarousel(this.unconstrainedUIPrevBtn);
    this.removeFromCarousel(this.unconstrainedUINextBtn);
    this.removeFromContainer(this.indicators);
  }

  attachConstrainedNav() {
    this.appendToContainer(this.constrainedNav);
  }

  removeConstrainedNav() {
    this.removeFromContainer(this.constrainedNav);
  }

  suggestedButtonHeightForOwnContainerSize = () => {
    let lambda = clamp01(
      (this.containerWidth - CAROUSEL_ARROW_MIN_HEIGHT_CONTAINER_WIDTH) /
        (CAROUSEL_ARROW_MAX_HEIGHT_CONTAINER_WIDTH -
          CAROUSEL_ARROW_MIN_HEIGHT_CONTAINER_WIDTH),
    );

    return (
      CAROUSEL_ARROW_MIN_HEIGHT * (1 - lambda) +
      CAROUSEL_ARROW_MAX_HEIGHT * lambda
    );
  };

  onScreenWidthChangePhase1() {
    this.containerWidth = this.container.getBoundingClientRect().width;
    return this.suggestedButtonHeightForOwnContainerSize();
  }

  phase2ResetUnconstrainedUIButtonStyles = () => {
    let height = this.buttonHeightInPx + "px";
    this.unconstrainedUIPrevBtn.style.height = height;
    this.unconstrainedUINextBtn.style.height = height;

    let margin = this.buttonMarginInPx + "px";
    this.unconstrainedUIPrevBtn.style.margin = "0 " + margin;
    this.unconstrainedUINextBtn.style.margin = "0 " + margin;
    this.unconstrainedUIPrevBtn.style.margin = "0 " + margin;
    this.unconstrainedUINextBtn.style.margin = "0 " + margin;
  };

  phase2ResetConstrainedUIButtonStyles = () => {
    let height = this.buttonHeightInPx + "px";
    this.constrainedUIPrevBtn.style.height = height;
    this.constrainedUINextBtn.style.height = height;
    this.constrainedUIFstBtn.style.height = height;
    this.constrainedUILstBtn.style.height = height;

    let margin = this.buttonMarginInPx + "px";
    this.constrainedUIPrevBtn.style.margin = "0 " + margin;
    this.constrainedUINextBtn.style.margin = "0 " + margin;
    this.constrainedUIFstBtn.style.margin = "0 " + margin;
    this.constrainedUILstBtn.style.margin = "0 " + margin;
  };

  onScreenWidthChangePhase2(imposedButtonHeight) {
    this.buttonHeightInPx = imposedButtonHeight;
    this.buttonWidthInPx = (this.buttonHeightInPx * 18) / 34;
    this.buttonMarginInPx = imposedButtonHeight * 0.7;

    let unconstrainedUIWidth =
      this.maxOriginalWidthInPx +
      2 * this.buttonWidthInPx +
      4 * this.buttonMarginInPx;

    if (this.containerWidth >= unconstrainedUIWidth) {
      this.bigEnoughContainerForUnconstrainedUI = true;
      this.removeConstrainedNav();
      this.attachUnconstrainedNav();
      this.phase2ResetUnconstrainedUIButtonStyles();
    } else {
      this.bigEnoughContainerForUnconstrainedUI = false;
      this.removeUnconstrainedNav();
      this.attachConstrainedNav();
      this.phase2ResetConstrainedUIButtonStyles();
    }

    this.updateConstrained();
  }

  updateIndexCounter() {
    this.indexCounter.textContent = `${this.itemNumber}`;
  }

  updateItemsDisplayValue() {
    this.carouselItems.forEach((item, index) => {
      item.style.display = index + 1 === this.itemNumber ? "flex" : "none";
    });
  }

  ourConstrainImage = (image) => {
    image.classList.remove("unconstrained");
    image.classList.add("constrained");
    image.style.width = `min(${this.containerWidth + "px"}, ${
      image.originalWidth
    })`;
  };

  ourUnconstrainImage = (image) => {
    image.classList.remove("constrained");
    image.classList.add("unconstrained");
    image.style.width = image.originalWidth;
  };

  updateConstrained() {
    if (this.bigEnoughContainerForUnconstrainedUI === undefined) {
      console.warn("carousel.updateConstrained called before onResize (?)");
    }

    if (!this.bigEnoughContainerForUnconstrainedUI && this.constrained) {
      this.imgs.forEach(this.ourConstrainImage);
    } else {
      this.imgs.forEach(this.ourUnconstrainImage);
    }
  }

  toggleZoom() {
    this.constrained = !this.constrained;
    this.updateConstrained();
  }

  updateIndicators() {
    this.indicator_dots.forEach((indicator, index) => {
      indicator.classList.toggle("active", index + 1 === this.itemNumber);
    });
  }

  setItemNumber(itemNumber) {
    if (itemNumber < 1 || itemNumber > this.numItems) {
      console.error("bad item number:", itemNumber);
      return;
    }
    this.itemNumber = itemNumber;
    this.updateItemsDisplayValue();
    this.updateIndexCounter();
    this.updateIndicators();
  }

  nudgeCarouselItem(direction) {
    // console.log("in nudge!", direction);
    this.setItemNumber(
      1 + ((this.numItems + this.itemNumber + direction - 1) % this.numItems),
    );
  }

  doOnClickAndOnHold(button, callback) {
    const startHold = (e) => {
      e.preventDefault();
      if (this.isHolding) return;
      this.isHolding = true;
      callback();
      this.holdTimeout = setTimeout(() => {
        this.holdInterval = setInterval(() => {
          callback();
        }, 200);
      }, 400);
    };

    const stopHold = (e) => {
      e.preventDefault();
      this.isHolding = false;
      if (this.holdTimeout) {
        clearTimeout(this.holdTimeout);
        this.holdTimeout = null;
      }
      if (this.holdInterval) {
        clearInterval(this.holdInterval);
        this.holdInterval = null;
      }
    };

    button.addEventListener("mousedown", startHold);
    button.addEventListener("touchstart", startHold, { passive: false });
    button.addEventListener("mouseup", stopHold);
    button.addEventListener("mouseleave", stopHold);
    button.addEventListener("touchend", stopHold, { passive: false });
    button.addEventListener("touchcancel", stopHold);
  }
}

const setupCarousels = () => {
  let carouselObserver = createCarouselObserver();
  const carousels = document.querySelectorAll(".carousel__container");
  carousels.forEach((container) => {
    carouselObserver.observe(container);
    let c = new Carousel(container);
    allCarouselObjects.push(c);
  });
};

const setPageTitleGridColumns = () => {
  const onMobile = window.innerWidth <= MOBILE_MAX_WIDTH;

  const pageTitle = document.querySelector(".page-title");
  if (!pageTitle) return;

  if (onMobile) {
    pageTitle.style.setProperty("grid-template-columns", "1fr");
    pageTitle.classList.toggle("no-borders", onMobile);
    return;
  }

  const minWidth = getComputedStyle(root)
    .getPropertyValue("--page-title-border-min-width")
    .trim();

  pageTitle.style.setProperty(
    "grid-template-columns",
    `minmax(${minWidth}, 1fr) auto minmax(${minWidth}, 1fr)`,
  );
  pageTitle.classList.toggle("no-borders", onMobile);
};

const onLoad = () => {
  setupImages();
  setupCarousels();
  onResize();
  setMenuVisibility(true);
  setupMenuTooltips();
};

const onResize = () => {
  if (window.innerWidth == screenWidth) return;
  screenWidth = window.innerWidth;
  instantRecenter();
  resetScreenWidthDependentVars();
  setTimeout(adjustMathAlignment, 60);
  for (const image of allConstrainableImages) {
    image.classList.remove("zoom-transition");
  }
  figureImagesOnResize();
  carouselImagesOnResize();
  window.requestAnimationFrame(() => {
    for (const image of allConstrainableImages) {
      image.classList.add("zoom-transition");
    }
  });
  setPageTitleGridColumns();
};

const figureImagesOnResize = () => {
  for (const image of allFigureImages) {
    if (image.classList.contains("constrained")) constrainFigureImage(image);
  }
};

const carouselImagesOnResize = () => {
  if (allCarouselObjects.length === 0) return;
  let totalButtonHeights = 0;
  for (const carousel of allCarouselObjects) {
    totalButtonHeights += carousel.onScreenWidthChangePhase1();
  }
  const avgButtonHeight = totalButtonHeights / allCarouselObjects.length;
  for (const carousel of allCarouselObjects) {
    carousel.onScreenWidthChangePhase2(avgButtonHeight);
  }
};

const onScrollEnd = (e) => {
  smoothRecenterMaybe();
  setTimeout(adjustMathAlignment, 60);
};

const onTouchEnd = (e) => {
  smoothRecenterMaybe();
  setTimeout(adjustMathAlignment, 60);
};

// chapter navigation functions
const navigateToChapter = (elementId) => {
  const element = document.getElementById(elementId);
  if (element && element.tagName === "A" && element.href) {
    window.location.href = element.href;
  }
};

const onKeyDown = (e) => {
  // prevent default browser behavior for Option/Alt + Arrow combinations first
  if (e.altKey && (e.key === "ArrowLeft" || e.key === "ArrowRight")) {
    e.preventDefault();
    e.stopPropagation();
  }

  // check if any input fields are focused to avoid interfering with typing
  const activeElement = document.activeElement;
  const isInputFocused =
    activeElement &&
    (activeElement.tagName === "INPUT" ||
      activeElement.tagName === "TEXTAREA" ||
      activeElement.isContentEditable);

  if (isInputFocused) return;

  // check for Option+Arrow (Mac) or Alt+Arrow (Windows) for direct page navigation
  if (e.altKey && (e.key === "ArrowLeft" || e.key === "ArrowRight")) {
    switch (e.key) {
      case "ArrowLeft":
        navigateToChapter("prev-page");
        break;
      case "ArrowRight":
        navigateToChapter("next-page");
        break;
    }
    return;
  }

  switch (e.key) {
    case "ArrowLeft":
      e.preventDefault();
      var carousel = getClosestVisibleCarousel();
      if (carousel != null) {
        carousel.nudgeCarouselItem(-1);
      } else {
        navigateToChapter("prev-page");
      }
      break;
    case "ArrowRight":
      e.preventDefault();
      var carousel = getClosestVisibleCarousel();
      if (carousel != null) {
        carousel.nudgeCarouselItem(1);
      } else {
        navigateToChapter("next-page");
      }
      break;
    case "0":
      window.location.href = "index.html";
      break;
  }
};

window.addEventListener("resize", onResize);
document.addEventListener("DOMContentLoaded", onLoad);
document.addEventListener("click", smoothRecenter);
document.addEventListener("scroll", onScrollMenuDisplay, { passive: true });
document.addEventListener("scrollend", onScrollEnd);
document.addEventListener("touchend", onTouchEnd, { passive: true });
document.addEventListener("keydown", onKeyDown, { capture: true });
