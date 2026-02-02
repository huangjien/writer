# Buttons and Menus Design Guide

## Overview

This document establishes consistent rules for displaying buttons and menu items across the application.

---

## Button Types

### Primary Button
- **Use case**: Main action, primary call-to-action (CTA)
- **Style**: Prominent, filled with primary color
- **Examples**: "Sign In", "Create Novel", "Save"
- **Placement**: Bottom of screen, end of form, prominent position
- **Per screen**: Maximum 1-2 primary actions

```dart
AppButtons.primary(
  label: l10n.createNovel,
  onPressed: () {},
)
```

### Secondary Button
- **Use case**: Alternative actions, cancel, dismiss
- **Style**: Outlined or less prominent than primary
- **Examples**: "Cancel", "Reload", "Back"
- **Placement**: Next to primary button, in dialogs, alerts

```dart
AppButtons.secondary(
  label: l10n.cancel,
  icon: Icons.close,
  onPressed: () {},
)
```

### Text Button
- **Use case**: Low-priority actions, tertiary options
- **Style**: Text-only, minimal visual weight
- **Examples**: "Sign Out", "Learn More", "Dismiss"
- **Placement**: Footer, settings sections, inline actions

```dart
AppButtons.text(
  label: l10n.signOut,
  color: Colors.orange,
  onPressed: () {},
)
```

### Icon Button
- **Use case**: Quick access, tool actions, navigation
- **Style**: Icon with tooltip, minimal footprint
- **Examples**: Settings, Search, Menu, Refresh, Add
- **Placement**: AppBar actions, list items, toolbars
- **Ordering** (left to right):
  1. Navigation (Back, Home)
  2. Primary actions (Add, Create)
  3. Utility (Refresh, Search)
  4. Menu/More

```dart
AppButtons.icon(
  iconData: Icons.refresh,
  tooltip: l10n.refreshTooltip,
  onPressed: () {},
)
```

---

## AppBar Button Organization

### Standard AppBar Structure (Left to Right)

```
[Navigation] [Title] [Primary] [Utility] [Utility] [Menu]
   |          |       |         |          |        |
 Back/Home  Screen   Add    Refresh   Search   Menu/More
           Title
```

### Button Ordering Rules

1. **Leading (left side)**:
   - Back button (if in navigation stack)
   - Home button (if at root)
   - Maximum 1 leading button

2. **Actions (right side)**:
   - Primary action (Create, Add) - if single
   - Utility actions (Refresh, Download, PDF)
   - Menu/More trigger
   - Maximum 4-5 action buttons

3. **Disabled state indicators**:
   - Loading spinner (when action in progress)
   - Disabled icon/tooltip

### Example
```dart
AppBar(
  leading: AppButtons.icon(
    iconData: Icons.home,
    tooltip: l10n.home,
    onPressed: () => context.go('/'),
  ),
  title: Text(l10n.settings),
  actions: [
    if (canEdit)
      AppButtons.icon(
        iconData: Icons.add,
        tooltip: l10n.newLabel,
        onPressed: () {},
      ),
    AppButtons.icon(
      iconData: Icons.refresh,
      tooltip: l10n.refreshTooltip,
      onPressed: () {},
    ),
    AppButtons.icon(
      iconData: Icons.menu_open,
      tooltip: l10n.menu,
      onPressed: () => Scaffold.of(context).openDrawer(),
    ),
  ],
)
```

---

## Settings and Lists

### Settings Items

Use `ListTile` with consistent structure:
- **Leading**: Icon (optional)
- **Title**: Setting name (localized)
- **Trailing**: Switch, chevron, or status
- **OnTap**: Navigate or toggle

```dart
ListTile(
  leading: const Icon(Icons.palette),
  title: Text(l10n.colorTheme),
  trailing: const Icon(Icons.chevron_right),
  onTap: () => context.push('/settings/theme'),
)
```

### List Item Actions

- **Primary action**: Tap the entire row
- **Secondary actions**: Trailing icons (Delete, Edit, More)
- **Order**:
  1. Edit/Update
  2. Download/Export
  3. Delete/Remove
  4. More menu (if >3 actions)

---

## Menu Organization

### Main Sidebar (Navigation)

**Section 1: Navigation**
- Home / Library
- Current Novel

