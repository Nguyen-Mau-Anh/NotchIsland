# NotchIsland - Comprehensive QA Test Plan

**Version:** 1.0
**Date:** February 10, 2026
**Tester:** QA Agent
**Status:** Prepared (awaiting feature completion)

---

## 1. Test Scope

### Features Under Test (Tasks #1-5)
1. **Task #1:** Album artwork loading fix (Music Widget)
2. **Task #2:** Weather Widget with location-based forecast
3. **Task #3:** Global keyboard shortcut to toggle island
4. **Task #4:** Theme system with light/dark mode toggle
5. **Task #5:** Multiple monitor support for notch detection

### Existing Features (Regression Testing)
- Hover detection and window show/hide
- Music Widget (track info, playback controls, Apple Music + Spotify)
- Calendar Widget (EventKit integration, upcoming events)
- Custom Widget placeholder
- Settings panel (General, Widgets, About)
- Menu bar integration
- Permission management (Accessibility, Calendar, Automation)

---

## 2. Test Categories

### 2.1 Functional Testing
### 2.2 Integration Testing
### 2.3 UI/UX Testing
### 2.4 Performance Testing
### 2.5 Edge Case / Boundary Testing
### 2.6 Regression Testing

---

## 3. Detailed Test Cases

### 3.1 Task #1: Album Artwork Loading Fix

| ID | Test Case | Steps | Expected Result | Priority |
|----|-----------|-------|-----------------|----------|
| ART-001 | Apple Music artwork loads | 1. Play a song in Music.app 2. Hover over notch | Album artwork displays in 60x60 area | P0 |
| ART-002 | Spotify artwork loads | 1. Play a song in Spotify 2. Hover over notch | Album artwork displays in 60x60 area | P0 |
| ART-003 | Artwork updates on track change | 1. Play music 2. Skip to next track | Artwork updates to new track's artwork | P0 |
| ART-004 | Missing artwork fallback | 1. Play a track with no artwork | Music note placeholder icon shown | P1 |
| ART-005 | Artwork caching | 1. Play a track 2. Switch tabs 3. Switch back | Artwork loads instantly from cache | P1 |
| ART-006 | Large artwork handling | 1. Play track with very high-res artwork | Artwork scales properly within 60x60 frame | P2 |
| ART-007 | Artwork with pipe character in metadata | 1. Play track with "|" in title/artist/album | Track info parses correctly, no crash | P1 |
| ART-008 | Rapid track switching | 1. Quickly skip 5+ tracks in succession | Final track's artwork displays correctly | P2 |
| ART-009 | Music app quit during playback | 1. Play music 2. Quit Music.app | Widget shows "No music playing" gracefully | P1 |
| ART-010 | Both apps running | 1. Open both Music.app and Spotify | Priority source (Music.app first) shows correctly | P2 |

### 3.2 Task #2: Weather Widget

| ID | Test Case | Steps | Expected Result | Priority |
|----|-----------|-------|-----------------|----------|
| WEA-001 | Weather data loads | 1. Open weather widget tab | Current temperature and conditions display | P0 |
| WEA-002 | Location permission request | 1. First launch with no location permission | Permission prompt shown, handled gracefully | P0 |
| WEA-003 | Location permission denied | 1. Deny location permission | Fallback message or manual location entry | P1 |
| WEA-004 | Forecast display | 1. View weather widget | 3-6 hour forecast shown | P0 |
| WEA-005 | Weather icon/animation | 1. View weather in different conditions | Appropriate icon/animation for conditions | P1 |
| WEA-006 | Auto-refresh (30 min) | 1. Leave widget open 2. Wait 30+ min | Data refreshes automatically | P1 |
| WEA-007 | No internet connection | 1. Disable network 2. View weather widget | Graceful error message, cached data if available | P1 |
| WEA-008 | API rate limiting | 1. Trigger many refreshes | Handles rate limiting gracefully | P2 |
| WEA-009 | Temperature units | 1. Check temperature display | Correct unit for locale (F/C) | P1 |
| WEA-010 | Widget tab integration | 1. Switch between Music/Calendar/Weather tabs | Weather tab appears in tab bar and switches correctly | P0 |

