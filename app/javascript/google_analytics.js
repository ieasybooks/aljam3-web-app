window.dataLayer = window.dataLayer || [];
function gtag() { dataLayer.push(arguments); }

gtag("js", new Date());

document.addEventListener("turbo:load", function (event) {
  gtag("config", "G-VBEGPJJEHW", {
    page_location: event.detail.url,
    page_path: window.location.pathname,
    page_title: document.title
  });
});

export default gtag;
