const MIN_DOCUMENT_WIDTH_TO_MAINTAIN_FOR_IMAGES_EVEN_ON_MOBILE = 1000;
const MAX_TEXT_COLUMN_WIDTH_ON_DESKTOP_OR_ANYWHERE = 2000;
const FALLBACK_TEXT_COLUMN_WIDTH_ON_DESKTOP_IF_SCREEN_IS_REALLY_THAT_WIDE = 700;

let text_parents = null;
let paragraphs = null;

function handleResize() {
    let innerWidth = window.innerWidth;
    let text_column_width = 
        (innerWidth > MAX_TEXT_COLUMN_WIDTH_ON_DESKTOP_OR_ANYWHERE) ? 
        FALLBACK_TEXT_COLUMN_WIDTH_ON_DESKTOP_IF_SCREEN_IS_REALLY_THAT_WIDE :
        innerWidth;
    let total_width = Math.max(MIN_DOCUMENT_WIDTH_TO_MAINTAIN_FOR_IMAGES_EVEN_ON_MOBILE, innerWidth);

    console.assert(total_width >= innerWidth, "total_width < innerWidth", total_width, innerWidth);
    
    outer_container.style.width = total_width + "px";

    console.log("====");
    console.log("innerWidth:", innerWidth);
    console.log("set container width to", total_width);
    console.log("set text_column_width to", text_column_width);

    text_column_width += "px";

    for (const tp of text_parents) {
        console.log("tryin text-parent");
        tp.style.width = text_column_width;
    }

    for (const tp of paragraphs) {
        console.log("tryin paragraph");
        tp.style.width = text_column_width;
    }

    window.scrollTo(
        (total_width - window.innerWidth) / 2,
        window.scrollY,
    );
}

function loadHandleResize() {
    text_parents = document.getElementsByClassName('text-parent');
    paragraphs = document.getElementsByTagName('p');
    window.addEventListener('resize', handleResize);
    handleResize();
}