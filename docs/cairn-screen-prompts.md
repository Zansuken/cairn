# Cairn — Claude Design screen prompts

Paste these into Claude Design **one at a time**, in order. Review each, iterate with chat (broad changes) and inline comments (small tweaks), then move to the next. Every prompt assumes the **locked design system** and the **official mascot PNGs** are loaded — reference them, never let Claude redraw the mascot.

Global context (already set, restated for safety): *Cairn, mobile, Android, dark-first earthy palette, calm and unsticky, honest, respects user agency.*

---

## Core

### 1. Home / dashboard (hero — get this right first)
```
Build the Home screen for Cairn (mobile, Android, dark-first, locked design system).
Show: the global "clean days" meta-streak as the top focal number; today's
in-progress status ("Day 12 — still clean"); a scrollable list of per-app cairns
where each row shows the app, its current streak, and a small stacked-stone visual
(use stone_sand/grey/sage) whose height reflects streak length; and lifetime total
+ best record. Calm, scannable, nothing to grind on. Use the attached mascot assets.
Show me 2–3 layout options for the per-app list.
```

### 2. App detail
```
Build the App detail screen: one tracked app's cairn up close. Show current streak,
best record, lifetime clean days, and a simple history (e.g. a month of dots:
clean / slipped / unverified). Include edit and "stop tracking" actions. Reserve a
"Freed" state for when the app has been uninstalled (summit cairn + flag, celebratory).
Use cairn_building/summit assets. Same calm dark-first system.
```

### 3. Manage / add apps
```
Build the Manage Apps screen: the current tracked list (edit/remove), plus an
"add app" entry point that opens a picker with curated suggestions (TikTok,
Instagram, YouTube, X, Reddit, Snapchat) and a search field for all installed apps.
Include the gentle "most people start with 1–3 apps" guidance. No hard cap.
```

---

## Onboarding

### 4. Welcome + how it works
```
Build a 2-slide onboarding intro for Cairn. Slide 1: the pitch — "A streak for the
days you don't open the app you can't quit." Meet the mascot (use cairn_building).
Slide 2: how it works in one calm sentence — zero opens = a clean day, on-device,
no blocking. Minimal, warm, dark-first. A single quiet "Continue" action.
```

### 5. Permission primer (make-or-break)
```
Build the Usage Access permission screen. Plain-language sell of WHY it's needed:
"To count your clean days, Cairn needs to see which apps you open — this never
leaves your phone." Reassure on privacy. One clear primary button ("Grant access")
that implies opening system settings, and a secondary "Why?" expandable. Warm,
trustworthy, not alarming. Use the mascot reassuringly.
```

### 6. Pick your apps
```
Build the first-run "Pick your apps" screen: curated app suggestions as tappable
chips/cards + a search for all installed apps + the "start with 1–3" nudge.
Selected apps preview as small cairns forming. Continue button. Calm, dark-first.
```

### 7. All set / first stone
```
Build the onboarding completion screen: confirmation that the first stone is placed
and tracking has begun, mascot in a content state (cairn_building), one "Start"
button into Home. Quietly celebratory, not loud.
```

---

## Moments (modals / overlays)

### 8. Streak reset / slip (tone-critical)
```
Build the slip/reset modal. Honest and gentle: the app's streak resets, but
emphasize "your trail is still N clean days" (lifetime total preserved) and best
record. Mascot in the reset state (cairn_reset) — calm, reassuring, never shaming.
Framing: "Run ended — a new stack starts now." One soft acknowledge button.
```

### 9. Milestone celebration
```
Build a milestone modal for 7 / 30 / 100 clean days. Bounded and calm — quietly
proud, not manic, no confetti spam. Mascot in the proud state (cairn_proud), the
milestone number, a one-line affirmation, a single dismiss action.
```

### 10. Freed trophy
```
Build the "Freed" celebration shown when a tracked app is uninstalled entirely —
the ultimate win. Summit cairn with a planted flag (cairn_summit), a warm
"You're free of [app]" message, framed as graduation not loss. The most shareable
screen — include a subtle, optional share action. Serene, earned, not flashy.
```

---

## States

### 11. Empty state
```
Build the Home empty state (no apps tracked yet): a warm, inviting prompt to add
the first app, mascot present (cairn_building), one clear "Choose an app" action.
Calm, encouraging, dark-first.
```

### 12. Permission lost / re-grant
```
Build the "permission needed" recovery screen for when Usage Access has been
revoked. Explain honestly that without it, days can't be verified (they'll show as
"unverified," never falsely clean). Reassure, then a clear "Re-enable access"
action. Non-alarming, trustworthy tone.
```

---

## Settings & meta

### 13. Settings
```
Build the Settings screen: day reset hour (default 4:00 AM, configurable);
notifications (on/off, daily summary time, milestone toggles); analytics opt-out
(anonymous, transparent); and an About entry. Clean, minimal, dark-first. No
dark-pattern toggles or nags.
```

### 14. Privacy / About
```
Build the Privacy/About screen as a trust asset: plain statement that usage data
and which apps you track never leave the device; links to the open-source repo and
F-Droid; a non-gating "support the dev" tip option; version info. Calm and honest.
```

---

## Later (design now for visual consistency)

### 15. Daily summary recap
```
Build the daily summary recap screen (the view behind the morning notification):
yesterday's result per app (clean / reset), current streaks, lifetime total.
Glanceable, calm, leave-quickly. Mascot optional and subtle.
```

### 16. Intervention speed bump (first fast-follow)
```
Build the intervention "speed bump" overlay shown the moment a blocked app opens:
a brief calming pause, an honest reminder of the stake ("You're on a 12-day [app]
streak — continuing ends it"), and TWO real choices: "Stay strong" (primary) and a
genuine "Open anyway" (secondary, never hidden). Respectful, non-blocking, never
shaming. Mascot present, calm.
```

---

### Working tips
- Build Home fully and lock its patterns first; later screens should reuse its components.
- Chat = structural/aesthetic changes; inline comments = small targeted tweaks.
- Ask Claude to review contrast/accessibility on the dark palette periodically.
- To branch: "save what we have and try a different approach."
- When the set is locked: Export → Handoff to Claude Code, then have Claude Code translate the HTML/CSS into Flutter widgets.