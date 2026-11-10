<script type="text/x-dc" data-dc-script data-props='{"theme":{"editor":"enum","options":["Blues","Cyberpunk","Sunburst","Earth tones"],"default":"Blues"},"$preview":{"width":1440,"height":1040}}'>
class Component extends DCLogic {
  constructor(props) {
    super(props);
    this.state = { theme: null, left: null, right: null, conn: null };
  }
  renderVals() {
    const T = {
      'Blues': {
        bg: 'radial-gradient(900px 600px at 0% 0%, rgba(59,130,246,0.38), transparent 60%), radial-gradient(800px 600px at 100% 25%, rgba(14,165,233,0.30), transparent 60%), radial-gradient(700px 500px at 50% 100%, rgba(99,102,241,0.28), transparent 60%), #EEF3FB',
        ink: '#0F1A2E', muted: '#4B5873', glass: 'rgba(255,255,255,0.55)', glassBorder: 'rgba(255,255,255,0.8)', solid: 'rgba(255,255,255,0.94)',
        line: '#E1E7F1', track: '#E3EAF4', accent: '#1E4FD8', onAccent: '#FFFFFF', accentSoft: '#E4ECFF', accentText: '#163BA3',
        warn: '#C2410C', warnSoft: '#FFF0E4', warnText: '#9A3412', subtle: 'rgba(241,245,251,0.75)', btnBg: 'rgba(255,255,255,0.75)', btnBorder: '#CFD9EA', bubble: '#E9EFF8', dashed: '#E0A27A',
        invBg: '#0E2350', invInk: '#F2F6FF', invMuted: '#AFC0E0', invBorder: 'rgba(255,255,255,0.14)', invLine: 'rgba(255,255,255,0.12)', invBtn: 'rgba(255,255,255,0.08)', riskLocal: '#4ADE80', riskHybrid: '#FDBA74', riskExposed: '#F87171', swatch: 'linear-gradient(135deg, #3B82F6, #1E3A8A)', flyout: 'rgba(255,255,255,0.82)', shadow: '0 24px 60px rgba(15,26,46,0.22)', onWarn: '#FFFFFF'
      },
      'Cyberpunk': {
        bg: 'radial-gradient(900px 600px at 6% 0%, rgba(255,43,214,0.34), transparent 60%), radial-gradient(800px 600px at 100% 18%, rgba(0,229,255,0.28), transparent 60%), radial-gradient(700px 500px at 55% 100%, rgba(124,58,237,0.36), transparent 60%), #0A0A12',
        ink: '#EDEBFF', muted: '#B3AFD6', glass: 'rgba(24,22,46,0.55)', glassBorder: 'rgba(170,150,255,0.26)', solid: 'rgba(17,16,31,0.92)',
        line: 'rgba(255,255,255,0.10)', track: 'rgba(255,255,255,0.12)', accent: '#00E5FF', onAccent: '#031418', accentSoft: 'rgba(0,229,255,0.14)', accentText: '#7DF3FF',
        warn: '#FF4FB0', warnSoft: 'rgba(255,79,176,0.15)', warnText: '#FFA3D4', subtle: 'rgba(255,255,255,0.05)', btnBg: 'rgba(255,255,255,0.07)', btnBorder: 'rgba(255,255,255,0.20)', bubble: 'rgba(255,255,255,0.08)', dashed: 'rgba(255,79,176,0.6)',
        invBg: '#F1EEFF', invInk: '#14112A', invMuted: '#4A4570', invBorder: 'rgba(20,17,42,0.16)', invLine: 'rgba(20,17,42,0.12)', invBtn: 'rgba(20,17,42,0.06)', riskLocal: '#15803D', riskHybrid: '#D97706', riskExposed: '#B91C1C', swatch: 'linear-gradient(135deg, #FF2BD6, #00E5FF)', flyout: 'rgba(22,20,42,0.84)', shadow: '0 24px 60px rgba(0,0,0,0.55), 0 0 0 1px rgba(0,229,255,0.15)', onWarn: '#1A0612'
      },
      'Sunburst': {
        bg: 'radial-gradient(900px 600px at 0% 0%, rgba(255,183,3,0.42), transparent 60%), radial-gradient(800px 600px at 100% 28%, rgba(251,133,0,0.32), transparent 60%), radial-gradient(700px 500px at 40% 100%, rgba(255,99,72,0.28), transparent 60%), #FFF7EC',
        ink: '#2A1606', muted: '#6B4626', glass: 'rgba(255,250,240,0.55)', glassBorder: 'rgba(255,255,255,0.8)', solid: 'rgba(255,253,248,0.95)',
        line: '#F0E1CC', track: '#F3E4CF', accent: '#C2410C', onAccent: '#FFFFFF', accentSoft: '#FFE8D2', accentText: '#9A3412',
        warn: '#9D174D', warnSoft: '#FCE4EC', warnText: '#831843', subtle: 'rgba(251,241,227,0.75)', btnBg: 'rgba(255,255,255,0.75)', btnBorder: '#EBD2B2', bubble: '#F8EAD7', dashed: '#D58AA6',
        invBg: '#3A1C06', invInk: '#FFF4E6', invMuted: '#E6C7A6', invBorder: 'rgba(255,255,255,0.14)', invLine: 'rgba(255,255,255,0.12)', invBtn: 'rgba(255,255,255,0.08)', riskLocal: '#4ADE80', riskHybrid: '#FDBA74', riskExposed: '#F87171', swatch: 'linear-gradient(135deg, #FFB703, #FB5607)', flyout: 'rgba(255,251,244,0.85)', shadow: '0 24px 60px rgba(42,22,6,0.22)', onWarn: '#FFFFFF'
      },
      'Earth tones': {
        bg: 'radial-gradient(900px 600px at 0% 0%, rgba(122,140,84,0.38), transparent 60%), radial-gradient(800px 600px at 100% 25%, rgba(181,101,64,0.30), transparent 60%), radial-gradient(700px 500px at 50% 100%, rgba(196,164,108,0.38), transparent 60%), #F1EBE0',
        ink: '#2B2A22', muted: '#5C5748', glass: 'rgba(250,246,238,0.55)', glassBorder: 'rgba(255,255,255,0.7)', solid: 'rgba(252,249,243,0.95)',
        line: '#E5DCCB', track: '#EAE2D3', accent: '#4D6B3C', onAccent: '#FFFFFF', accentSoft: '#E4ECD9', accentText: '#3A5230',
        warn: '#A4471F', warnSoft: '#F7E5DA', warnText: '#863915', subtle: 'rgba(243,237,226,0.75)', btnBg: 'rgba(255,255,255,0.7)', btnBorder: '#D8CCB6', bubble: '#EEE7D9', dashed: '#D19A72',
        invBg: '#2C3622', invInk: '#F4F1E8', invMuted: '#CDD0B8', invBorder: 'rgba(255,255,255,0.14)', invLine: 'rgba(255,255,255,0.12)', invBtn: 'rgba(255,255,255,0.08)', riskLocal: '#4ADE80', riskHybrid: '#FDBA74', riskExposed: '#F87171', swatch: 'linear-gradient(135deg, #7A8C54, #B56540)', flyout: 'rgba(251,248,241,0.85)', shadow: '0 24px 60px rgba(43,42,34,0.22)', onWarn: '#FFFFFF'
      }
    };
    const names = ['Blues', 'Cyberpunk', 'Sunburst', 'Earth tones'];
    const current = this.state.theme ?? this.props.theme ?? 'Blues';
    const t = T[current] ?? T['Blues'];
    const themes = names.map((n) => ({
      label: n,
      swatch: T[n].swatch,
      pressed: n === current ? 'true' : 'false',
      ring: n === current ? '0 0 0 2px ' + t.glass + ', 0 0 0 4px ' + t.ink : '0 0 0 1px ' + t.btnBorder,
      pick: () => this.setState({ theme: n })
    }));
    // Edge tool strips: one panel open per side, overlaying the primary focus.
    const sideOf = { db: 'left', log: 'left', tasks: 'right', grade: 'right' };
    const tabs = {};
    Object.keys(sideOf).forEach((key) => {
      const side = sideOf[key];
      const open = this.state[side] === key;
      tabs[key] = {
        open,
        expanded: open ? 'true' : 'false',
        bg: open ? t.accent : t.btnBg,
        fg: open ? t.onAccent : t.ink,
        border: open ? t.accent : t.btnBorder,
        toggle: () => this.setState({ [side]: open ? null : key }),
        close: () => this.setState({ [side]: null })
      };
    });
    // Connections monitor: only hybrid and exposed tiers can be opened.
    const c = this.state.conn;
    const tier = (k) => ({
      [k + 'Open']: c === k,
      [k + 'Expanded']: c === k ? 'true' : 'false',
      [k + 'Bg']: c === k ? t.invBtn : 'transparent',
      [k + 'Border']: c === k ? t.invBorder : 'transparent',
      [k + 'Toggle']: () => this.setState({ conn: c === k ? null : k })
    });
    const conn = Object.assign({ close: () => this.setState({ conn: null }) }, tier('hybrid'), tier('exposed'));
    return { t, themes, tabs, conn };
  }
}
</script>