**Section 2: Content**
- Chapters
- Characters
- Scenes
- Summaries

**Section 3: Settings**
- Settings

**Section 4: Account**
- Profile
- Sign Out

### More Menus (Overflow)

When action buttons exceed 4-5, move to overflow menu:

```dart
PopupMenuButton<String>(
  onSelected: (value) {
    // Handle selection
  },
  itemBuilder: (context) => [
    PopupMenuItem(
      value: 'export',
      child: Row(
        children: [
          Icon(Icons.download),
          SizedBox(width: 12),
          Text(l10n.export),
        ],
      ),
    ),
    PopupMenuItem(
      value: 'share',
      child: Row(
        children: [
          Icon(Icons.share),
          SizedBox(width: 12),
          Text(l10n.share),
        ],
      ),
    ),
  ],
)
```

### Menu Item Structure

- **Icon**: Left-aligned, consistent size (24px)
- **Label**: Left-aligned, localized text
- **Shortcut**: Right-aligned (optional)
- **Divider**: Group related items

---

## Authentication & Authorization Display Rules

This section defines which buttons and menu items should be displayed based on user authentication state and permissions.

### User States

| State | Description | Key Characteristics |
|-------|-------------|---------------------|
| **Guest** | Not logged in | No cloud sync, offline only |
| **Logged In (Online)** | Authenticated, connected | Full features, cloud sync enabled |
| **Logged In (Offline)** | Authenticated, no connection | Local only, cached data |
| **Admin** | Logged in with admin privileges | All features + admin tools |

---

### Library Screen (Home)

#### Guest Mode
```
[Home] [Library]                       [Search]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Novel List (local only)

                            [Sign In]
```

**Visible:**
- ✓ Home button
- ✓ Search
- ✓ Novel list (local/mock data only)
- ✓ "Sign In" button (prominent, centered)

**Hidden:**
- ✗ Add/Create Novel button
- ✗ Sync indicators
- ✗ Cloud-related actions

#### Logged In (Online)
```
[Home] [Library]  [Create] [Sync]  [Search]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Novel List (cloud + local)
                              [More >]
```

**Visible:**
- ✓ All Guest features
- ✓ Create Novel button
- ✓ Sync/Refresh button
- ✓ Delete from library
- ✓ Cloud status indicator

**Hidden:**
- ✗ "Sign In" button (already logged in)

#### Logged In (Offline)
```
[Home] [Library]            [Retry]  [Search]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Novel List (cached/local)
                              [More >]

⚠ You're offline. Changes will sync when online.
```

**Visible:**
- ✓ All Guest features
- ✓ Retry/Refresh button (for reconnection)
- ✓ Novel list (cached data)
- ✓ Offline banner/indicator
- ✓ Create Novel button (local only)

**Hidden:**
- ✗ Sync button (no connection)
- ✗ Cloud-specific actions

#### Admin
```
[Home] [Library]  [Create] [Sync]  [Search]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Novel List
                              [More >]
                            [User Mgmt]
```

**Visible:**
- ✓ All Logged In features
- ✓ User Management button/link

---

### Settings Screen

#### Guest Mode
```
[Home] [Settings]                       [Refresh]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
> App Settings        [>]
> Color Theme         [>]
> Typography          [>]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
> Reader Bundles
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
> Performance         [>]
> TTS Settings        [>]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                 [Sign In]
```

**Visible:**
- ✓ Home button
- ✓ App Settings (theme, typography, language)
- ✓ Reader Bundles
- ✓ Performance (prefetch, cache)
- ✓ TTS Settings
- ✓ "Sign In" button

**Hidden:**
- ✗ Cloud/Supabase Settings section
- ✗ Token Usage section
- ✗ Admin Mode section
- ✗ Style Guide
- ✗ Sign Out button

#### Logged In (Online/Offline)
```
[Home] [Settings - user@email.com]    [Refresh]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
> App Settings        [>]
> Cloud Sync Settings [>]
> Color Theme         [>]
> Typography          [>]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
> Reader Bundles
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
> Performance         [>]
> TTS Settings        [>]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
> Token Usage         [>]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                [Sign Out]
```

**Visible:**
- ✓ All Guest features
- ✓ User email in title
- ✓ Cloud Sync Settings
- ✓ Token Usage (if available)
- ✓ Sign Out button

