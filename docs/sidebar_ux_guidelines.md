# Sidebar UX Guidelines

## Placement Strategy

### Primary Sidebar (Navigation) - **LEFT**
- Position: `Scaffold.drawer` (not `endDrawer`)
- Content: Library, chapters, settings, navigation
- Rationale: Follows natural reading pattern (LTR: top-left → bottom-right)

### Secondary Sidebar (Tools) - **RIGHT**
- Position: Aligned right, optional toggle
- Content: AI assistant, formatting tools, writing aids
- Rationale: Complementary tools, action-oriented, not primary navigation

### Mobile - **Bottom Navigation Bar**
- Position: `Scaffold.bottomNavigationBar`
- Content: Primary navigation actions
- Rationale: Better thumb reach on mobile devices

---

## Why This Layout?

### 1. Reading Order & Eye Flow
```
┌─────────────────────────────────────────┐
│ [Nav]         Novel Editor          │  ← Natural scan pattern
│  Lib                               (LTR: left → right)
│  Chpt  [AI Tools]                 │
│  Set                                ↓
│       Writing Area                    │
│       ← More horizontal space          │
└─────────────────────────────────────────┘
```

### 2. Platform Conventions
| Platform | Navigation Position |
|----------|-------------------|
| macOS | Left sidebar |
| Windows | Left pane |
| iOS/Android | Bottom bar (drawer from left) |
| Web | Left navigation |

### 3. Content-First Design
- **Writing apps** need maximum horizontal space for text
- Left sidebar preserves content width
- Right sidebar for tools (AI, formatting) doesn't interfere with reading flow

### 4. Cognitive Load
- Primary navigation (left) is discovered first
- Secondary tools (right) can be hidden/dismissed
- Matches mental model of book indexes (left of pages)

---

## RTL Support

### Automatic Position Flip
```dart
bool isRTL(BuildContext context) {
  return Directionality.of(context) == TextDirection.rtl;
}

// AI Sidebar positioning
alignment: isRTL(context)
    ? Alignment.centerLeft   // RTL: sidebar on left
    : Alignment.centerRight; // LTR: sidebar on right
```

### Border Flip
```dart
// RTL: border on right, LTR: border on left
border: Border(
  left: BorderSide(
    color: outline.withValues(alpha: isRTL ? 0 : 0.2),
  ),
  right: BorderSide(
    color: outline.withValues(alpha: isRTL ? 0.2 : 0),
  ),
),
```

---

## Platform-Specific Behavior

### Desktop (macOS/Windows/Linux)
- Left sidebar: Always visible (or collapsible)
- Right sidebar: Toggleable (AI chat panel)
- Full keyboard navigation support

### Tablet
- Left sidebar: Partially collapsed (icons only)
- Right sidebar: Full width when open
- Bottom navigation: Available as alternative

### Mobile (iOS/Android)
- Left sidebar: Hidden by default (hamburger menu)
- Bottom bar: Primary navigation
- Right sidebar: Full-screen modal when active
- Swipe gestures: Left (nav), Right (tools)

---

## Use Cases

### Novel Writing App - Recommended Layout

| Element | Position | Reason |
|----------|------------|---------|
| **Library/Chapters** | Left sidebar | Primary navigation, frequent access |
| **Settings** | Left sidebar | App configuration, standard placement |
| **AI Chat** | Right sidebar | Writing tool, contextual aid |
| **Formatting Toolbar** | Right sidebar or top | Writing-focused tools |
| **Character Notes** | Right sidebar | Reference material during writing |
| **Writing Stats** | Right sidebar or bottom panel | Progress monitoring, secondary |

---

## Implementation Notes

### Scaffold Structure
```dart
Scaffold(
  drawer: PrimarySidebar(),           // ← LEFT: Navigation
  endDrawer: null,                    // ✅ Removed (was wrong)
  body: Stack(
    children: [
      // Main content
      Positioned(
        alignment: isRTL(context)
            ? Alignment.centerLeft
            : Alignment.centerRight,
        child: AISidebar(),                // ← RIGHT: Tools
      ),
    ],
  ),
)
```

### Animation Best Practices
- **Left sidebar**: Slide in from left (LTR) / right (RTL)
- **Right sidebar**: Slide in from right (LTR) / left (RTL)
- Duration: 200-300ms (Material Design standard)
- Curve: `Curves.easeOutQuint`

---

## Accessibility Considerations

1. **Focus Order**: Left sidebar → Content → Right sidebar
2. **Keyboard Shortcuts**:
   - `Ctrl/Cmd + B`: Toggle left sidebar
   - `Ctrl/Cmd + I`: Toggle right sidebar (AI)
3. **Screen Reader**: Proper labeling of sidebar elements
4. **Touch Targets**: 48x48 minimum for sidebar items

---

## References

- **Material Design Guidelines**: Navigation drawers on left
- **Apple Human Interface Guidelines**: Sidebar navigation hierarchy
- **Fluent Design**: Left pane for structure
- **Nielsen Norman Group**: "Left-side navigation most familiar to users"

---

## Migration Notes

### Before (Incorrect)
```dart
Scaffold(
  endDrawer: SideBar(),  // ❌ Wrong: Right side
  body: ...,
)
```

### After (Correct)
```dart
Scaffold(
  drawer: SideBar(),     // ✅ Correct: Left side
  body: Stack(
    children: [
      // Content
      Positioned(
        alignment: Alignment.centerRight,
        child: AISidebar(),  // ✅ Correct: Right side (tools)
      ),
    ],
  ),
)
```
