/* MoaV blog scroll motion. Asymmetric reveals: on the index, post cards slide in
   from alternating sides; inside a post, content blocks fade up with a staggered,
   alternating nudge. Transform/opacity only, IntersectionObserver, and it bails
   entirely under prefers-reduced-motion — the audience reads this on metered,
   low-power devices. navigation.instant is disabled site-wide, so a plain load
   hook is enough (no SPA re-init needed). */
(function () {
  "use strict";
  var root = document.documentElement;
  if (!root || root.getAttribute("data-moav-section") !== "blog") return;

  var reduce =
    window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches;

  function ready(fn) {
    if (document.readyState !== "loading") fn();
    else document.addEventListener("DOMContentLoaded", fn);
  }

  ready(function () {
    var targets = [];
    var cards = document.querySelectorAll(".blog-card");

    if (cards.length) {
      // Blog index: alternate the slide side for an asymmetric grid-in.
      cards.forEach(function (el, i) {
        el.classList.add("reveal", i % 2 ? "reveal-right" : "reveal-left");
        el.style.setProperty("--reveal-delay", ((i % 3) * 70) + "ms");
        targets.push(el);
      });
    } else {
      // A single post: reveal the rendered markdown blocks, staggered fade-up,
      // with a subtle alternating horizontal nudge so it does not feel metronomic.
      var body = document.querySelector(".md-content__inner .md-typeset") ||
                 document.querySelector(".md-content .md-typeset");
      if (body) {
        var blocks = body.querySelectorAll(
          ":scope > h2, :scope > h3, :scope > p, :scope > ul, :scope > ol," +
          ":scope > pre, :scope > blockquote, :scope > table, :scope > .admonition," +
          ":scope > details, :scope > figure, :scope > .highlight, :scope > .tabbed-set"
        );
        blocks.forEach(function (el, i) {
          el.classList.add("reveal");
          if (i % 4 === 1) el.classList.add("reveal-left");
          else if (i % 4 === 3) el.classList.add("reveal-right");
          el.style.setProperty("--reveal-delay", ((i % 3) * 60) + "ms");
          targets.push(el);
        });
      }
    }

    if (!targets.length) return;

    // Reduced motion or no observer: show everything, no animation.
    if (reduce || !("IntersectionObserver" in window)) {
      targets.forEach(function (el) { el.classList.add("is-visible"); });
      return;
    }

    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (e) {
        if (e.isIntersecting) {
          e.target.classList.add("is-visible");
          io.unobserve(e.target);
        }
      });
    }, { rootMargin: "0px 0px -8% 0px", threshold: 0.12 });

    targets.forEach(function (el) { io.observe(el); });
  });
})();