**Hidden:**
- ✗ "Sign In" button
- ✗ Admin Mode section (unless admin)

#### Admin
```
[Home] [Settings - admin@email.com]   [Refresh]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
> App Settings        [>]
> Cloud Sync Settings [>]
> Color Theme         [>]
> Typography          [>]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
> Reader Bundles
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
> Performance         [>]
> TTS Settings        [>]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
> Token Usage         [>]
> Admin Mode          [>]
> Style Guide         [>]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                [Sign Out]
```

**Visible:**
- ✓ All Logged In features
- ✓ Admin Mode section
- ✓ Style Guide

---

### Novel/Chapter Screens

#### Guest Mode
```
[Back] [Novel Title - Chapters]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Chapter List (read-only)

No chapters found.
```

**Visible:**
- ✓ Back button
- ✓ Novel title
- ✓ Chapter list (if local data exists)

**Hidden:**
- ✗ Add/Create Chapter button
- ✗ Edit chapter actions
- ✗ Delete chapter actions
- ✗ Refresh/sync button
- ✗ PDF export (if requires cloud)

#### Logged In (Online/Offline) - Can Edit
```
[Back] [Novel Title - Chapters]  [Add] [Refresh] [PDF]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Chapter 1: Title          [Edit] [Delete]
Chapter 2: Title          [Edit] [Delete]
```

**Visible:**
- ✓ Back button
- ✓ Novel title
- ✓ Add/Create Chapter button
- ✓ Refresh button
- ✓ PDF export button
- ✓ Edit actions on chapters
- ✓ Delete actions on chapters

**Hidden:**
- ✗ Sync button (if offline)

#### Logged In (Online/Offline) - Cannot Edit
```
[Back] [Novel Title - Chapters]           [PDF]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Chapter 1: Title          (read-only)
Chapter 2: Title          (read-only)
```

**Visible:**
- ✓ Back button
- ✓ Novel title
- ✓ PDF export button
- ✓ Chapter list (read-only)

**Hidden:**
- ✗ Add/Create Chapter button
- ✗ Refresh button (maybe)
- ✗ Edit actions
- ✗ Delete actions

#### Admin
```
[Back] [Novel Title - Chapters]  [Add] [Refresh] [PDF]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Chapter 1: Title          [Edit] [Delete]
Chapter 2: Title          [Edit] [Delete]
```

**Visible:**
- ✓ All Logged In (Can Edit) features
- ✓ Additional admin options in chapter menu

---

### Sidebar Navigation

#### Guest Mode
```
┌─────────────────┐
│ 📚 Library      │
├─────────────────┤
│ ⚙️ Settings     │
├─────────────────┤
│ ✉️ Sign In      │
└─────────────────┘
```

**Visible:**
- ✓ Library
- ✓ Settings
- ✓ Sign In (as navigation item)

**Hidden:**
- ✗ Current Novel (no selected novel)
- ✗ Content sections (Chapters, Characters, etc.)
- ✗ Profile
- ✗ Sign Out

#### Logged In (Online/Offline)
```
┌─────────────────┐
│ 📚 Library      │
│ 📖 Novel Title  │
├─────────────────┤
│ 📑 Chapters     │
│ 👥 Characters   │
│ 🎬 Scenes       │
│ 📝 Summaries   │
├─────────────────┤
│ ⚙️ Settings     │
│ 👤 Profile      │
│ 🚪 Sign Out    │
└─────────────────┘
```

**Visible:**
- ✓ Library
- ✓ Current Novel (if selected)
- ✓ Content sections (Chapters, Characters, Scenes, Summaries)
- ✓ Settings
- ✓ Profile
- ✓ Sign Out

**Hidden:**
- ✗ Sign In (already logged in)

#### Admin
```
┌─────────────────┐
│ 📚 Library      │
│ 📖 Novel Title  │
├─────────────────┤
│ 📑 Chapters     │
│ 👥 Characters   │
│ 🎬 Scenes       │
│ 📝 Summaries   │
├─────────────────┤
│ ⚙️ Settings     │
│ 👤 Profile      │
│ 👑 Admin Panel  │
│ 🚪 Sign Out    │
└─────────────────┘
```

**Visible:**
- ✓ All Logged In features
- ✓ Admin Panel

---

### AppBar Action Summary by State

