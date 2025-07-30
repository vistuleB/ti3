const WELL_100VW_MAX_WIDTH = 550;
const WELL_100VW_MINUS_PADDING_MAX_WIDTH = 700;
const MAIN_COLUMN_100VW_MAX_WIDTH = 1400;
const WIDE_SCREEN_MAIN_COLUMN_WIDTH = 1100;
const TOTAL_X_PADDING_IN_PX = 64;
const DIFF_BETWEEN_WELL_AND_MAIN_COLUMN_WHEN_WELL_IS_INSET = 100;
const CAROUSEL_ARROW_DESKTOP_SIZE = 48;
const CAROUSEL_ARROW_MOBILE_SIZE = 28;
const BODY_TOP_MARGIN_MOBILE = 140;
const BODY_TOP_MARGIN_DESKTOP = 80;

window.history.scrollRestoration = "manual";
// menu scroll behavior 
let lastScrollY = 0;
let menuElement = null;


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

const computeBodyTopMargin = () => {
  const screenWidth = window.innerWidth;
  if (screenWidth <= WELL_100VW_MAX_WIDTH) return BODY_TOP_MARGIN_MOBILE;
  return BODY_TOP_MARGIN_DESKTOP;
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


const computeCarouselArrowSize = () => {
  const screenWidth = window.innerWidth;
  if (screenWidth <= WELL_100VW_MAX_WIDTH) return CAROUSEL_ARROW_MOBILE_SIZE;
  return CAROUSEL_ARROW_DESKTOP_SIZE;
};

const setBodyTopMargin = (value) => {
  const root = document.documentElement;
  const cssValue = `${value}px`;
  root.style.setProperty('--body-top-margin', cssValue);
};

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

const setCarouselArrowSize = (value) => {
  const root = document.documentElement;
  const cssValue = `${value}px`;
  root.style.setProperty('--carousel-arrow-size', cssValue);
};

const add_line_number_to_numbered_pre = () => {
  document.querySelectorAll('pre.numbered-pre').forEach(pre => {
    const lines = pre.textContent.split('\n');
    pre.innerHTML = lines
      .map((line, i) => `${i + 1}. ${line}`)
      .slice(0, -1)
      .join('\n');
  });
}

class Carousel {
  constructor(container) {
    this.container = container;
    this.carousel = container.querySelector('.carousel__items');
    this.carouselItems = container.querySelectorAll('.carousel__item');
    this.totalCarouselItems = this.carouselItems.length - 1;
    this.currentCarouselItem = 0;
    
    this.init();
  }
  
  init() {
    this.createNavigationButtons();
    this.showCurrentItem();
    this.attachEventListeners();
  }
  
  createNavigationButtons() {
    // prev button
    const prevBtn = document.createElement('button');
    prevBtn.className = 'carousel__nav-button carousel__nav-item--prev';
    prevBtn.innerHTML = '<img src="./img/carousel-prev-icon.svg" alt="Previous">';
    prevBtn.setAttribute('aria-label', "Previous slide");
    
    // next button
    const nextBtn = document.createElement('button');
    nextBtn.className = 'carousel__nav-button carousel__nav-item--next';
    nextBtn.innerHTML = '<img src="./img/carousel-next-icon.svg" alt="Next">';
    nextBtn.setAttribute('aria-label', "Next slide");
    
    this.container.prepend(prevBtn);
    this.container.append(nextBtn);
  }
  
  showCurrentItem() {
    // hide all items and show only the current one
    this.carouselItems.forEach((item, index) => {
      item.classList.remove('active');
      if (index === this.currentCarouselItem) {
        item.classList.add('active');
      }
    });
    
    this.updateButtonStates();
  }
  
  changeCarouselItem(direction) {
    this.currentCarouselItem += direction;
    
    if (this.currentCarouselItem >= this.carouselItems.length) {
      this.currentCarouselItem = this.carouselItems.length - 1;
    } else if (this.currentCarouselItem < 0) {
      this.currentCarouselItem = 0;
    }
    
    this.showCurrentItem();
  }
  
  goToCarouselItem(carouselItemIndex) {
    if (carouselItemIndex >= 0 && carouselItemIndex <= this.totalCarouselItems) {
      this.currentCarouselItem = carouselItemIndex;
      this.showCurrentItem();
    }
  }
  
  updateButtonStates() {
      const prevBtn = this.container.querySelector('.carousel__nav-item--prev');
      const nextBtn = this.container.querySelector('.carousel__nav-item--next');
      
      // disable prev button if at first item
      prevBtn.disabled = this.currentCarouselItem === 0;
      
      // disable next button if at last item
      nextBtn.disabled = this.currentCarouselItem === this.carouselItems.length - 1;
  }
  
  attachEventListeners() {
    const prevBtn = this.container.querySelector('.carousel__nav-item--prev');
    const nextBtn = this.container.querySelector('.carousel__nav-item--next');
    
    prevBtn.addEventListener('click', () => {
      this.changeCarouselItem(-1);
    })
    
    nextBtn.addEventListener('click', () => {
      this.changeCarouselItem(1);
    })
  }
}

const setupCarousels = () => {
  const carousels = document.querySelectorAll('.carousel');
  carousels.forEach(container => {
    new Carousel(container);
  })
  
  setCarouselArrowSize(computeCarouselArrowSize());
};

const adjustMathAlignment = () => {
  document.querySelectorAll('.math-block').forEach((math_block) => {
    const svg = math_block.querySelector('svg');
    if (!svg) {
      // this happens throughout---it seems the mjx_container
      // momentarily only contains assistive content
      return;
    }
    const minWidth = window.getComputedStyle(svg).minWidth;
    if (!minWidth || !minWidth.endsWith('px')) {
      console.log("failed to get minWidth ending with 'px':", minWidth);
      return;
    }
    const minWidthInPx = parseFloat(minWidth);
    const mathBlockWidthInPx = math_block.getBoundingClientRect().width;
    if (minWidthInPx > mathBlockWidthInPx) {
      math_block.scroll({left: minWidthInPx * (1/3)});
    }
  });
}

const onImgClick = (e) => {
  const image = e.srcElement;
  if (image.classList.contains("constrained")) {
    image.classList.remove("constrained");
  } else {
    image.classList.add("constrained");
  }
};

const handleMenuOnScroll = () => {
  if (!menuElement) {
    menuElement = document.querySelector('.menu');
    if (!menuElement) return;
  }

  const currentScrollY = window.scrollY;
  
  // show menu when scrolling up or at the top
  if (currentScrollY < lastScrollY || currentScrollY <= 10) {
    menuElement.classList.remove('menu--hidden');
  } 
  // hide menu when scrolling down (but not at the very top)
  else if (currentScrollY > lastScrollY && currentScrollY > 100) {
    menuElement.classList.add('menu--hidden');
  }
  
  lastScrollY = currentScrollY;
};

const smoothRecenterMaybe = (e) => {
  let theoretical_left = marginWidth();
  if (
    window.scrollX > theoretical_left - 200 &&
    window.scrollX < theoretical_left + 200
  ) {
    recenter("smooth");
  }
};

// helpers
const onWideScreen = (callback) => {
  const screenWidth = window.innerWidth;
  if (screenWidth <= WELL_100VW_MAX_WIDTH) return;
  return callback();
}

const onLoad = () => {
  setupCarousels();
  add_line_number_to_numbered_pre();
  onResize();
};

// event listeners
const onResize = () => {
  instantRecenter();
  setBodyTopMargin(computeBodyTopMargin());
  setMainColumnWidth(computeMainColumnWidth());
  setOuterWellWidth(computeOuterWellWidth());
  setCarouselArrowSize(computeCarouselArrowSize());
  setTimeout(adjustMathAlignment, 60);
}

const onScroll = (e) => {
  handleMenuOnScroll();
};

const onScrollEnd = (e) => {
  smoothRecenterMaybe();
  onWideScreen(() => setTimeout(adjustMathAlignment, 60))
};

const onTouchEnd = (e) => {
  smoothRecenterMaybe();
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
window.addEventListener("resize", onResize);
document.addEventListener("click", smoothRecenter);
document.addEventListener("scroll", onScroll);
document.addEventListener("scrollend", onScrollEnd);
document.addEventListener("touchend", onTouchEnd, {passive: true});
document.addEventListener('keydown', onKeyDown);
