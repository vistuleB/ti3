const setImgsToNaturalWidth = (imgs) => {
  imgs.forEach((img) => {
    img.style.width = `${img.naturalWidth}px`;
  });
};

const setImgsWidthToHundredPercent = (imgs) => {
  imgs.forEach((img) => {
    img.style.width = "100%";
  });
};

const toggleGroupZoom = (group) => {
  const imgs = document.querySelectorAll(".group img");
  const zoomed = group.classList.contains("zoom");
  if (zoomed) {
    requestAnimationFrame(() => {
      setImgsWidthToHundredPercent(imgs);
      group.classList.remove("zoom");
    });
  } else {
    requestAnimationFrame(() => {
      setImgsToNaturalWidth(imgs);
      group.classList.add("zoom");
    });
  }
};