| Button | Guest | Logged In (Online) | Logged In (Offline) | Admin |
|--------|-------|-------------------|---------------------|-------|
| Home/Library | ✓ | ✓ | ✓ | ✓ |
| Back | ✓ | ✓ | ✓ | ✓ |
| Add/Create | ✗ | ✓ (if can edit) | ✓ (if can edit) | ✓ |
| Refresh/Sync | ✗ | ✓ | ⚠️ (retry only) | ✓ |
| Search | ✓ | ✓ | ✓ | ✓ |
| PDF | ✗ | ✓ | ✓ | ✓ |
| Menu/More | ✓ | ✓ | ✓ | ✓ |
| Sign In | ✓ | ✗ | ✗ | ✗ |
| Sign Out | ✗ | ✓ | ✓ | ✓ |
| Admin Mode | ✗ | ✗ | ✗ | ✓ |

---

### Implementation Pattern

```dart
// Get user state
final isSignedIn = ref.watch(isSignedInProvider);
final isOnline = ref.watch(connectivityProvider);
final currentUser = ref.watch(currentUserProvider).asData?.value;
final isAdmin = currentUser?.isAdmin ?? false;
final canEdit = ref.watch(editPermissionsProvider(novelId)).asData?.value ?? false;

// Show/hide buttons based on state
AppBar(
  leading: AppButtons.icon(
    iconData: Icons.home,
    tooltip: l10n.home,
    onPressed: () => context.go('/'),
  ),
  title: Text(l10n.chapters),
  actions: [
    // Add button: Only logged in, can edit
    if (isSignedIn && canEdit)
      AppButtons.icon(
        iconData: Icons.add,
        tooltip: l10n.newLabel,
        onPressed: () {},
      ),
    
    // Refresh: Always show, but behavior changes
    AppButtons.icon(
      iconData: isOnline ? Icons.refresh : Icons.sync_problem,
      tooltip: isOnline ? l10n.refreshTooltip : l10n.retry,
      onPressed: isOnline ? refreshAction : retryAction,
    ),
    
    // PDF: Logged in only
    if (isSignedIn)
      AppButtons.icon(
        iconData: Icons.picture_as_pdf,
        tooltip: l10n.pdf,
        onPressed: () {},
      ),
    
    // Menu: Always show
    AppButtons.icon(
      iconData: Icons.menu_open,
      tooltip: l10n.menu,
      onPressed: () => Scaffold.of(context).openDrawer(),
    ),
  ],
)
```

---

## Context-Specific Rules

### Forms

