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
