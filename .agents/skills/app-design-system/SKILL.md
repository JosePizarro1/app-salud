# App Design System

This skill defines the architectural standards for the application's design system, ensuring consistency in colors, typography, and spacing.

## Color Foundation
All colors must be sourced from `lib/app/theme/app_colors.dart`. Avoid hardcoding `Color(0xFF...)` values in widgets.

### Primary Palette
- **Primary**: `AppColors.primary` (Indigo) - Main action color.
- **Secondary**: `AppColors.secondary` (Cyan) - Accents and highlights.
- **Success/Error**: `AppColors.success` / `AppColors.error`.

## Theme Architecture
The app uses a `ThemeData` provider that switches between light and dark modes. Use `Theme.of(context)` where possible to maintain reactivity.

## Implementation Rules
1. When creating a new page, use `AppColors.bgLight` or `bgDark` for the scaffold background.
2. For buttons, use `AppColors.primaryGradient`.
3. For text, differentiate between `textPrimary` and `textSecondary` roles.

## Safe Areas & Márgenes de Respeto (Mobile Layouts)
Mobile devices have notches, dynamic islands, and system status bars at the top, as well as home indicators at the bottom. To ensure a premium layout, always apply the following margin and safety rules:

1. **Top Notch & Status Bar**: 
   - Never place interactive elements or text within the raw status bar area.
   - Always wrap main content in a `SafeArea` or use `MediaQuery.of(context).padding.top` to calculate offsets dynamically.
   - Headers with back buttons must have a top offset of `MediaQuery.of(context).padding.top + 8` or be placed inside a `SafeArea` to avoid overlapping with status bar icons.
   - Provide a visual breathing room of at least `60px` to `70px` from the top of the safe area for content lists or scrolls.

2. **Bottom Home Indicator**:
   - Scrollable content must have a bottom spacer (`SizedBox(height: 80)` or `SizedBox(height: 100)`) at the end of lists so that the last items are not covered by the dynamic home indicator or the Floating Action Button (FAB).
   - If drawing elements at the bottom of the screen (outside scrolls), use `SafeArea` or pad using `MediaQuery.of(context).padding.bottom + 16` to prevent overlaps with the device's native gesture bar.

3. **Floating Elements**:
   - Buttons, panels, and custom dialogs must maintain a lateral margin of at least `16px` or `20px` to respect the screen edges on all phone sizes.