- **Bottom**: Primary (Save) → Secondary (Cancel)
- **Alignment**: Centered (mobile), right-aligned (desktop)

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
    AppButtons.secondary(
      label: l10n.cancel,
      onPressed: () {},
    ),
    SizedBox(width: 12),
    AppButtons.primary(
      label: l10n.save,
      onPressed: () {},
    ),
  ],
)
```

### Dialogs

- **Actions**: Right-aligned
- **Order**: Cancel → Secondary → Primary
- **Destructive**: Last, distinct color (red/orange)

```dart
AlertDialog(
  actions: [
    AppButtons.text(
      label: l10n.cancel,
      onPressed: () => Navigator.pop(context),
    ),
    AppButtons.primary(
      label: l10n.confirm,
      onPressed: () {},
    ),
  ],
)
```

### Empty States

- **Single action**: Primary button
- **Centered**: Vertically and horizontally
- **Label**: Action verb + noun (e.g., "Create Novel")

### Cards/Lists

- **Inline actions**: Icon buttons in trailing position
- **Limit**: 2-3 inline max, rest in overflow

---

## Accessibility Guidelines

### Button Labels
- Always provide `tooltip` for icon buttons
- Use localized strings
- Keep labels concise (< 20 chars)
- Use action verbs ("Save", not "Saving")

### Keyboard Navigation
- All buttons focusable
- Logical tab order
- Enter/Space to activate

### Contrast
- Primary: High contrast (WCAG AA)
- Secondary: Sufficient contrast
- Disabled: 50% opacity

### Touch Targets
- Minimum 44x44 points
- Adequate spacing (8px minimum)

---

## Responsive Behavior

### Mobile (< 600px)
- Icon buttons preferred in AppBar
- Bottom sheets for menus
- Single column layout

### Tablet (600-1200px)
- Mix of icon + text buttons
- Side panels for menus
- Two-column where appropriate

### Desktop (> 1200px)
- Text buttons in AppBar
- Permanent sidebar (if screen space allows)
- Mouse hover effects

---

## Do's and Don'ts

### Do
- ✓ Use `AppButtons` widget for consistency
- ✓ Localize all text
- ✓ Provide tooltips for icon-only buttons
- ✓ Limit primary actions per screen (1-2)
- ✓ Group related menu items with dividers
- ✓ Show loading state for async actions
- ✓ Disable buttons during operation

### Don't
- ✗ Mix button styles arbitrarily
- ✗ Use hardcoded strings
- ✗ Put more than 4-5 actions in AppBar
- ✗ Hide critical actions in menus
- ✗ Use icon buttons without tooltips
- ✗ Place primary action after secondary

---

## Examples

### Settings Screen - Guest Mode
```
[Home] [Settings]                       [Refresh]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
> App Settings        [>]
> Color Theme         [>]
> Typography          [>]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
> Reader Bundles
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
> Performance         [>]
> TTS Settings        [>]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                 [Sign In]
```

### Settings Screen - Logged In
```
[Home] [Settings - user@email.com]    [Refresh]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
> App Settings        [>]
> Cloud Sync Settings [>]
> Color Theme         [>]
> Typography          [>]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
> Reader Bundles
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
> Performance         [>]
> TTS Settings        [>]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
> Token Usage         [>]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                [Sign Out]
```

### Chapter List - Guest Mode
```
[Back] [Novel Title - Chapters]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Chapter 1: Title             (read-only)
Chapter 2: Title             (read-only)
```

### Chapter List - Logged In (Can Edit)
```
[Back] [Novel Title - Chapters]  [Add] [Refresh] [PDF] [Menu]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Chapter 1: Title          [Edit] [Delete]
Chapter 2: Title          [Edit] [Delete]
Chapter 3: Title          [Edit] [Delete]
```

### Library - Guest Mode
```
[Home] [Library]                       [Search]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Novel List (local only)

                            [Sign In]
```

### Library - Logged In (Offline)
```
[Home] [Library]            [Retry]  [Search]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Novel List (cached)
                              [More >]

⚠ You're offline. Changes will sync when online.
```

### Form (New Chapter)
```
[Back] [New Chapter]                    [Cancel] [Save] (⌘+S)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Title: [___________________]

Content:
[_________________________]
[_________________________]
[_________________________]

                                        [Save] [Cancel]

