const WELL_100VW_MAX_WIDTH = 550;
const WELL_100VW_MINUS_PADDING_MAX_WIDTH = 900;
const MAIN_COLUMN_100VW_MAX_WIDTH = 1400;
const WIDE_SCREEN_MAIN_COLUMN_WIDTH = 1050;
const DIFF_BETWEEN_WELL_AND_MAIN_COLUMN_WHEN_WELL_IS_INSET = 150;
const CAROUSEL_ARROW_MAX_SIZE = 48;
const CAROUSEL_ARROW_MIN_SIZE = 28;

const root = document.documentElement;
const remToPx = 16;

window.history.scrollRestoration = "manual";

let lastScrollY = 0;
let lastScrollYMoment = Date.now();
let menuHidden = false;
// let menuElement = null;
let menuElements = null;
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
    if (screenWidth <= MAIN_COLUMN_100VW_MAX_WIDTH) return "none";
    return "inline";
  }

  let menuPaddingXInRem = () => {
    if (screenWidth <= MAIN_COLUMN_100VW_MAX_WIDTH) return mainColumnPaddingXInRem();
    return 1.7;
  }

  let menuPaddingYInRem = () => {
    if (screenWidth <= WELL_100VW_MAX_WIDTH) return 1.6;
    if (screenWidth <= WELL_100VW_MINUS_PADDING_MAX_WIDTH) return 1.6;
    return 1.4;
  }

  let menuBackgroundColor = () => {
    if (screenWidth <= MAIN_COLUMN_100VW_MAX_WIDTH) return "var(--body-background-color)";
    return "#0000";
  }

  let menuElementGapInRem = () => {
    if (screenWidth <= WELL_100VW_MAX_WIDTH) return 0.7;
    if (screenWidth <= WELL_100VW_MINUS_PADDING_MAX_WIDTH) return 0.7;
    return 0.55;
  }

  let indexHeaderTitleFontSizeInRem = () => {
    return pageTitleFontSizeInRem();
  };

  let indexHeaderTitleLineHeightInRem = () => {
    if (screenWidth <= WELL_100VW_MAX_WIDTH) return 2.2;
    if (screenWidth <= WELL_100VW_MINUS_PADDING_MAX_WIDTH) return 2.5;
    return 2.8;
  };

  let indexHeaderSubtitleFontSizeInRem = () => {
    if (screenWidth <= WELL_100VW_MAX_WIDTH) return 1.35;
    if (screenWidth <= WELL_100VW_MINUS_PADDING_MAX_WIDTH) return 1.45;
    return 1.5;
  };

  let indexHeaderPaddingTopInPx = () => {
    if (screenWidth <= WELL_100VW_MAX_WIDTH) return 90;
    if (screenWidth <= WELL_100VW_MINUS_PADDING_MAX_WIDTH) return 100;
    return 90;
  };

  let indexHeaderPaddingBottomInRem = () => {
    if (screenWidth <= WELL_100VW_MAX_WIDTH) return 2;
    if (screenWidth <= WELL_100VW_MINUS_PADDING_MAX_WIDTH) return 3;
    return 4;
  };

  let indexTocMaxWidthInPx = () => {
    if (screenWidth <= WELL_100VW_MINUS_PADDING_MAX_WIDTH)
      return screenWidth - 2 * mainColumnPaddingXInRem() * remToPx;
    return 580;
  };

  let indexTocPaddingBottomInRem = () => {
    if (screenWidth <= WELL_100VW_MAX_WIDTH) return 1.5;
    if (screenWidth <= WELL_100VW_MINUS_PADDING_MAX_WIDTH) return 2;
    return 3;
  }

  let indexTocChapterLevelMarginInEm = () => {
    if (screenWidth <= WELL_100VW_MAX_WIDTH) return 0.6;
    if (screenWidth <= WELL_100VW_MINUS_PADDING_MAX_WIDTH) return 0.6;
    return 0.5;
  }

  let indexTocSubchapterLevelMarginInEm = () => {
    if (screenWidth <= WELL_100VW_MAX_WIDTH) return 0.25;
    if (screenWidth <= WELL_100VW_MINUS_PADDING_MAX_WIDTH) return 0.2;
    return 0.15;
  }

  const carouselArrowSizeInPx = () => {
    const size = (6 / 100) * screenWidth; // 6vw
    const clampedSize = Math.min(
      CAROUSEL_ARROW_MAX_SIZE,
      Math.max(CAROUSEL_ARROW_MIN_SIZE, size),
    );
    return clampedSize;
  };

  const carouselNavButtonMarginXInPx = () => {
    if (screenWidth <= WELL_100VW_MAX_WIDTH) return 0;
    if (screenWidth <= WELL_100VW_MINUS_PADDING_MAX_WIDTH) return carouselArrowSizeInPx() * 0.7;
    if (screenWidth <= MAIN_COLUMN_100VW_MAX_WIDTH) return carouselArrowSizeInPx() * 0.4;
    return carouselArrowSizeInPx();
  };

  const endOfPageMainColumnMarginBottomInRem = () => {
    if (screenWidth <= WELL_100VW_MAX_WIDTH) return 1.2;
    if (screenWidth <= WELL_100VW_MINUS_PADDING_MAX_WIDTH) return 1.5;
    if (screenWidth <= MAIN_COLUMN_100VW_MAX_WIDTH) return 1.8;
    return 2.4;
  };

  const endOfPageWellMarginBottomInRem = () => {
    if (screenWidth <= WELL_100VW_MAX_WIDTH) return 0.8;
    if (screenWidth <= WELL_100VW_MINUS_PADDING_MAX_WIDTH) return 1.9;
    return 2.2;
  };

  let mainColumnWidthInPx = () => {
    if (screenWidth <= MAIN_COLUMN_100VW_MAX_WIDTH) return screenWidth;
    return WIDE_SCREEN_MAIN_COLUMN_WIDTH;
  };

  let mainColumnPaddingXInRem = () => {
    if (screenWidth <= WELL_100VW_MAX_WIDTH) return 1.5;
    if (screenWidth <= WELL_100VW_MINUS_PADDING_MAX_WIDTH) return 1.8;
    return 2;
  };

  let mainColumnToWellMarginInRem = () => {
    if (screenWidth <= WELL_100VW_MAX_WIDTH) return 0.8;
    if (screenWidth <= WELL_100VW_MINUS_PADDING_MAX_WIDTH) return 1.6;
    if (screenWidth <= MAIN_COLUMN_100VW_MAX_WIDTH) return 1.7;
    return 1.8;
  };

  let outerWellWidthInPx = () => {
    if (screenWidth <= WELL_100VW_MAX_WIDTH) return screenWidth - 1.5 * remToPx;
    if (screenWidth <= WELL_100VW_MINUS_PADDING_MAX_WIDTH)
      return screenWidth - 2 * mainColumnPaddingXInRem() * remToPx;
    if (screenWidth <= MAIN_COLUMN_100VW_MAX_WIDTH)
      return (
        mainColumnWidthInPx() -
        2 * DIFF_BETWEEN_WELL_AND_MAIN_COLUMN_WHEN_WELL_IS_INSET
      );
    return mainColumnWidthInPx() - 2 * mainColumnPaddingXInRem() * remToPx;
  };

  let pageTitleFontSizeInRem = () => {
    if (screenWidth <= WELL_100VW_MAX_WIDTH) return 1.8;
    if (screenWidth <= WELL_100VW_MINUS_PADDING_MAX_WIDTH) return 2.1;
    return 2.25;
  };

  let pageTitleMarginTopInRem = () => {
    if (screenWidth <= WELL_100VW_MAX_WIDTH) return 7;
    if (screenWidth <= WELL_100VW_MINUS_PADDING_MAX_WIDTH) return 7;
    if (screenWidth <= MAIN_COLUMN_100VW_MAX_WIDTH) return 6;
    return 3.6;
  };

  let topicAnnouncementFontSizeInRem = () => {
    if (screenWidth <= WELL_100VW_MAX_WIDTH) return pageTitleFontSizeInRem() * 0.85;
    if (screenWidth <= WELL_100VW_MINUS_PADDING_MAX_WIDTH) return pageTitleFontSizeInRem() * 0.82;
    return pageTitleFontSizeInRem() * 0.78;
  };

  let subtopicAnnouncementFontSizeInRem = () => {
    if (screenWidth <= WELL_100VW_MAX_WIDTH)
      return topicAnnouncementFontSizeInRem() * 0.95;
    if (screenWidth <= WELL_100VW_MINUS_PADDING_MAX_WIDTH)
      return topicAnnouncementFontSizeInRem() * 0.9;
    return topicAnnouncementFontSizeInRem() * 0.85;
  };

  const wellMarginYInRem = () => {
    if (screenWidth <= WELL_100VW_MAX_WIDTH) return 0.75;
    if (screenWidth <= WELL_100VW_MINUS_PADDING_MAX_WIDTH) return 1.6;
    return 2;
  };

  const lastChildWellMarginBottomInRem = () => {
    if (screenWidth <= WELL_100VW_MAX_WIDTH) return 0;
    if (screenWidth <= WELL_100VW_MINUS_PADDING_MAX_WIDTH) return 0.2;
    return 0.5;
  };

  const wellPaddingXInRem = () => {
    if (screenWidth <= WELL_100VW_MAX_WIDTH) return 0.75;
    if (screenWidth <= WELL_100VW_MINUS_PADDING_MAX_WIDTH) return 1.3;
    return 2;
  };

  const wellPaddingYInRem = () => {
    if (screenWidth <= WELL_100VW_MAX_WIDTH) return 0.75;
    if (screenWidth <= WELL_100VW_MINUS_PADDING_MAX_WIDTH) return 1.2;
    return 1.6;
  };

  const ulOlMarginLeftInRem = () => {
    if (screenWidth <= WELL_100VW_MAX_WIDTH) return 1;
    if (screenWidth <= WELL_100VW_MINUS_PADDING_MAX_WIDTH) return 1.5;
    return 2;
  };

  const ulOlMarginRightInRem = () => {
    if (screenWidth <= WELL_100VW_MAX_WIDTH) return 1;
    if (screenWidth <= WELL_100VW_MINUS_PADDING_MAX_WIDTH) return 1.5;
    return 2;
  };

  const nestedUlOlMarginLeftInRem = () => {
    return ulOlMarginLeftInRem();
  };

  const nestedUlOlMarginRightInRem = () => {
    if (screenWidth <= WELL_100VW_MAX_WIDTH) return 0;
    if (screenWidth <= WELL_100VW_MINUS_PADDING_MAX_WIDTH) return 1;
    return 2;
  };

  const textfigurePaddingXInRem = () => {
    if (screenWidth <= WELL_100VW_MAX_WIDTH) return 2.5;
    if (screenWidth <= WELL_100VW_MINUS_PADDING_MAX_WIDTH) return 3;
    if (screenWidth <= MAIN_COLUMN_100VW_MAX_WIDTH) return 5;
    return 6;
  };

  const mathBlockMaxWidthInPx = () => {
    if (screenWidth > MAIN_COLUMN_100VW_MAX_WIDTH) return Infinity;
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
  set("--index-toc-subchapter-level-margin", indexTocSubchapterLevelMarginInEm, "em");
  set("--carousel-arrow-size", carouselArrowSizeInPx, "px");
  set("--carousel-nav-button-margin-x", carouselNavButtonMarginXInPx, "px");
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

const setImgHeightToAuto = () => {
  const images = document.querySelectorAll(
    "figure.main-column img, .well figure img",
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

const add_line_number_to_numbered_pre = () => {
  document.querySelectorAll("pre.numbered-pre").forEach((pre) => {
    const lines = pre.textContent.split("\n");
    pre.innerHTML = lines
      .map((line, i) => `${i + 1}. ${line}`)
      .slice(0, -1)
      .join("\n");
  });
};

class Carousel {
  constructor(container) {
    container.carousel = this;
    this.container = container;
    this.carousel = container.querySelector(".carousel");
    this.carouselItems = container.querySelectorAll(".carousel__item");
    this.indicators = null;
    this.hasIndicators = false;
    this.totalCarouselItems = this.carouselItems.length - 1;
    this.currentCarouselItem = 0;

    this.allCarouselImgs = Array.from(this.carouselItems)
      .map((item) => item.querySelector("img"))
      .filter((img) => img);

    // initialize image state based on predicate that if ANY image has constrained class
    this.isImagesEnlarged = !this.allCarouselImgs.some((img) =>
      img.classList.contains("constrained"),
    );

    // mobile navigation button on hold properties
    this.holdInterval = null;
    this.holdTimeout = null;
    this.isHolding = false;
    // buttons
    this.prevBtn = (() => {
      const prevBtn = document.createElement("button");
      prevBtn.className = "carousel__nav-button carousel__nav-item--prev";
      prevBtn.innerHTML =
        '<img src="./img/carousel-prev-icon.svg" alt="Previous">';
      prevBtn.setAttribute("aria-label", "Previous slide");
      prevBtn.addEventListener("click", () => {
        this.changeCarouselItem(-1);
      });

      return prevBtn;
    })();

    this.nextBtn = (() => {
      const nextBtn = document.createElement("button");
      nextBtn.className = "carousel__nav-button carousel__nav-item--next";
      nextBtn.innerHTML = '<img src="./img/carousel-next-icon.svg" alt="Next">';
      nextBtn.setAttribute("aria-label", "Next slide");
      nextBtn.addEventListener("click", () => {
        this.changeCarouselItem(1);
      });

      return nextBtn;
    })();

    this.firstBtn = (() => {
      const firstBtn = document.createElement("button");
      firstBtn.className = "carousel__nav-button carousel__nav-item--first";
      firstBtn.innerHTML =
        '<img src="./img/carousel-jump-to-start.svg" alt="First">';
      firstBtn.setAttribute("aria-label", "First slide");
      firstBtn.addEventListener("click", () => {
        // show first slide
        if (!(this.currentCarouselItem == 0)) {
          this.goToCarouselItem(0);
        }
      });

      return firstBtn;
    })();

    this.lastBtn = (() => {
      const lastBtn = document.createElement("button");
      lastBtn.className = "carousel__nav-button carousel__nav-item--last";
      lastBtn.innerHTML =
        '<img src="./img/carousel-jump-to-end.svg" alt="Last">';
      lastBtn.setAttribute("aria-label", "Last slide");
      lastBtn.addEventListener("click", () => {
        // show last slide
        if (!(this.currentCarouselItem == this.totalCarouselItems)) {
          this.goToCarouselItem(this.totalCarouselItems);
        }
      });

      return lastBtn;
    })();

    this.indexCounter = (() => {
      const indexCounter = document.createElement("span");
      indexCounter.textContent = `${this.currentCarouselItem + 1}`;
      return indexCounter;
    })();

    this.progressCounter = (() => {
      const container = document.createElement("div");
      container.className = "carousel__progress-counter";
      const slash = (() => {
        const slash = document.createElement("span");
        slash.textContent = "/";
        return slash;
      })();
      const totalSlides = (() => {
        const totalSlides = document.createElement("span");
        totalSlides.textContent = `${this.totalCarouselItems + 1}`;
        return totalSlides;
      })();

      container.appendChild(this.indexCounter);
      container.appendChild(slash);
      container.appendChild(totalSlides);

      return container;
    })();

    // mobile navigation
    this.mobileNav = (() => {
      const mobileNav = document.createElement("div");
      mobileNav.className = "carousel__mobile-nav";

      const mobilePrevBtn = this.prevBtn.cloneNode(true);
      const mobileNextBtn = this.nextBtn.cloneNode(true);

      // add event listeners to cloned buttons
      this.addHoldFunctionality(mobilePrevBtn, -1);
      this.addHoldFunctionality(mobileNextBtn, 1);

      mobileNav.appendChild(this.firstBtn);
      mobileNav.appendChild(mobilePrevBtn);
      mobileNav.appendChild(this.progressCounter);
      mobileNav.appendChild(mobileNextBtn);
      mobileNav.appendChild(this.lastBtn);

      return mobileNav;
    })();

    this.init();
  }

  init() {
    onTouchScreenElse(
      () => {
        this.createMobileNavigationButtons();
        this.showCurrentItem();
      },
      () => {
        this.createWideScreenNavigationButtons();
        this.showCurrentItem();
      },
    );
    this.attachEventListeners();
  }

  createWideScreenNavigationButtons() {
    this.carousel.prepend(this.prevBtn);
    this.carousel.append(this.nextBtn);
    this.createIndicators();
  }

  createMobileNavigationButtons() {
    if (!this.container.contains(this.mobileNav)) {
      this.container.appendChild(this.mobileNav);
    }
  }

  removeMobileNavigationButtons() {
    if (this.container.contains(this.mobileNav)) {
      this.container.removeChild(this.mobileNav);
    }
  }

  createIndicators() {
    if (this.hasIndicators && this.indicators) return;

    this.indicators = document.createElement("div");
    this.indicators.className = "carousel__indicators";

    for (let i = 0; i <= this.totalCarouselItems; i++) {
      const indicator = document.createElement("button");
      indicator.className = "carousel__indicator_box";
      indicator.setAttribute("aria-label", `Go to slide ${i + 1}`);
      indicator.addEventListener("click", () => this.goToCarouselItem(i));
      const circle = document.createElement("div");
      circle.className = "carousel__indicator_dot";
      if (i === 0) circle.classList.add("active");
      indicator.appendChild(circle);
      this.indicators.appendChild(indicator);
    }

    this.container.appendChild(this.indicators);
    this.hasIndicators = true;

    this.updateIndicators();
  }

  removeIndicators() {
    if (this.hasIndicators && this.indicators) {
      this.container.removeChild(this.indicators);
      this.indicators = null;
      this.hasIndicators = false;
    }
  }

  removeWideScreenNavigationButtons() {
    if (this.carousel.contains(this.prevBtn)) {
      this.carousel.removeChild(this.prevBtn);
    }
    if (this.carousel.contains(this.nextBtn)) {
      this.carousel.removeChild(this.nextBtn);
    }

    this.removeIndicators();
  }

  showCurrentItem() {
    // hide all items and show only the current one
    this.carouselItems.forEach((item, index) => {
      item.classList.remove("active");
      if (index === this.currentCarouselItem) {
        item.classList.add("active");
      }
    });

    // preserve the enlarged/constrained state after navigation
    this.preserveImageState();

    if (this.indexCounter) {
      this.indexCounter.textContent = `${this.currentCarouselItem + 1}`;
    }

    this.updateIndicators();
  }

  preserveImageState() {
    // apply the current enlarged/constrained state to all images in the carousel
    if (this.isImagesEnlarged) {
      // apply enlarged state to all images
      this.allCarouselImgs.forEach((img) => {
        img.classList.remove("constrained");
        // set img size to naturalWidth or some specific enlarged size
        if (img.naturalWidth < WELL_100VW_MAX_WIDTH) {
          img.style.width = "150%";
          img.style.maxWidth = "150%";
        } else {
          img.style.width = img.naturalWidth + "px";
          img.style.maxWidth = img.naturalWidth + "px";
        }
      });
    } else {
      // apply constrained state to all images
      this.allCarouselImgs.forEach((img) => {
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
    const dots = this.container.querySelectorAll(".carousel__indicator_dot");
    dots.forEach((indicator, index) => {
      indicator.classList.toggle("active", index === this.currentCarouselItem);
    });
  }

  changeCarouselItem(direction) {
    this.currentCarouselItem += direction;

    // cyclic rotation
    if (this.currentCarouselItem > this.totalCarouselItems) {
      this.currentCarouselItem = 0; // go to first slide
    } else if (this.currentCarouselItem < 0) {
      this.currentCarouselItem = this.totalCarouselItems; // go to last slide
    }

    this.showCurrentItem();
  }

  goToCarouselItem(carouselItemIndex) {
    if (
      carouselItemIndex >= 0 &&
      carouselItemIndex <= this.totalCarouselItems
    ) {
      this.currentCarouselItem = carouselItemIndex;
      this.showCurrentItem();
    }
  }

  addHoldFunctionality(button, direction) {
    const startHold = () => {
      if (this.isHolding) return;

      this.isHolding = true;

      // initial touch - immediate response
      this.changeCarouselItem(direction);

      // start continuous navigation after a delay
      this.holdTimeout = setTimeout(() => {
        this.holdInterval = setInterval(() => {
          this.changeCarouselItem(direction);
        }, 200); // change slide every 200ms while holding
      }, 500); // wait 500ms before starting continuous navigation
    };

    const stopHold = () => {
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

    // mouse events
    button.addEventListener("mousedown", startHold);
    button.addEventListener("mouseup", stopHold);
    button.addEventListener("mouseleave", stopHold);

    // touch events for mobile
    button.addEventListener(
      "touchstart",
      (e) => {
        e.preventDefault();
        startHold();
      },
      { passive: false },
    );

    button.addEventListener(
      "touchend",
      (e) => {
        e.preventDefault();
        stopHold();
      },
      { passive: false },
    );

    button.addEventListener("touchcancel", stopHold);
  }

  handleResize() {
    onTouchScreenElse(
      () => {
        this.removeWideScreenNavigationButtons();
        this.createMobileNavigationButtons();
      },
      () => {
        this.removeMobileNavigationButtons();
        this.createWideScreenNavigationButtons();
      },
    );
  }

  attachEventListeners() {
    window.addEventListener("resize", () => this.handleResize());
  }
}

function getClosestVisibleCarousel() {
  var y0 = window.innerHeight / 2;
  var closestDistance = Infinity;
  var closestContainer = null;
  for (c of visibleCarouselContainers) {
    let r = c.getBoundingClientRect();
    let y = r.y + r.height / 2;
    if (Math.abs(y - y0) < closestDistance) {
      closestDistance = Math.abs(y - y0);
      closestContainer = c;
    }
  }
  return closestContainer != null ? closestContainer.carousel : null;
}

function createCarouselObserver() {
  const options = {
    root: null,
    rootMargin: "0% 0% 0% 0%",
    threshold: 1.0,
  };

  const callback = (entries, _) => {
    entries.forEach((entry) => {
      let index = visibleCarouselContainers.indexOf(entry.target);
      if (entry.isIntersecting) {
        if (index === -1) {
          visibleCarouselContainers.push(entry.target);
        }
      } else {
        if (index !== -1) {
          visibleCarouselContainers.splice(index, 1);
        }
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
  if (screenWidth <= WELL_100VW_MAX_WIDTH) return;

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

const englargeImg = (image) => {
  if (image.classList.contains("constrained")) {
    image.classList.remove("constrained");
    if (image.naturalWidth < WELL_100VW_MAX_WIDTH) {
      image.style.width = "150%";
      image.style.maxWidth = "150%";
    } else {
      image.style.width = image.naturalWidth + "px";
      image.style.maxWidth = image.naturalWidth + "px";
    }
  } else {
    image.classList.add("constrained");
    image.style.width = "100%";
    image.style.maxWidth = getComputedStyle(root)
      .getPropertyValue("--main-column-width")
      .trim();
  }
};

const enlargeImgForCarousel = (image) => {
  // enlarge or constrain all carousel images whenever the action is performed on a single image
  const carouselContainer = image.closest(".carousel__container");
  const carousel = carouselContainer.carousel;

  if (image.classList.contains("constrained")) {
    // switch to enlarged state
    carousel.isImagesEnlarged = true;
  } else {
    // switch to constrained state
    carousel.isImagesEnlarged = false;
  }

  carousel.preserveImageState();
};

const onImgClick = (e) => {
  const image = e.srcElement;
  if (isPageCentered) {
    onMobile(() => {
      if (image.closest(".carousel")) {
        enlargeImgForCarousel(image);
      } else {
        englargeImg(image);
      }
    });
  }
};

const onScrollMenuDisplay = (e) => {
  if (!menuElements) {
    menuElements = document.getElementsByClassName("menu");
    if (menuElements.length === 0) return;
  }

  const currentScrollY = window.scrollY;
  const currentScrollYMoment = Date.now();
  const velocity = (currentScrollY - lastScrollY) / (currentScrollYMoment - lastScrollYMoment);

  if ((velocity < -7 || currentScrollY <= 10) && menuHidden) {
    for (const m of menuElements) { m.classList.remove("menu--hidden"); }
    menuHidden = false;
  }
  
  else if (currentScrollY > lastScrollY && currentScrollY > 10 && !menuHidden) {
    for (const m of menuElements) { m.classList.add("menu--hidden"); }
    menuHidden = true;
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

// helpers
const onWideScreen = (callback) => {
  const screenWidth = window.innerWidth;
  if (screenWidth <= WELL_100VW_MAX_WIDTH) return;
  return callback();
};

const onMobile = (callback) => {
  const screenWidth = window.innerWidth;
  if (screenWidth <= WELL_100VW_MAX_WIDTH) return callback();
  return;
};

const onTouchScreenElse = (callback1, callback2) => {
  const screenWidth = window.innerWidth;
  if (screenWidth <= WELL_100VW_MINUS_PADDING_MAX_WIDTH) return callback1();
  return callback2();
};

const visibleCarouselContainers = new Array();

const onLoad = () => {
  setupCarousels();
  add_line_number_to_numbered_pre();
  onResize();
};

// event listeners
const onResize = () => {
  instantRecenter();
  resetScreenWidthDependentVars();
  onMobile(() => hideMenu());
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
  // check if any input fields are focused to avoid interfering with typing
  const activeElement = document.activeElement;
  const isInputFocused =
    activeElement &&
    (activeElement.tagName === "INPUT" ||
      activeElement.tagName === "TEXTAREA" ||
      activeElement.isContentEditable);

  if (isInputFocused) return;

  switch (e.key) {
    case "ArrowLeft":
      e.preventDefault();
      var carousel = getClosestVisibleCarousel();
      if (carousel != null) {
        carousel.changeCarouselItem(-1);
      } else {
        navigateToChapter("prev-page");
      }
      break;
    case "ArrowRight":
      e.preventDefault();
      var carousel = getClosestVisibleCarousel();
      if (carousel != null) {
        carousel.changeCarouselItem(1);
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
document.addEventListener("keydown", onKeyDown);