### 3.3 Task #3: Global Keyboard Shortcut

| ID | Test Case | Steps | Expected Result | Priority |
|----|-----------|-------|-----------------|----------|
| KEY-001 | Default shortcut toggles island | 1. Press default keyboard shortcut | Island shows if hidden, hides if shown | P0 |
| KEY-002 | Shortcut works in any app | 1. Focus on different app 2. Press shortcut | Island toggles regardless of focused app | P0 |
| KEY-003 | Shortcut works in fullscreen | 1. Enter fullscreen app 2. Press shortcut | Island toggles over fullscreen app | P1 |
| KEY-004 | Shortcut customization | 1. Open settings 2. Change shortcut | New shortcut works, old one doesn't | P1 |
| KEY-005 | Conflict detection | 1. Set shortcut that conflicts with system | Warning shown, conflict handled | P2 |
| KEY-006 | Shortcut with modifiers | 1. Set shortcut with Cmd+Shift+key | Modifier combination works correctly | P1 |
| KEY-007 | Rapid toggle | 1. Press shortcut rapidly multiple times | No flickering, final state is correct | P2 |
| KEY-008 | Shortcut persists after restart | 1. Set custom shortcut 2. Restart app | Custom shortcut still works | P1 |
| KEY-009 | Disable shortcut | 1. Disable keyboard shortcut in settings | Shortcut no longer triggers toggle | P2 |
| KEY-010 | Shortcut + hover interaction | 1. Show via shortcut 2. Move mouse away from notch | Behavior is consistent (check if auto-hide still works) | P1 |

### 3.4 Task #4: Theme System (Light/Dark Mode)

| ID | Test Case | Steps | Expected Result | Priority |
|----|-----------|-------|-----------------|----------|
| THM-001 | Dark mode default | 1. Launch app | Dark theme applied by default | P0 |
| THM-002 | Toggle to light mode | 1. Open settings 2. Switch to light mode | All UI elements update to light theme | P0 |
| THM-003 | Toggle back to dark mode | 1. Switch from light to dark | All UI elements revert to dark theme | P0 |
| THM-004 | Theme persists after restart | 1. Set light mode 2. Restart app | Light mode still active | P0 |
| THM-005 | Follow system appearance | 1. Set to "Follow System" 2. Change macOS appearance | App follows system setting | P1 |
| THM-006 | Theme applies to all widgets | 1. Switch theme 2. Check each widget | Music, Calendar, Weather, Custom all themed correctly | P0 |
| THM-007 | Theme applies to settings | 1. Switch theme 2. Open settings | Settings window reflects theme | P1 |
| THM-008 | Theme transition animation | 1. Toggle theme | Smooth transition, no jarring flash | P2 |
| THM-009 | Text readability in light mode | 1. Switch to light mode | All text is readable against light background | P0 |
| THM-010 | Accent colors | 1. Check interactive elements in both themes | Accent colors appropriate for each theme | P1 |

### 3.5 Task #5: Multiple Monitor Support

| ID | Test Case | Steps | Expected Result | Priority |
|----|-----------|-------|-----------------|----------|
| MON-001 | Notch detected on built-in display | 1. Use MacBook Pro with notch 2. Hover notch | Island appears on built-in display | P0 |
| MON-002 | External monitor without notch | 1. Connect external monitor 2. Hover top center | Island does NOT appear on external display | P0 |
| MON-003 | External monitor as primary | 1. Set external as primary 2. Hover built-in notch | Island still appears on built-in display (has notch) | P0 |
| MON-004 | Hot-plug monitor | 1. App running 2. Connect/disconnect monitor | App adapts correctly, no crash | P1 |
| MON-005 | Lid closed (clamshell mode) | 1. Close MacBook lid with external display | Island does not appear (no notch on external) | P1 |
| MON-006 | Multiple external monitors | 1. Connect 2+ external monitors | Island only on screen with notch | P1 |
| MON-007 | Screen arrangement changes | 1. Change display arrangement in System Settings | Island repositions correctly | P2 |
| MON-008 | Resolution/scaling changes | 1. Change display resolution/scaling | Island position and size remain correct | P2 |
| MON-009 | Mirror displays mode | 1. Enable display mirroring | Island appears correctly | P2 |
| MON-010 | NSScreen.screens detection | 1. Verify notch detection logic | Uses correct screen properties to find notch | P0 |

