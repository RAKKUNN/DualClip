/* Runtime behaviour for the prerendered landing page.
 *
 * The page ships as static HTML — this replaces what React state used to do.
 * Everything degrades gracefully: without JS the page still renders its first
 * frame, and every control below is inert rather than broken.
 */
(function () {
  'use strict';

  var reduceMotion = window.matchMedia
    ? window.matchMedia('(prefers-reduced-motion: reduce)').matches
    : false;

  /* ---- Theme -------------------------------------------------------- */

  var root = document.documentElement;
  var STORAGE_KEY = 'dualclip-theme';

  function applyTheme(theme) {
    root.setAttribute('data-theme', theme);
  }

  function initTheme() {
    var stored = null;
    try { stored = localStorage.getItem(STORAGE_KEY); } catch (e) { /* private mode */ }

    if (stored === 'light' || stored === 'dark') {
      applyTheme(stored);
    } else if (window.matchMedia && window.matchMedia('(prefers-color-scheme: light)').matches) {
      // Previously the page was hardcoded to dark regardless of OS preference.
      applyTheme('light');
    }

    var button = document.querySelector('[data-theme-toggle]');
    if (!button) return;
    button.addEventListener('click', function () {
      var next = root.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
      applyTheme(next);
      try { localStorage.setItem(STORAGE_KEY, next); } catch (e) { /* ignore */ }
    });
  }

  /* ---- Hero: rotate the highlighted slot ---------------------------- */

  function initHeroSlots() {
    var rows = Array.prototype.slice.call(document.querySelectorAll('[data-slot-row]'));
    if (rows.length < 2 || reduceMotion) return;

    var order = ['A', 'B', 'C'];
    var index = 0;
    setInterval(function () {
      index = (index + 1) % order.length;
      rows.forEach(function (row) {
        row.classList.toggle('is-active', row.getAttribute('data-slot-row') === order[index]);
      });
    }, 2400);
  }

  /* ---- How it works: 3-step storyboard ------------------------------ */

  function initHowItWorks() {
    var stage = document.querySelector('[data-how-stage]');
    var items = Array.prototype.slice.call(document.querySelectorAll('[data-how-step]'));
    if (!stage || !items.length) return;

    var highlight = stage.querySelector('.stage-highlight');
    var cursor = stage.querySelector('.stage-cursor');
    var packet = stage.querySelector('.stage-packet');
    var slotB = stage.querySelector('[data-stage-slot-b]');
    var slotBHint = slotB && slotB.querySelector('.stage-slot-hint');
    var system = stage.querySelector('.stage-system');

    var current = 0;
    var timer = null;

    function render(step) {
      current = step;
      stage.className = 'how-stage-inner step-' + step;

      items.forEach(function (item, i) {
        item.classList.toggle('is-active', i === step);
      });
      if (highlight) highlight.classList.toggle('is-on', step === 0);
      if (cursor) cursor.classList.toggle('is-on', step === 1);
      if (packet) {
        packet.className = 'stage-packet ' +
          (step === 0 ? 'fly-out' : step === 1 ? 'fly-in' : 'rest');
      }
      var loaded = step === 0 || step === 1;
      if (slotB) slotB.className = 'stage-slot' + (loaded ? ' is-loaded slot-b' : '');
      if (slotBHint) slotBHint.textContent = loaded ? 'handleCopy()' : 'empty';
      if (system) system.classList.toggle('is-pulse', step === 2);
    }

    function start() {
      if (reduceMotion || timer) return;
      timer = setInterval(function () { render((current + 1) % 3); }, 3000);
    }

    items.forEach(function (item, i) {
      item.setAttribute('tabindex', '0');
      item.setAttribute('role', 'button');
      function pick() {
        // A deliberate click shouldn't be yanked away a moment later.
        if (timer) { clearInterval(timer); timer = null; }
        render(i);
      }
      item.addEventListener('click', pick);
      item.addEventListener('keydown', function (event) {
        if (event.key === 'Enter' || event.key === ' ') {
          event.preventDefault();
          pick();
        }
      });
    });

    start();
  }

  /* ---- Demo tabs ----------------------------------------------------- */

  function initDemoTabs() {
    var tabs = Array.prototype.slice.call(document.querySelectorAll('[data-demo-tab]'));
    var panels = Array.prototype.slice.call(document.querySelectorAll('[data-demo-panel]'));
    var title = document.querySelector('[data-demo-title]');
    if (!tabs.length || !panels.length) return;

    var titles = { text: 'DualClip — text demo', image: 'DualClip — image demo' };

    tabs.forEach(function (tab) {
      tab.addEventListener('click', function () {
        var name = tab.getAttribute('data-demo-tab');
        tabs.forEach(function (other) {
          var on = other === tab;
          other.classList.toggle('is-active', on);
          other.setAttribute('aria-selected', on ? 'true' : 'false');
        });
        panels.forEach(function (panel) {
          var on = panel.getAttribute('data-demo-panel') === name;
          panel.classList.toggle('is-hidden', !on);
          panel.hidden = !on;
        });
        if (title && titles[name]) title.textContent = titles[name];
      });
    });
  }

  /* ---- Copy buttons --------------------------------------------------- */

  function initCopyButtons() {
    var buttons = Array.prototype.slice.call(document.querySelectorAll('[data-copy]'));

    buttons.forEach(function (button) {
      var reset = null;
      button.addEventListener('click', function () {
        var text = button.getAttribute('data-copy');

        function done() {
          button.classList.add('copied');
          clearTimeout(reset);
          reset = setTimeout(function () { button.classList.remove('copied'); }, 1600);
        }

        function fallback() {
          var field = document.createElement('textarea');
          field.value = text;
          field.setAttribute('readonly', '');
          field.style.position = 'fixed';
          field.style.opacity = '0';
          document.body.appendChild(field);
          field.select();
          try { document.execCommand('copy'); } catch (e) { /* nothing else to try */ }
          document.body.removeChild(field);
          done();
        }

        if (navigator.clipboard && navigator.clipboard.writeText) {
          navigator.clipboard.writeText(text).then(done, fallback);
        } else {
          fallback();
        }
      });
    });
  }

  function init() {
    initTheme();
    initHeroSlots();
    initHowItWorks();
    initDemoTabs();
    initCopyButtons();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
