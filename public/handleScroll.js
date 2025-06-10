const onLoad = () => {
  window.scrollTo({
    left: 1500,
  });
};

const scroll_back_to_center = (e) => {
  let theoretical_left = (document.body.scrollWidth - window.innerWidth) / 2;
  if (
    window.scrollX > theoretical_left - 200 &&
    window.scrollX < theoretical_left + 200
  ) {
    window.scroll({
      left: theoretical_left,
      behavior: "smooth",
    });
    return;
  }
};

window.addEventListener("DOMContentLoaded", onLoad);
window.addEventListener("scroll", scroll_back_to_center);
document.addEventListener("scrollend", scroll_back_to_center);
document.addEventListener("touchend", scroll_back_to_center);