---

## 4. Regression Test Cases

| ID | Test Case | Steps | Expected Result | Priority |
|----|-----------|-------|-----------------|----------|
| REG-001 | Hover show/hide still works | 1. Hover near notch 2. Move mouse away | Island shows and hides with animation | P0 |
| REG-002 | Music widget track display | 1. Play music 2. Hover notch | Track title and artist display correctly | P0 |
| REG-003 | Music playback controls | 1. Click play/pause, next, previous | Controls work correctly | P0 |
| REG-004 | Calendar events display | 1. Have calendar events 2. View calendar widget | Events show with time, duration, location | P0 |
| REG-005 | Calendar permission flow | 1. Reset calendar permissions 2. View calendar | Permission request appears correctly | P1 |
| REG-006 | Widget tab switching | 1. Click between Music/Calendar/Custom tabs | Tabs switch with animation, no flicker | P0 |
| REG-007 | Menu bar icon | 1. Check menu bar | NotchIsland icon present in menu bar | P0 |
| REG-008 | Menu bar > Settings | 1. Click menu bar icon 2. Click Settings | Settings window opens | P1 |
| REG-009 | Menu bar > Quit | 1. Click menu bar icon 2. Click Quit | App terminates cleanly | P1 |
| REG-010 | Settings persistence | 1. Change settings 2. Restart app | Settings are retained | P1 |
| REG-011 | App hides from Dock | 1. Launch app | No Dock icon visible | P0 |
| REG-012 | Accessibility permission prompt | 1. First launch without accessibility | Permission prompt shown | P1 |
| REG-013 | Hide timer delay | 1. Hover notch 2. Move away slowly | 0.5s delay before hiding (no flicker) | P1 |
| REG-014 | Window positioning | 1. Show island | Centered below notch, 40px from top | P0 |
| REG-015 | Window stays on top | 1. Show island 2. Click on another window | Island remains visible on top | P1 |

---

## 5. Integration Test Cases

| ID | Test Case | Steps | Expected Result | Priority |
|----|-----------|-------|-----------------|----------|
| INT-001 | Weather + Theme integration | 1. Set light mode 2. View weather widget | Weather widget themed correctly | P1 |
| INT-002 | Keyboard shortcut + Theme | 1. Toggle island via shortcut 2. Toggle theme | Both features work together | P1 |
| INT-003 | Multi-monitor + Keyboard shortcut | 1. Use external monitor 2. Press shortcut | Island appears on correct screen (with notch) | P1 |
| INT-004 | All new widgets in tab bar | 1. View tab bar | All widgets (Music, Calendar, Weather, Custom) accessible | P0 |
| INT-005 | Theme + Album artwork | 1. Switch themes 2. View music with artwork | Artwork displays correctly in both themes | P1 |
| INT-006 | Settings reflect new features | 1. Open settings | New feature settings (theme, shortcut, etc.) present | P0 |
| INT-007 | New features + hover detection | 1. Use all new features 2. Test hover show/hide | Hover detection unaffected by new features | P0 |

---

## 6. Performance Test Criteria

| Metric | Target | Method |
|--------|--------|--------|
| CPU idle usage | < 5% | Activity Monitor observation over 5 min |
| CPU active usage (island visible) | < 15% | Activity Monitor during interaction |
| Memory footprint | < 100MB | Activity Monitor observation |
| Show animation latency | < 300ms | Visual inspection |
| Hide animation latency | < 200ms | Visual inspection |
| Keyboard shortcut response | < 100ms | Perceived latency test |
| Weather data fetch time | < 3s | Time from tab switch to data display |
| Artwork load time | < 2s | Time from track change to artwork display |
| Theme switch time | < 500ms | Visual inspection |
| App launch time | < 3s | Stopwatch from click to menu bar icon |

