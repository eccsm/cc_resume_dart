// Verifies WCAG AA contrast (4.5:1 for body-size text) for every
// text-on-background token pair in the design system. Exits non-zero on
// failure so it can gate CI. Keep the pairs in sync with global.css.

const themes = {
  light: {
    bg: '#fafaf8',
    surface: '#ffffff',
    text: '#1a1a1a',
    muted: '#5a5f6a',
    accent: '#96610b',
    accentFill: '#e8a33d',
    onAccent: '#1a1a1a',
    chipBg: '#efefec',
    chipText: '#4a4f58',
    success: '#256c43',
    error: '#a53d37',
  },
  dark: {
    bg: '#0f1115',
    surface: '#171a21',
    text: '#e6e6e6',
    muted: '#9aa0aa',
    accent: '#e8a33d',
    accentFill: '#e8a33d',
    onAccent: '#14100a',
    chipBg: '#21252e',
    chipText: '#b8bdc7',
    success: '#7cba93',
    error: '#e08d84',
  },
};

function luminance(hex) {
  const [r, g, b] = [1, 3, 5].map((i) => {
    const c = parseInt(hex.slice(i, i + 2), 16) / 255;
    return c <= 0.03928 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4;
  });
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

function ratio(fg, bg) {
  const [l1, l2] = [luminance(fg), luminance(bg)].sort((a, b) => b - a);
  return (l1 + 0.05) / (l2 + 0.05);
}

let failed = false;
for (const [themeName, t] of Object.entries(themes)) {
  // [label, fg, bg, minimum]. 4.5 = AA body text; 3.0 = large text / UI.
  const pairs = [
    ['body text on bg', t.text, t.bg, 4.5],
    ['body text on surface', t.text, t.surface, 4.5],
    ['muted text on bg', t.muted, t.bg, 4.5],
    ['muted text on surface', t.muted, t.surface, 4.5],
    ['link (accent) on bg', t.accent, t.bg, 4.5],
    ['link (accent) on surface', t.accent, t.surface, 4.5],
    ['button text on accent fill', t.onAccent, t.accentFill, 4.5],
    ['chip text on chip bg', t.chipText, t.chipBg, 4.5],
    ['success text on surface', t.success, t.surface, 4.5],
    ['error text on surface', t.error, t.surface, 4.5],
  ];
  console.log(`\n${themeName} theme`);
  for (const [label, fg, bg, min] of pairs) {
    const r = ratio(fg, bg);
    const ok = r >= min;
    if (!ok) failed = true;
    console.log(
      `  ${ok ? 'PASS' : 'FAIL'}  ${label}: ${r.toFixed(2)}:1 (needs ${min}:1)  ${fg} on ${bg}`
    );
  }
}

if (failed) {
  console.error('\nContrast check FAILED');
  process.exit(1);
}
console.log('\nAll contrast checks passed');
