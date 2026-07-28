/* App entry — composes all sections.
 *
 * Build-time only: build.mjs renders <App/> to static HTML and nothing in this
 * file (or React itself) is shipped to the browser. Runtime behaviour lives in
 * site.js.
 *
 * The old tweaks panel and accent-preset switcher were removed — they were
 * prototyping tools that every visitor downloaded, and the default palette is
 * already the one hardcoded in styles.css.
 */

const App = () => (
  <>
    <div id="top"/>
    <Hero headlineVariant="zero-history" showShortcuts={true}/>
    <Insight/>
    <HowItWorks/>
    <Features/>
    <Demo/>
    <Compare/>
    <Privacy/>
    <Install/>
    <Sponsor/>
    <Footer/>
  </>
);

Object.assign(window, { App });
