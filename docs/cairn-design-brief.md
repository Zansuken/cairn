# Cairn — Design Brief

A handoff brief for the Claude Design session. Captures the product, brand world, tone, design principles, and the full screen inventory. Visual specifics (final palette, mascot illustration, layouts) are Design's job — this brief gives them a real starting point instead of a blank page.

---

## 1. What Cairn is

A calm Android app that grows a **streak for the days you *don't* open an app you can't quit.** Each clean day adds a stone to a little cairn. It's for people who genuinely use (and don't want to delete) an app but want to master it — not a blocker, not a nanny. It supports a decision the user already made for themselves.

**One-liner:** *A streak for the days you don't open the app you can't quit — no blocking, no subscriptions, nothing leaves your phone.*

**Positioning order:** lead with the streak reframe → speak to "the app you can't delete but want to master" → privacy/honesty as the trust layer underneath.

---

## 2. Brand world — the cairn metaphor

The name maps onto the whole mechanic, and Design should lean into this:

- **One stone per clean day** → the streak builds, stone by stone.
- **The cairn grows taller** → quiet, visible progress.
- **Knock it over (a slip)** → the stack resets, *but the trail you've already walked stays behind you* → that's the lifetime clean-days total.
- **One cairn per app** → per-app streaks; the whole marked trail → the global meta-streak.
- **Uninstalling an app** → you've summited; plant a final marker → the "Freed" trophy is a *summit cairn*.

**Tagline candidates (pick in Design):**
- "One stone a day."
- "Build something by leaving it alone."
- "Mark the days you stayed away."
- "Your trail, one clean day at a time."

---

## 3. Mascot

**The living cairn** — a friendly stack of stones with a face. It does triple duty: mascot, logo, *and* progress visualization, because the stack literally grows taller as the streak grows.

**Illustration style (locked):** soft rounded, subtly tactile — smooth pebbles with gentle shading and a deliberately minimal face (dot eyes, simple mouth). "Cute but calm," never hyper-kawaii or manic. Must stack/grow modularly (a stone per clean day), survive shrinking to app-icon size, and keep the face minimal so expression states are quick to vary.

Expression states for Design to explore:
- **Building** — content, steady, gaining a stone.
- **Milestone** — quietly proud (not manic).
- **Slip/reset** — gentle, not sad-shaming; "we start a new stack, the trail remains."
- **Freed (summit)** — a small flag/marker planted; the celebratory peak state.

**Assets produced (transparent PNGs, ready to import into Design):** `cairn_building` (content, eyes open), `cairn_proud` (eyes closed), `cairn_reset` (top stone resting beside the stack), `cairn_summit` (5-stone + flag), `cairn_icon` (app icon), and three **modular single stones** — `stone_sand`, `stone_grey`, `stone_sage` — for the streak-growth animation (stack one per clean day). Note: the generated set drifted slightly cooler than the first concept; standardize exact hex in the design system rather than eyedropping the renders.

---

## 4. Tone of voice

Calm, honest, quietly proud, respectful of the adult using it. Encouraging without being loud; celebratory without being manic.

- Say: "Nice. Day 14." / "Run ended — your trail is still 47 days long." / "You haven't opened TikTok in 3 weeks."
- Never: "🔥🔥 STREAK ON FIRE", "Don't lose your streak!!", "We miss you 🥺", manufactured urgency or FOMO.

---

## 5. Design principles

1. **Calm and unsticky.** Open, glance, feel good, close. Give no reason to linger. "The best session is a short one."
2. **Bounded, outcome-tied reward.** Reward staying clean; never reward opening *this* app, never create reasons to grind or refresh.
3. **Honest above all.** Never imply a day is clean when it isn't. The metric's integrity is the brand.
4. **Respect agency.** Inform and nudge; never block, shame, or coerce. Even the (later) intervention has a real "Open anyway."
5. **On-device pride.** Privacy isn't fine print — it's a visible, earned trust signal.

