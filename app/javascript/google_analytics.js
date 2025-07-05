window.dataLayer = window.dataLayer || [];
function gtag() { dataLayer.push(arguments); }

gtag("js", new Date());

document.addEventListener("turbo:load", function (event) {
  gtag("config", "G-YPW981RE5N", {
    page_location: event.detail.url,
    page_path: window.location.pathname,
    page_title: document.title
  });
});

export default gtag;
