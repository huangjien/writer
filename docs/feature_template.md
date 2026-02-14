# Feature Template

This document defines the standard structure for all features in the Writer application.

## Required Directory Structure

All features should follow this consistent layout:

```
features/
└── feature_name/
    ├── models/              # Feature-specific data models (if any)
    ├── repositories/        # Feature-specific repositories (if any)
    ├── services/           # Feature-specific services (if any)
    ├── state/              # Feature state management
    ├── widgets/            # Feature-specific reusable widgets
    ├── utils/              # Feature-specific utilities (if any)
    ├── screens/            # Feature screens
    │   ├── *_screen.dart
    │   └── ...
    └── *_screen.dart       # Main entry point (if single screen)
```

## Naming Conventions

- **Directory**: lowercase_with_underscores
- **Screen files**: `{feature}_screen.dart` (e.g., `sign_in_screen.dart`)
- **Widget files**: lowercase_with_underscores.dart (e.g., `user_card.dart`)
- **State files**: `{feature}_state.dart` or `{feature}_notifier.dart`
- **Provider files**: `{feature}_providers.dart`

## Examples

### Well-Organized Features

#### `ai_chat/` - Reference Example
```
ai_chat/
├── models/                    # Chat message models
│   ├── ai_message.dart
│   └── chat_session.dart
├── services/                  # AI API integration
│   └── ai_chat_service.dart
├── state/                    # Chat state management
│   ├── ai_chat_providers.dart
│   └── ai_chat_state.dart
├── utils/                    # Chat utilities
│   └── message_formatter.dart
└── widgets/                  # Chat UI components
    ├── ai_chat_panel.dart
    └── global_ai_overlay.dart
```

#### `reader/` - Reference Example
```
reader/
├── logic/                     # Reader business logic
│   ├── edit_mode.dart
│   ├── reader_navigation.dart
│   ├── reader_shortcuts.dart
│   └── tts_driver.dart
├── state/                     # Reader state
│   ├── reader_session_state.dart
│   └── reader_session_notifier.dart
├── widgets/                   # Reader widgets
│   ├── contrast_alert_dialog.dart
│   ├── reader_app_bar.dart
│   ├── reader_bottom_bar_shell.dart
│   ├── reader_edit_actions.dart
│   ├── reader_settings_panel.dart
│   └── reader_tts_controls.dart
├── chapter_reader_screen.dart  # Chapter reader
├── novel_metadata_editor.dart   # Metadata editor
├── reader_screen.dart          # Main entry point
└── tts_chunker.dart           # TTS utility
```

### Migration Examples

#### Before (Flat Structure)
```
auth/
├── forgot_password_screen.dart
├── reset_password_screen.dart
├── sign_in_screen.dart
├── sign_up_screen.dart
└── user_management_screen.dart
```

#### After (Standardized)
```
auth/
├── screens/
│   ├── forgot_password_screen.dart
│   ├── reset_password_screen.dart
│   ├── sign_in_screen.dart
│   ├── sign_up_screen.dart
│   └── user_management_screen.dart
└── widgets/                   # If any shared widgets
```

## Guidelines

### When to Create Subdirectories

- **models/**: If the feature has custom data models not shared with other features
- **repositories/**: If the feature needs specific data access logic
- **services/**: If the feature integrates with external APIs or has complex business logic
- **state/**: Always create for features with state management needs
- **widgets/**: Create if extracting reusable components from screens
- **utils/**: If the feature has helper functions specific to it
- **screens/**: Create if the feature has multiple screens

### When to Keep Flat

Small, simple features with 1-2 files may remain flat:
```
about/
└── about_screen.dart
```

## Import Organization

When updating imports after restructuring:

1. **Use absolute imports from package root** (`lib/`)
   ```dart
   import 'package:writer/features/auth/screens/sign_in_screen.dart';
   ```

2. **Group imports** in this order:
   - Dart/SDK imports
   - Flutter package imports
   - Local imports (grouped by feature)

3. **Update all references** when moving files
   - Run `make test` to verify no broken imports
   - Run `dart analyze` to check for issues

## Checklist for New Features

When creating a new feature:

- [ ] Create feature directory with appropriate subdirectories
- [ ] Follow naming conventions for all files
- [ ] Use absolute imports from `lib/`
- [ ] Create feature-specific providers in `state/`
- [ ] Extract reusable widgets to `widgets/`
- [ ] Add tests mirroring feature structure
- [ ] Update `app_router.dart` with new routes
- [ ] Document any feature-specific patterns in this file

## Benefits of Standardized Structure

1. **Predictability**: Developers know where to find code
2. **Scalability**: Easy to add new features following established patterns
3. **Maintainability**: Clear separation of concerns
4. **Testability**: Tests mirror feature structure
5. **Collaboration**: Reduced merge conflicts with clear boundaries

## Migration Strategy

When restructuring existing features:

1. **Plan new structure** before moving files
2. **Create new directories**
3. **Move files** to new locations
4. **Update all imports** throughout codebase
5. **Run tests**: `make test`
6. **Run analyzer**: `dart analyze`
7. **Verify navigation**: Test all affected screens
8. **Update documentation**: Keep this file current

## Related Documentation

- `README.md` - Overall architecture and design system
- `docs/sidebar_ux_guidelines.md` - UX patterns for navigation
- `docs/keyboard_shortcuts_implementation.md` - Keyboard shortcut integration
