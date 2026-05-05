/* Sections: Insight, How it works, Features, Demo, Compare, Privacy, Install, Footer */

const Insight = () => (
  <section id="insight" className="section-insight" data-screen-label="Insight">
    <div className="container-narrow insight-inner">
      <div className="eyebrow"><span className="dot"/> The insight</div>
      <h2 className="insight-headline">
        You don&rsquo;t want to remember what you copied.
        <br/>
        <span className="insight-em">You want to decide where it goes.</span>
      </h2>
      <p className="lede insight-lede">
        Clipboard history apps make you scroll. Search. Recognize. They turn a one-key action into
        a small UI puzzle. DualClip flips it: stash deliberately, recall by muscle memory.
      </p>
    </div>
  </section>
);

const HowItWorks = () => {
  const [step, setStep] = React.useState(0);
  React.useEffect(() => {
    const i = setInterval(() => setStep(s => (s + 1) % 3), 3000);
    return () => clearInterval(i);
  }, []);

  const steps = [
    {
      n: '01',
      title: 'Copy to a slot',
      desc: 'Highlight any text, image or file. Press the slot\u2019s copy shortcut. It lands in slot A, B or C.',
      keys: ['⌥','⌘','C'],
      slot: 'B',
      action: 'copy',
    },
    {
      n: '02',
      title: 'Paste from a slot',
      desc: 'Anywhere in macOS, hit the matching paste shortcut. The slot\u2019s contents drop in atomically.',
      keys: ['⌥','⌘','V'],
      slot: 'B',
      action: 'paste',
    },
    {
      n: '03',
      title: '⌘C / ⌘V untouched',
      desc: 'Your normal system clipboard keeps doing its thing. DualClip lives next to it, never on top of it.',
      keys: ['⌘','C'],
      slot: null,
      action: 'system',
    },
  ];

  return (
    <section id="how" className="section-how" data-screen-label="How it works">
      <div className="container">
        <div className="section-head">
          <div className="eyebrow"><span className="dot"/> How it works</div>
          <h2>Two shortcuts per slot. <span className="muted">That&rsquo;s the entire app.</span></h2>
        </div>

        <div className="how-grid">
          <div className="how-stage">
            <HowStage step={step} />
          </div>
          <ol className="how-steps">
            {steps.map((s, i) => (
              <li
                key={i}
                className={`how-step ${i === step ? 'is-active' : ''}`}
                onClick={() => setStep(i)}
              >
                <div className="how-step-num mono">{s.n}</div>
                <div className="how-step-body">
                  <h3>{s.title}</h3>
                  <p>{s.desc}</p>
                  <div className="how-step-foot">
                    <Shortcut keys={s.keys} sm/>
                    {s.slot && <span className={`slot-chip slot-${s.slot}`}>{s.slot}</span>}
                  </div>
                </div>
              </li>
            ))}
          </ol>
        </div>
      </div>
    </section>
  );
};

const HowStage = ({ step }) => {
  // Animated 3-step storyboard
  return (
    <div className={`how-stage-inner step-${step}`}>
      {/* document */}
      <div className="stage-doc">
        <div className="stage-doc-bar"/>
        <div className="stage-doc-line w70"/>
        <div className="stage-doc-line w90"/>
        <div className="stage-doc-line w50">
          <span className={`stage-highlight ${step === 0 ? 'is-on' : ''}`}>const handleCopy = () =&gt; {'{'} ... {'}'}</span>
        </div>
        <div className="stage-doc-line w80"/>
        <div className="stage-doc-line w60">
          <span className={`stage-cursor ${step === 1 ? 'is-on' : ''}`}>|</span>
        </div>
      </div>
      {/* flying packet */}
      <div className={`stage-packet ${step === 0 ? 'fly-out' : step === 1 ? 'fly-in' : 'rest'}`}>
        <span className="slot-chip slot-B">B</span>
        <span className="mono">handleCopy()</span>
      </div>
      {/* slot dock */}
      <div className="stage-dock">
        <div className="stage-slot">
          <span className="slot-chip slot-A">A</span>
          <span className="mono stage-slot-hint">empty</span>
        </div>
        <div className={`stage-slot ${step === 0 || step === 1 ? 'is-loaded slot-b' : ''}`}>
          <span className="slot-chip slot-B">B</span>
          <span className="mono stage-slot-hint">{step === 0 || step === 1 ? 'handleCopy()' : 'empty'}</span>
        </div>
        <div className="stage-slot">
          <span className="slot-chip slot-C">C</span>
          <span className="mono stage-slot-hint">empty</span>
        </div>
      </div>
      {/* system clipboard */}
      <div className={`stage-system ${step === 2 ? 'is-pulse' : ''}`}>
        <div className="stage-system-label mono">⌘C / ⌘V</div>
        <div className="stage-system-content mono">untouched ✓</div>
      </div>
    </div>
  );
};

