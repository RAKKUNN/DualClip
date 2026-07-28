/* Hero — the menu-bar popover mockup is the showpiece */

const MenuBarPopover = ({ active = 'A' }) => {
  const slots = [
    { id: 'A', shortcut: ['⌘', 'C'], paste: ['⌘', 'V'], preview: 'github.com/RAKKUNN/DualClip', kind: 'link' },
    { id: 'B', shortcut: ['⌥', '⌘', 'C'], paste: ['⌥', '⌘', 'V'], preview: 'const handlePaste = async () => {\n  const text = await navigator.clipboard.readText()', kind: 'code' },
    { id: 'C', shortcut: ['⌃', '⌘', 'C'], paste: ['⌃', '⌘', 'V'], preview: '— image —', kind: 'image' },
  ];
  return (
    <div className="popover" role="dialog" aria-label="DualClip menu bar popover">
      <div className="popover-header">
        <div className="popover-header-left">
          <div className="popover-app-dot" />
          <span className="popover-app-name">DualClip</span>
        </div>
        <div className="popover-status mono">RAM-only · idle</div>
      </div>
      <div className="popover-slots">
        {slots.map(s => (
          <div key={s.id} data-slot-row={s.id} className={`slot-row ${active === s.id ? 'is-active' : ''}`}>
            <div className="slot-row-left">
              <span className={`slot-chip slot-${s.id}`}>{s.id}</span>
              <div className="slot-content">
                <div className="slot-label mono">Slot {s.id}</div>
                <div className={`slot-preview ${s.kind === 'image' ? 'slot-preview-image' : ''}`}>
                  {s.kind === 'image' ? (
                    <div className="slot-image-thumb">
                      <span className="slot-image-bars" />
                      <span className="mono">PNG · 1.2 MB</span>
                    </div>
                  ) : (
                    <span className="mono">{s.preview}</span>
                  )}
                </div>
              </div>
            </div>
            <div className="slot-row-right">
              <Shortcut keys={s.paste} sm />
            </div>
          </div>
        ))}
      </div>
      <div className="popover-footer">
        <div className="footer-hint mono">
          <span className="hint-dot" /> Press <Shortcut keys={['⌥','⌘','C']} sm/> to stash · <Shortcut keys={['⌥','⌘','V']} sm/> to recall
        </div>
      </div>
    </div>
  );
};

const HEADLINE_VARIANTS = {
  "zero-history": <>Three clipboards.<br/><span className="headline-em">Zero history.</span></>,
  "where-not-when": <><span className="headline-em">Where</span>, not when.</>,
  "by-the-letter": <>Stash by the letter.<br/><span className="headline-em">A, B, or C.</span></>,
};