Tip: Press ⌘/Ctrl + / for keyboard shortcuts
```

### Keyboard Shortcuts Dialog (⌘/Ctrl + /)
```
┌─────────────────────────────────────┐
│     Keyboard Shortcuts              │
├─────────────────────────────────────┤
│ Navigation                         │
│   Home                ⌘/Ctrl + H   │
│   Back                ⌘/Ctrl + [   │
│   Toggle Sidebar      ⌘/Ctrl + D   │
├─────────────────────────────────────┤
│ Actions                            │
│   Save                ⌘/Ctrl + S   │
│   New                 ⌘/Ctrl + N   │
│   Search              ⌘/Ctrl + F   │
│   Refresh             ⌘/Ctrl + R   │
├─────────────────────────────────────┤
│ Editor                             │
│   Bold                ⌘/Ctrl + B   │
│   Italic              ⌘/Ctrl + I   │
│   Underline           ⌘/Ctrl + U   │
│   Save & Close        ⌘/Ctrl + ↵  │
├─────────────────────────────────────┤
│ Reader                             │
│   Play/Pause          Space        │
│   Next Chapter        ⌘/Ctrl + →   │
│   Previous Chapter    ⌘/Ctrl + ←   │
│   Fullscreen          F            │
└─────────────────────────────────────┘
                    [Close] (Esc)
```
[Home] [Settings - Signed in as...]  [Refresh]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
> App Settings        [>]
> Color Theme         [>]
> Typography          [>]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
> Reader Bundles
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
> Performance         [>]
> TTS Settings        [>]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                 [Sign Out]
```

### Chapter List (Reader)
```
[Back] [Novel Title - Chapters]  [Add] [Refresh] [PDF] [Menu]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Chapter 1: Title                          [More >]
Chapter 2: Another Title                   [More >]
Chapter 3: Yet Another                     [More >]
```

### Form (New Chapter)
```
[Back] [New Chapter]                       [Cancel] [Save]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Title: [___________________]

Content:
[_________________________]
[_________________________]
[_________________________]

                                        [Save] [Cancel]
```

---

## Keyboard Shortcuts

Keyboard shortcuts improve productivity for power users. This section defines shortcuts for frequently used actions across the application.

### Platform Conventions

| Platform | Modifier Key | Display Format |
|----------|--------------|----------------|
| macOS | Command (⌘) | `⌘ + S` |
| Windows/Linux | Control (Ctrl) | `Ctrl + S` |

**Note**: In code, use `kIsWeb ? 'Ctrl' : (Platform.isMacOS ? '⌘' : 'Ctrl')` to display the correct modifier.

---

### Global Shortcuts

Available throughout the application:

| Shortcut | Action | Scope |
|----------|--------|-------|
| `⌘/Ctrl + H` | Navigate to Home (Library) | All screens |
| `⌘/Ctrl + ,` | Open Settings | All screens |
| `⌘/Ctrl + /` | Show Keyboard Shortcuts | All screens |
| `⌘/Ctrl + K` | Open Quick Search | All screens |
| `Escape` | Close dialogs/drawers | All screens |
| `⌘/Ctrl + [` | Navigate back | Most screens |
| `⌘/Ctrl + ]` | Navigate forward | Most screens |
| `⌘/Ctrl + Shift + R` | Force refresh | Most screens |

---

### Library Screen

| Shortcut | Action |
|----------|--------|
| `⌘/Ctrl + N` | Create New Novel |
| `⌘/Ctrl + F` | Focus Search |
| `Arrow Down` | Select next novel |
| `Arrow Up` | Select previous novel |
| `Enter` | Open selected novel |
| `Delete/Backspace` | Remove from library |

---

### Novel/Chapter List

| Shortcut | Action |
|----------|--------|
| `⌘/Ctrl + N` | Create New Chapter |
| `⌘/Ctrl + R` | Refresh chapters |
| `Arrow Down` | Select next chapter |
| `Arrow Up` | Select previous chapter |
| `Enter` | Open selected chapter |
| `⌘/Ctrl + D` | Duplicate chapter (if can edit) |
| `Delete/Backspace` | Delete chapter (if can edit) |

---

### Chapter Editor

| Shortcut | Action |
|----------|--------|
| `⌘/Ctrl + S` | Save chapter |
| `⌘/Ctrl + Enter` | Save and close |
| `⌘/Ctrl + W` | Close without saving (prompts if dirty) |
| `⌘/Ctrl + Shift + S` | Save as... (future) |
| `Escape` | Exit edit mode (if clean) |

#### Text Formatting

| Shortcut | Action |
|----------|--------|
| `⌘/Ctrl + B` | Bold |
| `⌘/Ctrl + I` | Italic |
| `⌘/Ctrl + U` | Underline |
| `⌘/Ctrl + K` | Insert link |
| `⌘/Ctrl + Shift + K` | Insert code block |
| `⌘/Ctrl + 1` | Heading 1 |
| `⌘/Ctrl + 2` | Heading 2 |
| `⌘/Ctrl + 3` | Heading 3 |
| `⌘/Ctrl + 0` | Paragraph (normal text) |

#### Cursor Navigation

| Shortcut | Action |
|----------|--------|
| `⌘/Ctrl + Arrow Left` | Jump to word start |
| `⌘/Ctrl + Arrow Right` | Jump to word end |
| `⌘/Ctrl + Arrow Up` | Jump to document start |
| `⌘/Ctrl + Arrow Down` | Jump to document end |
| `Option/Alt + Arrow Left/Right` | Jump by one character |
| `Option/Alt + Arrow Up/Down` | Jump by one line |

---

### Chapter Reader

| Shortcut | Action |
|----------|--------|
| `Space` | Play/Pause TTS |
| `⌘/Ctrl + Left` | Previous chapter |
| `⌘/Ctrl + Right` | Next chapter |
| `Arrow Up` | Scroll up |
| `Arrow Down` | Scroll down |
| `Page Up` | Scroll up one page |
| `Page Down` | Scroll down one page |
| `Home` | Scroll to top |
| `End` | Scroll to bottom |
| `F` | Enter fullscreen (desktop) |
| `Escape` | Exit fullscreen |

#### TTS Controls

| Shortcut | Action |
|----------|--------|
| `⌘/Ctrl + R` | Increase speech rate |
| `⌘/Ctrl + Shift + R` | Decrease speech rate |
| `⌘/Ctrl + V` | Change voice |
| `⌘/Ctrl + M` | Mute/Unmute |

---

### Settings Screen

| Shortcut | Action |
|----------|--------|
| `⌘/Ctrl + 1` | Focus App Settings |
| `⌘/Ctrl + 2` | Focus Color Theme |
| `⌘/Ctrl + 3` | Focus Typography |
| `⌘/Ctrl + 4` | Focus Performance |
| `⌘/Ctrl + 5` | Focus TTS Settings |
| `Enter` | Open selected setting |
| `Escape` | Close Settings |

---

### Sidebar/Drawer

| Shortcut | Action |
|----------|--------|
| `⌘/Ctrl + D` | Toggle sidebar |
| `⌘/Ctrl + 1` | Navigate to Library |
| `⌘/Ctrl + 2` | Navigate to Chapters |
| `⌘/Ctrl + 3` | Navigate to Characters |
| `⌘/Ctrl + 4` | Navigate to Scenes |
| `⌘/Ctrl + 5` | Navigate to Summaries |
| `⌘/Ctrl + ,` | Navigate to Settings |
| `Escape` | Close sidebar |

---

### Dialogs and Modals

| Shortcut | Action |
|----------|--------|
| `Enter` | Confirm primary action |
| `Escape` | Cancel/Close dialog |
| `⌘/Ctrl + Enter` | Confirm primary action (alternative) |
| `Tab` | Navigate between form fields |
| `Shift + Tab` | Navigate backward between form fields |

---

### Admin Panel (Admin Only)

| Shortcut | Action |
|----------|--------|
| `⌘/Ctrl + Shift + U` | Open User Management |
| `⌘/Ctrl + Shift + L` | Open Admin Logs |
| `⌘/Ctrl + Shift + A` | Toggle Admin Mode |

---

### Quick Search (⌘/Ctrl + K)

A global search modal for rapid navigation:

| Shortcut | Action (in search modal) |
|----------|---------------------------|
| `Arrow Down` | Select next result |
| `Arrow Up` | Select previous result |
| `Enter` | Navigate to selected result |
| `Escape` | Close search modal |
| `Type` | Filter results |

Search supports:
- Novel names
- Chapter titles
- Settings options
- Menu items

---

### Accessibility Shortcuts

| Shortcut | Action |
|----------|--------|
| `Tab` | Move focus forward |
| `Shift + Tab` | Move focus backward |
| `Space` | Activate focused button |
| `Enter` | Activate focused item |
| `⌘/Ctrl + Option + D` | Toggle dark mode |

---

### Implementation Pattern

```dart
// In your widget build method
Shortcuts(
  shortcuts: <LogicalKeySet, Intent>{
    LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyS): SaveIntent(),
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS): SaveIntent(),
    LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyN): NewIntent(),
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyN): NewIntent(),
    LogicalKeySet(LogicalKeyboardKey.escape): CloseIntent(),
  },
  child: Actions(
    actions: <Type, Action<Intent>>{
      SaveIntent: CallbackAction<SaveIntent>(
        onInvoke: (intent) => _saveChapter(),
      ),
      NewIntent: CallbackAction<NewIntent>(
        onInvoke: (intent) => _createNew(),
      ),
      CloseIntent: CallbackAction<CloseIntent>(
        onInvoke: (intent) => Navigator.of(context).pop(),
      ),
    },
    child: YourWidget(),
  ),
)

// Define intents
class SaveIntent extends Intent {
  const SaveIntent();
}

class NewIntent extends Intent {
  const NewIntent();
}

class CloseIntent extends Intent {
  const CloseIntent();
}
```

### Displaying Shortcuts in Tooltips

```dart
AppButtons.icon(
  iconData: Icons.save,
  tooltip: Platform.isMacOS 
    ? '${l10n.save} (⌘+S)' 
    : '${l10n.save} (Ctrl+S)',
  onPressed: () => _save(),
)
```

### Keyboard Shortcut Dialog

Show users available shortcuts with `⌘/Ctrl + /`:

```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text(l10n.keyboardShortcuts),
    content: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShortcutGroup(l10n.navigation, [
            _ShortcutItem(l10n.home, '⌘/Ctrl + H'),
            _ShortcutItem(l10n.back, '⌘/Ctrl + ['),
          ]),
          _buildShortcutGroup(l10n.actions, [
            _ShortcutItem(l10n.save, '⌘/Ctrl + S'),
            _ShortcutItem(l10n.newLabel, '⌘/Ctrl + N'),
          ]),
          // ... more groups
        ],
      ),
    ),
    actions: [
      AppButtons.primary(
        label: l10n.close,
        onPressed: () => Navigator.pop(context),
      ),
    ],
  ),
);
```

---

## Implementation Status

### ✅ Completed

1. **Button Types & Organization**
   - Button types defined (Primary, Secondary, Text, Icon)
   - AppBar organization rules
   - Settings and lists patterns
   - Menu organization patterns
   - Context-specific rules

2. **Authentication & Authorization Display Rules**
   - Guest mode visibility
   - Logged in (online) visibility
   - Logged in (offline) visibility
   - Non-admin visibility
   - Admin visibility
   - Sidebar state by auth mode

3. **Keyboard Shortcuts**
   - All Intent classes and mappings (40+ intents)
   - Platform-aware helper functions
   - Keyboard shortcuts dialog (desktop modal + mobile sheet)
   - Quick Search modal implementation
   - Wrapper widgets for integration

### 📝 Implemented Files

| File | Description | Status |
|------|-------------|--------|
| `lib/shared/widgets/keyboard_shortcuts.dart` | Central Intent definitions and shortcut mappings | ✅ |
| `lib/shared/widgets/keyboard_shortcuts_dialog.dart` | Shortcuts help dialog/bottom sheet | ✅ |
| `lib/shared/widgets/quick_search_modal.dart` | Quick search modal with navigation | ✅ |
| `lib/shared/widgets/global_shortcuts_wrapper.dart` | Wrapper widgets for all screen types | ✅ |
| `lib/shared/widgets/tooltip_with_shortcut.dart` | Tooltip helpers for shortcuts | ✅ |
| `lib/l10n/app_en.arb` | English translations for shortcuts | ✅ |
| `lib/l10n/app_zh.arb` | Chinese translations for shortcuts | ✅ |
| `docs/keyboard_shortcuts_implementation.md` | Implementation guide | ✅ |

### ⏳ Remaining Tasks (Optional Enhancements)

1. **Integrate into more screens** - Wrapper widgets are ready but not yet applied:
   - Settings screen - Use `SettingsShortcutsWrapper`
   - Chapter editor - Use `EditorShortcutsWrapper`
   - Sidebar - Add toggle shortcut

2. **Enhance Quick Search** - Basic modal is implemented:
   - Add more search types (settings options, menu items)
   - Add focus management for search bar
   - Add keyboard navigation within results

3. **Customizable Shortcuts** - Allow users to remap shortcuts

4. **Admin Panel Shortcuts** - Create admin panel and apply shortcuts

### Integration Example

```dart
// Wrap your screen with shortcuts wrapper
SettingsShortcutsWrapper(
  onFocusAppSettings: () => _scrollToSection('app'),
  onFocusColorTheme: () => _scrollToSection('theme'),
  onFocusTypography: () => _scrollToSection('typography'),
  onFocusPerformance: () => _scrollToSection('performance'),
  onFocusTTSSettings: () => _scrollToSection('tts'),
  child: Scaffold(...),
)

// Add shortcut to tooltips
AppButtons.icon(
  iconData: Icons.save,
  tooltip: l10n.save.withShortcut('S'),  // "Save (⌘+S)"
  onPressed: () => _save(),
)

// Show shortcuts help
showKeyboardShortcutsDialog(context);  // Desktop
showKeyboardShortcutsSheet(context);   // Mobile
```

---

## Related Files

- `lib/shared/widgets/app_buttons.dart` - Button widget implementations
- `lib/widgets/side_bar.dart` - Sidebar navigation
- `lib/features/settings/settings_screen.dart` - Settings example
- `lib/features/reader/reader_screen.dart` - List with AppBar actions