const Features = () => {
  const features = [
    { icon: <Icon.Slots size={18}/>, title: '3 dedicated slots', desc: 'A, B and C — labelled, isolated, instantly addressable. No history list to scroll.' },
    { icon: <Icon.Keyboard size={18}/>, title: 'Customizable shortcuts', desc: 'Bind copy & paste to any modifier combination. Defaults make sense; rebinds take seconds.' },
    { icon: <Icon.Zap size={18}/>, title: 'Atomic paste · ~150ms', desc: 'DualClip swaps in your slot, pastes, and restores your system clipboard before you blink.' },
    { icon: <Icon.Menubar size={18}/>, title: 'Menu bar popover', desc: 'A peek at what\u2019s in each slot — text, code, or image preview — without leaving the keyboard.' },
    { icon: <Icon.Cpu size={18}/>, title: 'RAM-only', desc: 'Slot contents live in memory. Quit the app or shut down the Mac and they\u2019re gone.' },
    { icon: <Icon.WifiOff size={18}/>, title: 'Zero network', desc: 'No telemetry, no analytics, no cloud, no accounts. The source code says so.' },
  ];
  return (
    <section id="features" className="section-features" data-screen-label="Features">
      <div className="container">
        <div className="section-head">
          <div className="eyebrow"><span className="dot"/> Features</div>
          <h2>Six things, all small, none of them surprises.</h2>
        </div>
        <div className="feature-grid">
          {features.map((f, i) => (
            <div className="feature-card card card-hover" key={i}>
              <div className="feature-icon">{f.icon}</div>
              <h3 className="feature-title">{f.title}</h3>
              <p className="feature-desc">{f.desc}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
};

const Demo = () => {
  const [active, setActive] = React.useState('text');
  return (
    <section id="demo" className="section-demo" data-screen-label="Demo">
      <div className="container">
        <div className="section-head">
          <div className="eyebrow"><span className="dot"/> See it</div>
          <h2>Text, code, images. <span className="muted">Same three keys.</span></h2>
        </div>
        <div className="demo-tabs" role="tablist">
          <button
            role="tab"
            aria-selected={active === 'text'}
            className={`demo-tab ${active === 'text' ? 'is-active' : ''}`}
            onClick={() => setActive('text')}
          >Text demo</button>
          <button
            role="tab"
            aria-selected={active === 'image'}
            className={`demo-tab ${active === 'image' ? 'is-active' : ''}`}
            onClick={() => setActive('image')}
          >Image / rich content</button>
        </div>
        <div className="demo-frame">
          <MacWindow title={active === 'text' ? 'DualClip — text demo' : 'DualClip — image demo'}>
            <div className="demo-media">
              <img
                src={active === 'text' ? 'assets/demo-text.gif' : 'assets/demo-image.gif'}
                alt={active === 'text' ? 'DualClip stashing and recalling three text snippets' : 'DualClip stashing and recalling an image'}
                loading="lazy"
              />
            </div>
          </MacWindow>
        </div>
      </div>
    </section>
  );
};

const Compare = () => {
  const rows = [
    { label: 'Approach', history: 'Time-ordered list', dualclip: 'Three named slots' },
    { label: 'Recall model', history: 'Open UI, scroll, click', dualclip: 'Press one shortcut' },
    { label: 'Disk writes', history: 'Database / SQLite', dualclip: 'None — RAM only' },
    { label: 'Network', history: 'Often telemetry / cloud sync', dualclip: 'None' },
    { label: 'Mental model', history: '"What did I copy earlier?"', dualclip: '"I put that in B."' },
  ];
  return (
    <section id="compare" className="section-compare" data-screen-label="Compare">
      <div className="container">
        <div className="section-head">
          <div className="eyebrow"><span className="dot"/> vs clipboard history</div>
          <h2>Same problem, different shape.</h2>
        </div>
        <div className="compare-table card">
          <div className="compare-row compare-head">
            <div className="compare-cell-label" />
            <div className="compare-cell">
              <div className="compare-col-title">History managers</div>
              <div className="compare-col-sub mono">paste, maccy, raycast, et al.</div>
            </div>
            <div className="compare-cell compare-cell-us">
              <div className="compare-col-title">
                <span className="compare-mark"><img src="assets/icon.png" alt="" width="20" height="20"/></span>
                DualClip
              </div>
              <div className="compare-col-sub mono">slot-based</div>
            </div>
          </div>
          {rows.map((r, i) => (
            <div className="compare-row" key={i}>
              <div className="compare-cell-label mono">{r.label}</div>
              <div className="compare-cell muted">{r.history}</div>
              <div className="compare-cell compare-cell-us">{r.dualclip}</div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
};

const Privacy = () => (
  <section id="privacy" className="section-privacy" data-screen-label="Privacy">
    <div className="container privacy-inner">
      <div className="privacy-copy">
        <div className="eyebrow"><span className="dot"/> Open source</div>
        <h2>Auditable, MIT-licensed, refreshingly boring.</h2>
        <p className="lede">
          Every line of the app is on GitHub. There is no server. There is no analytics endpoint.
          Slot contents live in a Swift array in RAM and are wiped when the process exits. You can
          read the code in an afternoon.
        </p>
        <div className="privacy-ctas">
          <a className="btn btn-primary" href="https://github.com/RAKKUNN/DualClip" target="_blank" rel="noreferrer">
            <Icon.Github size={14}/> Read the source
          </a>
          <a className="btn btn-ghost" href="https://github.com/RAKKUNN/DualClip/blob/main/LICENSE" target="_blank" rel="noreferrer">
            MIT License <Icon.ArrowRight size={14}/>
          </a>
        </div>
      </div>
      <div className="privacy-claims">
        <div className="claim-card card">
          <div className="claim-icon"><Icon.Cpu size={16}/></div>
          <div className="claim-title">No persistence</div>
          <div className="claim-desc mono">// no FileManager, no UserDefaults for slot data</div>
        </div>
        <div className="claim-card card">
          <div className="claim-icon"><Icon.WifiOff size={16}/></div>
          <div className="claim-title">No network</div>
          <div className="claim-desc mono">// app sandbox: outgoing-network entitlement off</div>
        </div>
        <div className="claim-card card">
          <div className="claim-icon"><Icon.Lock size={16}/></div>
          <div className="claim-title">Signed & notarized</div>
          <div className="claim-desc mono">// Developer ID + Apple notarization</div>
        </div>
      </div>
    </div>
  </section>
);

const Install = () => (
  <section id="install" className="section-install" data-screen-label="Install">
    <div className="container-narrow">
      <div className="section-head install-head">
        <div className="eyebrow"><span className="dot"/> Install</div>
        <h2>One command. Or one download.</h2>
      </div>

      <div className="install-card card">
        <div className="install-row">
          <div className="install-row-label">
            <div className="install-row-num mono">01</div>
            <div>
              <div className="install-row-title">Homebrew</div>
              <div className="install-row-sub mono">recommended</div>
            </div>
          </div>
          <div className="code-block install-code">
            <span><span className="prompt">$</span><span className="mono">brew install RAKKUNN/tap/dualclip</span></span>
            <CopyButton text="brew install RAKKUNN/tap/dualclip" />
          </div>
        </div>
        <hr className="hairline"/>
        <div className="install-row">
          <div className="install-row-label">
            <div className="install-row-num mono">02</div>
            <div>
              <div className="install-row-title">Direct download</div>
              <div className="install-row-sub mono">.zip from GitHub releases</div>
            </div>
          </div>
          <a className="btn btn-ghost" href="https://github.com/RAKKUNN/DualClip/releases" target="_blank" rel="noreferrer">
            <Icon.Download size={14}/> Latest release
          </a>
        </div>
        <hr className="hairline"/>
        <div className="install-foot">
          <div className="install-badge">
            <span className="install-badge-icon">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><polyline points="20 6 9 17 4 12"/></svg>
            </span>
            <span>Signed & notarized by Apple</span>
          </div>
          <div className="install-reqs mono">
            <span>macOS 13 (Ventura) or later</span>
            <span className="meta-dot"/>
            <span>Apple Silicon required</span>
          </div>
        </div>
      </div>
    </div>
  </section>
);

const Sponsor = () => (
  <section id="sponsor" className="section-sponsor" data-screen-label="Sponsor">
    <div className="container-narrow sponsor-inner">
      <div className="section-head sponsor-head">
        <div className="eyebrow"><span className="dot"/> Support</div>
        <h2>Like DualClip? <span className="muted">Consider sponsoring.</span></h2>
      </div>
      <p className="lede sponsor-lede">
        DualClip is free, open source, and built by one person. If it saves you time,
        a sponsorship helps keep development going.
      </p>
      <div className="sponsor-card card">
        <iframe
          src="https://github.com/sponsors/RAKKUNN/card"
          title="Sponsor RAKKUNN"
          height="225"
          width="600"
          style={{border: 0, maxWidth: '100%'}}
        />
      </div>
      <div className="sponsor-btn">
        <a className="btn btn-primary" href="https://github.com/sponsors/RAKKUNN" target="_blank" rel="noreferrer">
          <Icon.Heart size={14}/> Sponsor on GitHub
        </a>
      </div>
    </div>
  </section>
);

const Footer = () => (
  <footer className="footer" data-screen-label="Footer">
    <div className="container footer-inner">
      <div className="footer-brand">
        <img src="assets/icon.png" alt="" width="24" height="24"/>
        <span>DualClip</span>
        <span className="footer-tag mono">slots, not history.</span>
      </div>
      <div className="footer-links">
        <a href="https://github.com/RAKKUNN/DualClip" target="_blank" rel="noreferrer">GitHub</a>
        <a href="https://github.com/RAKKUNN/DualClip/blob/main/LICENSE" target="_blank" rel="noreferrer">MIT License</a>
        <a href="https://github.com/RAKKUNN/DualClip/issues" target="_blank" rel="noreferrer">Report an issue</a>
        <a href="https://github.com/RAKKUNN/homebrew-tap" target="_blank" rel="noreferrer">Homebrew tap</a>
      </div>
      <div className="footer-credit mono">
        Built for people who put things places.
      </div>
    </div>
  </footer>
);

Object.assign(window, { Insight, HowItWorks, HowStage, Features, Demo, Compare, Privacy, Install, Sponsor, Footer });
