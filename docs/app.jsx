/* App entry — composes all sections + Tweaks */

const { useTweaks } = window;

const TWEAK_DEFAULTS = /*EDITMODE-BEGIN*/{
  "theme": "dark",
  "accent": "violet-blue",
  "headlineVariant": "zero-history",
  "showShortcutCards": true
}/*EDITMODE-END*/;

const ACCENT_PRESETS = {
  "violet-blue": { violet: "#6B5BFF", blue: "#2D6CFF", teal: "#2DD4BF", a: "#8B7BFF", b: "#4D8AFF", c: "#2DD4BF" },
  "macos-blue":  { violet: "#0A84FF", blue: "#0A84FF", teal: "#30D158", a: "#0A84FF", b: "#5E5CE6", c: "#30D158" },
  "sunset":      { violet: "#FF6B6B", blue: "#FF9F0A", teal: "#FFD60A", a: "#FF6B6B", b: "#FF9F0A", c: "#FFD60A" },
  "monochrome":  { violet: "#FFFFFF", blue: "#A8A8B3", teal: "#6B6B78", a: "#FFFFFF", b: "#A8A8B3", c: "#6B6B78" },
};

const HEADLINES = {
  "zero-history": (<>Three clipboards.<br/><span className="headline-em">Zero history.</span></>),
  "where-not-when": (<><span className="headline-em">Where</span>, not when.</>),
  "by-the-letter": (<>Stash by the letter.<br/><span className="headline-em">A, B, or C.</span></>),
};

function applyAccent(name) {
  const a = ACCENT_PRESETS[name] || ACCENT_PRESETS["violet-blue"];
  const r = document.documentElement;
  r.style.setProperty('--accent-violet', a.violet);
  r.style.setProperty('--accent-blue', a.blue);
  r.style.setProperty('--accent-teal', a.teal);
  r.style.setProperty('--slot-a', a.a);
  r.style.setProperty('--slot-b', a.b);
  r.style.setProperty('--slot-c', a.c);
}

const App = () => {
  const [tweaks, setTweak] = useTweaks(TWEAK_DEFAULTS);

  React.useEffect(() => {
    document.documentElement.setAttribute('data-theme', tweaks.theme);
  }, [tweaks.theme]);

  React.useEffect(() => {
    applyAccent(tweaks.accent);
  }, [tweaks.accent]);

  // Override hero headline at runtime
  React.useEffect(() => {
    const el = document.querySelector('.hero-headline');
    if (!el) return;
    // No-op: handled by passing variant down via context-less prop is overkill.
    // Instead, mutate after mount:
  }, [tweaks.headlineVariant]);

  return (
    <>
      <div id="top"/>
      <Hero headlineVariant={tweaks.headlineVariant} showShortcuts={tweaks.showShortcutCards}/>
      <Insight/>
      <HowItWorks/>
      <Features/>
      <Demo/>
      <Compare/>
      <Privacy/>
      <Install/>
      <Footer/>
      {typeof window !== 'undefined' && new URLSearchParams(window.location.search).has('tweaks') && (
        <DualClipTweaks tweaks={tweaks} setTweak={setTweak}/>
      )}
    </>
  );
};

const DualClipTweaks = ({ tweaks, setTweak }) => {
  const { TweaksPanel, TweakSection, TweakRadio, TweakSelect, TweakToggle } = window;
  if (!TweaksPanel) return null;
  return (
    <TweaksPanel title="Tweaks">
      <TweakSection title="Appearance">
        <TweakRadio
          label="Theme"
          value={tweaks.theme}
          onChange={v => setTweak('theme', v)}
          options={[{ value: 'dark', label: 'Dark' }, { value: 'light', label: 'Light' }]}
        />
        <TweakSelect
          label="Accent palette"
          value={tweaks.accent}
          onChange={v => setTweak('accent', v)}
          options={[
            { value: 'violet-blue', label: 'Violet → Blue (default)' },
            { value: 'macos-blue', label: 'macOS Blue' },
            { value: 'sunset', label: 'Sunset' },
            { value: 'monochrome', label: 'Monochrome' },
          ]}
        />
      </TweakSection>
      <TweakSection title="Hero">
        <TweakSelect
          label="Headline"
          value={tweaks.headlineVariant}
          onChange={v => setTweak('headlineVariant', v)}
          options={[
            { value: 'zero-history', label: 'Three clipboards. Zero history.' },
            { value: 'where-not-when', label: 'Where, not when.' },
            { value: 'by-the-letter', label: 'Stash by the letter.' },
          ]}
        />
        <TweakToggle
          label="Show shortcut cards"
          checked={tweaks.showShortcutCards}
          onChange={v => setTweak('showShortcutCards', v)}
        />
      </TweakSection>
    </TweaksPanel>
  );
};

Object.assign(window, { App, HEADLINES });

ReactDOM.createRoot(document.getElementById('root')).render(<App/>);
