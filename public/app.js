/**************************************************
 * the different layouts are characterized by:    *
 *                                                *
 * - MOBILE: edge of text in outer wells is       *
 *   flush with edge of main column of text       *
 *                                                *
 * - TABLET: edge of outer well (the well itself) *
 *   is flush with edge of main column of text,   *
 *                                                *
 * - LAPTOP: outer well is inset compared to      *
 *   main column of text;                         *
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

const CAROUSEL_ARROW_DESKTOP_SIZE = 48;
const CAROUSEL_ARROW_LAPTOP_SIZE = 45;
const CAROUSEL_ARROW_TABLET_MAX_SIZE = 40;
const CAROUSEL_ARROW_MIN_SIZE = 28;

const root = document.documentElement;
const remToPx = 16;

window.history.scrollRestoration = "manual";

let lastScrollY = 0;
let lastScrollYMoment = Date.now();
let menuHidden = false;
let menuElement = null;
let isPageCentered = true;

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

const resetScreenWidthDependentVars = () => {
  const screenWidth = window.innerWidth;

  let set = (key, val, unit) => {
    root.style.setProperty(key, `${val()}` + unit);
  };

  let inhaltsArrowsDisplay = () => {
    if (screenWidth <= LAPTOP_MAX_WIDTH) return "none";
    return "inline";
  };

  let menuPaddingXInRem = () => {
    if (screenWidth <= LAPTOP_MAX_WIDTH) return mainColumnPaddingXInRem();
    return 1.7;
  };

  let menuPaddingYInRem = () => {
    if (screenWidth <= MOBILE_MAX_WIDTH) return 1.6;
    if (screenWidth <= TABLET_MAX_WIDTH) return 1.6;
    return 1.4;
  };

  let menuBackgroundColor = () => {
    if (screenWidth <= LAPTOP_MAX_WIDTH) return "var(--body-background-color)";
    return "#0000";
  };

  let menuElementGapInRem = () => {
    if (screenWidth <= MOBILE_MAX_WIDTH) return 0.7;
    if (screenWidth <= TABLET_MAX_WIDTH) return 0.7;
    return 0.55;
  };

  let indexHeaderTitleFontSizeInRem = () => {
    return pageTitleFontSizeInRem();
  };

  let indexHeaderTitleLineHeightInRem = () => {
    if (screenWidth <= MOBILE_MAX_WIDTH) return 2.2;
    if (screenWidth <= TABLET_MAX_WIDTH) return 2.5;
    return 2.8;
  };

  let indexHeaderSubtitleFontSizeInRem = () => {
    if (screenWidth <= MOBILE_MAX_WIDTH) return 1.35;
    if (screenWidth <= TABLET_MAX_WIDTH) return 1.45;
    return 1.5;
  };

  let indexHeaderPaddingTopInPx = () => {
    if (screenWidth <= MOBILE_MAX_WIDTH) return 90;
    if (screenWidth <= TABLET_MAX_WIDTH) return 100;
    return 90;
  };

  let indexHeaderPaddingBottomInRem = () => {
    if (screenWidth <= MOBILE_MAX_WIDTH) return 2;
    if (screenWidth <= TABLET_MAX_WIDTH) return 3;
    return 4;
  };

  let indexTocMaxWidthInPx = () => {
    if (screenWidth <= TABLET_MAX_WIDTH)
      return screenWidth - 2 * mainColumnPaddingXInRem() * remToPx;
    return 580;
  };

  let indexTocPaddingBottomInRem = () => {
    if (screenWidth <= MOBILE_MAX_WIDTH) return 1.5;
    if (screenWidth <= TABLET_MAX_WIDTH) return 2;
    return 3;
  };

  let indexTocChapterLevelMarginInEm = () => {
    if (screenWidth <= MOBILE_MAX_WIDTH) return 0.6;
    if (screenWidth <= TABLET_MAX_WIDTH) return 0.6;
    return 0.5;
  };

  let indexTocSubchapterLevelMarginInEm = () => {
    if (screenWidth <= MOBILE_MAX_WIDTH) return 0.25;
    if (screenWidth <= TABLET_MAX_WIDTH) return 0.2;
    return 0.15;
  };

  const carouselMaxWidthInPx = () => {
    const adjustedScreenWidth = screenWidth * 0.9;
    const computeTabletMaxWidth = Math.min(
      adjustedScreenWidth,
      DESKTOP_MAIN_COLUMN_WIDTH
    );
    const computeDesktopMaxWidth =
      screenWidth < DESKTOP_MAIN_COLUMN_WIDTH
        ? adjustedScreenWidth
        : DESKTOP_MAIN_COLUMN_WIDTH;

    if (screenWidth <= MOBILE_MAX_WIDTH) return screenWidth;
    if (screenWidth <= TABLET_MAX_WIDTH) return computeTabletMaxWidth;
    return computeDesktopMaxWidth;
  };

  const carouselArrowSizeInPx = () => {
    if (screenWidth > LAPTOP_MAX_WIDTH) return CAROUSEL_ARROW_DESKTOP_SIZE;
    if (screenWidth > TABLET_MAX_WIDTH) return CAROUSEL_ARROW_LAPTOP_SIZE;
    let minSizeWidth = 490; // the width at which arrow reaches min width
    return (
      CAROUSEL_ARROW_MIN_SIZE +
      ((CAROUSEL_ARROW_TABLET_MAX_SIZE - CAROUSEL_ARROW_MIN_SIZE) *
        Math.max(0, screenWidth - minSizeWidth)) /
        (TABLET_MAX_WIDTH - minSizeWidth)
    );
  };

  const carouselNavButtonMarginXInPx = () => {
    if (screenWidth <= MOBILE_MAX_WIDTH) return 0;
    if (screenWidth <= TABLET_MAX_WIDTH) return carouselArrowSizeInPx() * 0.7;
    if (screenWidth <= LAPTOP_MAX_WIDTH) return carouselArrowSizeInPx() * 0.4;
    return carouselArrowSizeInPx();
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

  let mainColumnWidthInPx = () => {
    if (screenWidth <= LAPTOP_MAX_WIDTH) return screenWidth;
    return DESKTOP_MAIN_COLUMN_WIDTH;
  };

  let mainColumnPaddingXInRem = () => {
    if (screenWidth <= MOBILE_MAX_WIDTH) return 1.5;
    if (screenWidth <= TABLET_MAX_WIDTH) return 1.8;
    return 2;
  };

  let mainColumnToWellMarginInRem = () => {
    if (screenWidth <= MOBILE_MAX_WIDTH) return 0.8;
    if (screenWidth <= TABLET_MAX_WIDTH) return 1.6;
    if (screenWidth <= LAPTOP_MAX_WIDTH) return 1.7;
    return 1.8;
  };

  let outerWellWidthInPx = () => {
    if (screenWidth <= MOBILE_MAX_WIDTH) return screenWidth - 1.5 * remToPx;
    if (screenWidth <= TABLET_MAX_WIDTH)
      return screenWidth - 2 * mainColumnPaddingXInRem() * remToPx;
    if (screenWidth <= LAPTOP_MAX_WIDTH)
      return mainColumnWidthInPx() - 2 * LAPTOP_OUTER_WELL_INSET;
    return mainColumnWidthInPx() - 2 * mainColumnPaddingXInRem() * remToPx;
  };

  let pageTitleFontSizeInRem = () => {
    if (screenWidth <= MOBILE_MAX_WIDTH) return 1.8;
    if (screenWidth <= TABLET_MAX_WIDTH) return 2.1;
    return 2.25;
  };

  let pageTitleMarginTopInRem = () => {
    if (screenWidth <= MOBILE_MAX_WIDTH) return 7;
    if (screenWidth <= TABLET_MAX_WIDTH) return 7;
    if (screenWidth <= LAPTOP_MAX_WIDTH) return 6;
    return 3.6;
  };

  let topicAnnouncementFontSizeInRem = () => {
    if (screenWidth <= MOBILE_MAX_WIDTH) return pageTitleFontSizeInRem() * 0.85;
    if (screenWidth <= TABLET_MAX_WIDTH) return pageTitleFontSizeInRem() * 0.82;
    return pageTitleFontSizeInRem() * 0.78;
  };

  let subtopicAnnouncementFontSizeInRem = () => {
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

  set("--inhalts-arrows-display", inhaltsArrowsDisplay, "");
  set("--menu-padding-x", menuPaddingXInRem, "rem");
  set("--menu-padding-y", menuPaddingYInRem, "rem");
  set("--menu-element-gap", menuElementGapInRem, "rem");
  set("--menu-background-color", menuBackgroundColor, "");
  set("--index-header-title-font-size", indexHeaderTitleFontSizeInRem, "rem");
  set(
    "--index-header-title-line-height",
    indexHeaderTitleLineHeightInRem,
    "rem"
  );
  set(
    "--index-header-subtitle-font-size",
    indexHeaderSubtitleFontSizeInRem,
    "rem"
  );
  set("--index-header-padding-top", indexHeaderPaddingTopInPx, "px");
  set("--index-header-padding-bottom", indexHeaderPaddingBottomInRem, "rem");
  set("--index-toc-max-width", indexTocMaxWidthInPx, "px");
  set("--index-toc-padding-bottom", indexTocPaddingBottomInRem, "rem");
  set("--index-toc-chapter-level-margin", indexTocChapterLevelMarginInEm, "em");
  set(
    "--index-toc-subchapter-level-margin",
    indexTocSubchapterLevelMarginInEm,
    "em"
  );
  set("--carousel-max-width", carouselMaxWidthInPx, "px");
  set("--carousel-arrow-size", carouselArrowSizeInPx, "px");
  set("--carousel-nav-button-margin-x", carouselNavButtonMarginXInPx, "px");
  set(
    "--end-of-page-main-column-margin-bottom",
    endOfPageMainColumnMarginBottomInRem,
    "rem"
  );
  set(
    "--end-of-page-well-margin-bottom",
    endOfPageWellMarginBottomInRem,
    "rem"
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
    "rem"
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

const setImgHeightToAuto = () => {
  const images = document.querySelectorAll(
    "figure.main-column img, .well figure img"
  );

  images.forEach((img) => {
    if (img.style.height) {
      img.style.height = "auto";
    }
  });
};

const setMenuBorder = () => {
  const menuLeftRight = document.querySelectorAll(".menu-right, .menu-left");
  menuLeftRight.forEach((menu) => (menu.style.borderRadius = "0px"));
};

class Carousel {
  constructor(container) {
    container.carousel = this;
    this.container = container;
    this.carousel = container.querySelector(".carousel");
    this.carouselItems = container.querySelectorAll(".carousel__item");
    this.numItems = this.carouselItems.length;
    this.itemNumber = 1;
    this.constrained = true;
    this.holdInterval = null;
    this.holdTimeout = null;
    this.isHolding = false;

    this.imgs = Array.from(this.carouselItems)
      .map((item) => item.querySelector("img"))
      .filter((img) => img);

    this.widescreenPrevBtn = (() => {
      const btn = document.createElement("button");
      btn.className = "carousel__nav-button carousel__nav-item--prev";
      btn.innerHTML = '<img src="./img/carousel-prev-icon.svg" alt="Previous">';
      btn.setAttribute("aria-label", "Previous slide");
      return btn;
    })();

    this.widescreenNextBtn = (() => {
      const btn = document.createElement("button");
      btn.className = "carousel__nav-button carousel__nav-item--next";
      btn.innerHTML = '<img src="./img/carousel-next-icon.svg" alt="Next">';
      btn.setAttribute("aria-label", "Next slide");
      return btn;
    })();

    this.touchscreenFstBtn = (() => {
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

    this.touchscreenLstBtn = (() => {
      const btn = document.createElement("button");
      btn.className = "carousel__nav-button carousel__nav-item--last";
      btn.innerHTML = '<img src="./img/carousel-jump-to-end.svg" alt="Last">';
      btn.setAttribute("aria-label", "Last slide");
      btn.addEventListener("click", () => {
        this.setItemNumber(this.numItems);
      });
      return btn;
    })();

    this.touchscreenPrevBtn = this.widescreenPrevBtn.cloneNode(true);
    this.touchscreenNextBtn = this.widescreenNextBtn.cloneNode(true);

    this.doOnClickAndOnHold(this.touchscreenPrevBtn, () => {
      this.nudgeCarouselItem(-1);
    });
    this.doOnClickAndOnHold(this.touchscreenNextBtn, () => {
      this.nudgeCarouselItem(1);
    });
    this.doOnClickAndOnHold(this.widescreenPrevBtn, () => {
      this.nudgeCarouselItem(-1);
    });
    this.doOnClickAndOnHold(this.widescreenNextBtn, () => {
      this.nudgeCarouselItem(1);
    });

    this.indexCounter = (() => {
      const indexCounter = document.createElement("span");
      indexCounter.textContent = `${this.itemNumber}`;
      return indexCounter;
    })();

    this.progressCounter = (() => {
      const progressCounter = document.createElement("div");
      progressCounter.className = "carousel__progress-counter";

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

    this.touchscreenNav = (() => {
      const touchscreenNav = document.createElement("div");

      touchscreenNav.className = "carousel__mobile-nav";
      touchscreenNav.appendChild(this.touchscreenFstBtn);
      touchscreenNav.appendChild(this.touchscreenPrevBtn);
      touchscreenNav.appendChild(this.progressCounter);
      touchscreenNav.appendChild(this.touchscreenNextBtn);
      touchscreenNav.appendChild(this.touchscreenLstBtn);

      return touchscreenNav;
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
    this.handleResize();

    window.addEventListener("resize", () => this.handleResize());
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

  attachWidescreenNav() {
    this.prependToCarousel(this.widescreenPrevBtn);
    this.appendToCarousel(this.widescreenNextBtn);
    this.appendToContainer(this.indicators);
  }

  removeWidescreenNav() {
    this.removeFromCarousel(this.widescreenPrevBtn);
    this.removeFromCarousel(this.widescreenNextBtn);
    this.removeFromContainer(this.indicators);
  }

  attachTouchscreenNav() {
    this.appendToContainer(this.touchscreenNav);
  }

  removeTouchscreenNav() {
    this.removeFromContainer(this.touchscreenNav);
  }

  handleResize() {
    onTouchscreenElse(
      () => {
        this.removeWidescreenNav();
        this.attachTouchscreenNav();
      },
      () => {
        this.removeTouchscreenNav();
        this.attachWidescreenNav();
      }
    );
  }

  updateIndexCounter() {
    this.indexCounter.textContent = `${this.itemNumber}`;
  }

  updateItemClassLists() {
    this.carouselItems.forEach((item, index) => {
      item.classList.remove("active");
      if (index + 1 === this.itemNumber) {
        item.classList.add("active");
      }
    });
  }

  updateImageWidthsAndMaxWidths() {
    // apply the current enlarged/constrained state to all images in the carousel
    if (!this.constrained) {
      // apply enlarged state to all images
      this.imgs.forEach((img) => {
        img.classList.remove("constrained");
        // set img size to naturalWidth or some specific enlarged size
        if (img.naturalWidth < MOBILE_MAX_WIDTH) {
          img.style.width = "150%";
          img.style.maxWidth = "150%";
        } else {
          img.style.width = img.naturalWidth + "px";
          img.style.maxWidth = img.naturalWidth + "px";
        }
      });
    } else {
      // apply constrained state to all images
      this.imgs.forEach((img) => {
        img.classList.add("constrained");
        // reset img size to fit the container
        img.style.width = "100%";
        img.style.maxWidth = getComputedStyle(root)
          .getPropertyValue("--main-column-width")
          .trim();
      });
    }
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
    this.updateItemClassLists();
    this.updateIndexCounter();
    this.updateIndicators();
    this.updateImageWidthsAndMaxWidths();
  }

  nudgeCarouselItem(direction) {
    // console.log("in nudge!", direction);
    this.setItemNumber(
      1 + ((this.numItems + this.itemNumber + direction - 1) % this.numItems)
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

const setupCarousels = () => {
  let carouselObserver = createCarouselObserver();
  const carousels = document.querySelectorAll(".carousel__container");
  carousels.forEach((container) => {
    new Carousel(container);
    carouselObserver.observe(container);
  });
};

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

const constrainImage = (image) => {
  image.classList.add("constrained");
  image.style.width = "100%";
  image.style.maxWidth = getComputedStyle(root)
    .getPropertyValue("--main-column-width")
    .trim();
};

const unconstrainImage = (image) => {
  image.classList.remove("constrained");
  if (image.naturalWidth < MOBILE_MAX_WIDTH) {
    image.style.width = "150%";
    image.style.maxWidth = "150%";
  } else {
    image.style.width = image.naturalWidth + "px";
    image.style.maxWidth = image.naturalWidth + "px";
  }
};

const toggleImageZoom = (image) => {
  if (image.classList.contains("constrained")) {
    unconstrainImage(image);
  } else {
    constrainImage(image);
  }
};

const toggleCarouselImageZoom = (image) => {
  const carouselContainer = image.closest(".carousel__container");
  const carousel = carouselContainer.carousel;

  if (image.classList.contains("constrained")) {
    carousel.constrained = false;
  } else {
    carousel.constrained = true;
  }

  carousel.updateImageWidthsAndMaxWidths();
};

const onImgClick = (e) => {
  const image = e.srcElement;
  if (isPageCentered) {
    onMobile(() => {
      if (image.closest(".carousel")) {
        toggleCarouselImageZoom(image);
      } else {
        toggleImageZoom(image);
      }
    });
  }
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

const setupImages = () => {
  let images = document.querySelectorAll("img");
  for (const image of images) {
    if (!image.closest(".carousel")) {
      constrainImage(image);
    }
  }
};

const onLoad = () => {
  setupImages();
  setupCarousels();
  onResize();
  setMenuVisibility(true);
  setupMenuTooltips();
};

// event listeners
const onResize = () => {
  instantRecenter();
  resetScreenWidthDependentVars();
  onMobile(() => setImgHeightToAuto());
  onMobile(() => setMenuBorder());
  setTimeout(adjustMathAlignment, 60);
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