const Hero = ({ headlineVariant = 'zero-history', showShortcuts = true }) => {
  // Renders the first frame only; site.js rotates the highlighted slot.
  const activeSlot = 'A';

  return (
    <header className="hero" data-screen-label="Hero">
      <div className="spotlight" />
      <div className="grain" />
      <Nav />
      <div className="container hero-grid">
        <div className="hero-copy">
          <div className="eyebrow"><span className="dot"/> macOS · Menu bar</div>
          <h1 className="hero-headline">
            {HEADLINE_VARIANTS[headlineVariant] || HEADLINE_VARIANTS["zero-history"]}
          </h1>
          <p className="lede hero-lede">
            DualClip gives you three dedicated clipboard slots — A, B, C — with their own
            keyboard shortcuts. Decide where things go. Recall them instantly. Nothing ever
            touches the disk.
          </p>

          <div className="hero-install">
            <div className="code-block hero-code">
              <span><span className="prompt">$</span><span className="mono">brew install RAKKUNN/tap/dualclip</span></span>
              <CopyButton text="brew install RAKKUNN/tap/dualclip" />
            </div>
            <div className="hero-cta-row">
              <a className="btn btn-primary" href="https://github.com/RAKKUNN/DualClip/releases" target="_blank" rel="noreferrer">
                <Icon.Download size={14}/> Download for macOS
              </a>
              <a className="btn btn-ghost" href="https://github.com/RAKKUNN/DualClip" target="_blank" rel="noreferrer">
                <Icon.Github size={14}/> View source
              </a>
            </div>
          </div>

          <div className="hero-meta mono">
            <span><Icon.Lock size={12}/> MIT licensed</span>
            <span className="meta-dot"/>
            <span>macOS 13+</span>
            <span className="meta-dot"/>
            <span>Universal binary</span>
          </div>
        </div>

        <div className="hero-visual" aria-hidden="false">
          <div className="hero-menubar">
            <div className="menubar-bar">
              <span className="menubar-apple">
                <svg width="13" height="14" viewBox="0 0 17 20" fill="currentColor"><path d="M13.97 10.6c-.02-2.43 1.99-3.6 2.08-3.65-1.13-1.66-2.9-1.89-3.53-1.91-1.5-.15-2.93.88-3.69.88-.77 0-1.94-.86-3.19-.84-1.64.02-3.16.96-4 2.42-1.71 2.97-.44 7.36 1.23 9.78.81 1.18 1.78 2.5 3.04 2.46 1.22-.05 1.69-.79 3.16-.79 1.47 0 1.89.79 3.18.77 1.31-.02 2.14-1.2 2.95-2.39.93-1.37 1.32-2.71 1.34-2.78-.03-.01-2.56-.98-2.58-3.95M11.5 3.41c.68-.82 1.13-1.96 1.01-3.1-.97.04-2.16.65-2.86 1.47-.62.72-1.17 1.88-1.02 3 1.08.08 2.19-.55 2.87-1.37"/></svg>
              </span>
              <span className="menubar-text">File</span>
              <span className="menubar-text">Edit</span>
              <span className="menubar-text">View</span>
              <span className="menubar-spacer" />
              <span className="menubar-icon-group">
                <span className="menubar-icon menubar-icon--app" aria-label="DualClip menu bar icon">
                  <span className="menubar-pill">
                    <span className="menubar-pill-half" />
                  </span>
                </span>
                <span className="menubar-icon">
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/></svg>
                </span>
                <span className="menubar-icon mono menubar-time">10:12</span>
              </span>
            </div>
            <div className="menubar-arrow" />
            <MenuBarPopover active={activeSlot} />
          </div>
          {showShortcuts && <div className="hero-shortcuts">
            <div className="shortcut-card">
              <div className="shortcut-card-label mono">copy →</div>
              <div className="shortcut-card-keys"><Shortcut keys={['⌘','C']}/></div>
              <div className="shortcut-card-slot"><span className="slot-chip slot-A">A</span></div>
            </div>
            <div className="shortcut-card">
              <div className="shortcut-card-label mono">copy →</div>
              <div className="shortcut-card-keys"><Shortcut keys={['⌥','⌘','C']}/></div>
              <div className="shortcut-card-slot"><span className="slot-chip slot-B">B</span></div>
            </div>
            <div className="shortcut-card">
              <div className="shortcut-card-label mono">copy →</div>
              <div className="shortcut-card-keys"><Shortcut keys={['⌃','⌘','C']}/></div>
              <div className="shortcut-card-slot"><span className="slot-chip slot-C">C</span></div>
            </div>
          </div>}
        </div>
      </div>
    </header>
  );
};

const Nav = () => (
  <nav className="nav container">
      <a className="nav-brand" href="#top">
        <img src="assets/icon.png" alt="DualClip" width="28" height="28" className="nav-icon"/>
        <span className="nav-name">DualClip</span>
      </a>
      <div className="nav-links">
        <a href="#how">How it works</a>
        <a href="#features">Features</a>
        <a href="#compare">vs History</a>
        <a href="#install">Install</a>
      </div>
      <div className="nav-actions">
        {/* Both icons ship; CSS shows the one matching :root[data-theme]. */}
        <button className="nav-theme" data-theme-toggle aria-label="Toggle theme">
          <span className="theme-icon theme-icon-sun"><Icon.Sun size={14}/></span>
          <span className="theme-icon theme-icon-moon"><Icon.Moon size={14}/></span>
        </button>
        <a className="nav-github" href="https://github.com/RAKKUNN/DualClip" target="_blank" rel="noreferrer">
          <Icon.Github size={16}/>
        </a>
      </div>
    </nav>
);

Object.assign(window, { Hero, Nav, MenuBarPopover });