---

## 7. Edge Cases & Boundary Conditions

| ID | Scenario | Expected Behavior |
|----|----------|-------------------|
| EDGE-001 | No internet connection | Weather fails gracefully, other features work |
| EDGE-002 | No music apps installed | Music widget shows "No music playing" |
| EDGE-003 | MacBook without notch (pre-2021) | App handles absence of notch gracefully |
| EDGE-004 | Very long track title (100+ chars) | Title truncated with ellipsis |
| EDGE-005 | Track metadata with special characters (emoji, unicode) | Displays correctly |
| EDGE-006 | 50+ calendar events | Only shows first 3 in widget, no performance issue |
| EDGE-007 | System under heavy load | Island still responds within 500ms |
| EDGE-008 | Sleep/wake cycle | App recovers correctly, timers restart |
| EDGE-009 | Fast user switching | App behaves correctly when switching users |
| EDGE-010 | Low disk space | App still functions (weather cache may fail) |
| EDGE-011 | macOS Sonoma vs older versions | Calendar permission API compatibility |
| EDGE-012 | Shortcut key already used by another app | Behavior is defined (either override or warn) |

---

## 8. Test Execution Tracking

### Status Legend
- [ ] Not Started
- [~] In Progress
- [x] Passed
- [!] Failed (with bug ID)
- [-] Blocked
- [S] Skipped (with reason)

### Execution will be tracked in Section 9 below after tasks complete.

---

## 9. Test Results (To be filled during execution)

*Awaiting completion of Tasks #1-5*

---

## 10. Pre-existing Issues Identified During Code Review

| ID | Issue | Severity | File | Line(s) |
|----|-------|----------|------|----------|
| PRE-001 | `getMusicAppArtwork()` returns nil (hardcoded) | Known Bug | MusicManager.swift | 104-108 |
| PRE-002 | Settings not persisted to UserDefaults (all @State, no @AppStorage) | Medium | SettingsView.swift | 11-15 |
| PRE-003 | Hover sensitivity slider not wired to actual detection logic | Medium | SettingsView.swift:64 + NotchIslandApp.swift:75 |  |
| PRE-004 | Auto-hide delay slider not wired to NotchWindow hide timer | Medium | SettingsView.swift:85 + NotchWindow.swift:84 |  |
| PRE-005 | Hardcoded notch dimensions (740x32) may not fit all MacBook models | Low | NotchIslandApp.swift | 87-89 |
| PRE-006 | `togglePlayPause` sends commands to BOTH Music and Spotify | Low | MusicManager.swift | 172-193 |
| PRE-007 | Track metadata with "|" character would break parsing | Medium | MusicManager.swift | 79, 128 |
| PRE-008 | `getSpotifyArtwork()` does synchronous network fetch on main thread | Medium | MusicManager.swift | 160-162 |
| PRE-009 | Widget enable/disable toggles in settings not connected to actual widget display | Medium | SettingsView.swift + NotchIslandView.swift |  |
| PRE-010 | `NSWindow.CollectionBehavior` includes `.fullScreenAuxiliary` but may not work over all fullscreen apps | Low | NotchWindow.swift | 31 |

---

## 11. Recommendations (Pre-testing)

1. **Settings persistence is critical** - PRE-002 through PRE-004 mean users can't actually configure the app. Theme and shortcut settings from Tasks #3-4 must use `@AppStorage` or similar.
2. **The pipe character delimiter** in AppleScript metadata parsing (PRE-007) is a real risk - track titles containing "|" would corrupt data.
3. **Synchronous network fetch** for Spotify artwork (PRE-008) could freeze the UI.
4. **Widget enable/disable toggles** (PRE-009) are cosmetic only - toggling them does nothing. New widgets should respect these settings.

---

**Document prepared by:** QA Tester Agent
**Next action:** Execute test plan once Tasks #1-5 are complete