**Palette (locked direction):** earthy and natural, **dark-first** — a dark/muted canvas with stone greys, warm sand, and a single quiet natural accent (sage or sky). Light mode is the polished secondary. The earthy tones *are* the metaphor and read as calm rather than stimulating; leading dark keeps the app from feeling like a bright, dopamine-y surface. Design picks exact values. Note: this is a *new* brand, distinct from getfolio's teal-green/chameleon.

**Anti-patterns to avoid:** red "at-risk" fear states, confetti spam, infinite-scroll stats, badge-grind treadmills, any hard-block UI.

---

## 6. Screen inventory

Tags: **[v1]** ships first · **[Later]** design now for visual consistency, feature lands later · **[Exploratory]** vibe-only, mechanics not yet locked.

### Onboarding (first run)
1. **Welcome + how it works** [v1] — the pitch, meet the living cairn. 1–2 light slides. Sets the calm tone immediately.
2. **Permission primer** [v1] — sell *why* Usage Access is needed (count clean days, stays on-device), then the button into system settings. Make-or-break screen; warmth and clarity matter more than anywhere else.
3. **Pick your apps** [v1] — curated suggestions (TikTok, Instagram, YouTube, X, Reddit, Snapchat…) + search all installed + the "start with 1–3" nudge. No hard cap.
4. **All set / first stone placed** [v1] — confirmation that flows into Home; the first cairn appears.

### Core
5. **Home / dashboard** [v1] **(hero)** — global meta-streak, today's in-progress status ("Day 12 — still clean"), the grid/list of per-app cairns, lifetime total + best record. Calm, scannable, nothing to grind.
6. **App detail** [v1] — one app's cairn up close: current streak, best record, lifetime clean days, a simple history, edit/remove, and the "Freed" state if uninstalled.
7. **Manage / add apps** [v1] — the picker again, post-onboarding; edit the tracked list.
8. **Settings** [v1] — day reset hour (default 4 AM, configurable), notifications (on/off, time, milestones), analytics opt-out, about.
9. **Privacy / About** [v1] — the on-device + open-source story as a trust asset; links to GitHub repo, F-Droid, and a tip-jar placeholder (non-gating).

### Moments (modals / overlays)
10. **Streak reset / slip** [v1] **(tone-critical)** — gentle and honest: "run ended — lifetime total still N." This is where the "what-the-hell" spiral is defused; never shaming.
11. **Milestone celebration** [v1] — 7 / 30 / 100 days. Bounded and calm; proud, not manic.
12. **"Freed" trophy** [v1] — the summit-cairn uninstall moment; the most shareable screen. Make it feel earned.

### States
13. **Empty state** [v1] — no apps tracked yet; warm invitation to add the first.
14. **Permission lost / re-grant** [v1] — if Usage Access gets revoked. Ties to the "unverified days, never falsely clean" rule — explain honestly, route to re-grant.

### Later / exploratory
15. **Daily summary recap** [Later] — a recap view behind the morning notification (notification alone covers v1).
16. **Intervention speed bump** [Later] — first fast-follow: a brief pause + honest reminder of the stake + a real "Open anyway." Non-blocking, respectful. Design now for consistency.
17. **Stats / history deep-dive, themes, tip-jar, accountability-buddy** [Later / Exploratory] — stats & themes are straightforward later screens; **buddy screens are exploratory only** (share streak *status*, never which apps or usage) since the feature's mechanics aren't locked.

---

## 7. Locked product decisions (context for Design)

- **Platform:** Android-only v1 (Flutter UI + Kotlin detection).
- **Success = zero opens** per app per day. Streak counts completed clean days; current day shows live in-progress.
- **Day rolls over at 4 AM** (configurable).
- **Slip → honest hard reset**, but best-ever record preserved + ever-growing lifetime clean-days total.
- **Per-app streaks (hero) + global "perfect days" meta-streak.**
- **Free** (optional non-gating tip later). No ads, ever.
- **Notifications:** one honest daily summary + earned milestones. No re-engagement/FOMO.
- **Analytics:** minimal, anonymous, transparent; sensitive data never leaves the device.
- **Distribution:** Play Store (primary) + open source + F-Droid.
- **Roadmap:** skeleton → intervention speed bump → stats/themes → accountability buddy.