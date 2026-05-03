# Vitali Token System Skill

This skill defines the mandatory rules for color and design token management in the Vitali project. Following these rules ensures that the entire application's theme can be updated instantly by modifying a single file.

## 🏛️ The Single Source of Truth
All design tokens (colors, gradients, spacing, shadows) MUST reside in:
`lib/app/theme/app_colors.dart`

## 🚫 Forbidden Practices
1. **No Hardcoding**: Never use `Colors.xyz` or hex codes (`0xFF...`) directly in widgets or pages.
2. **No Specific Names in UI**: Do NOT use tokens like `AppColors.coral` or `AppColors.mint` in your page layouts. These names are unstable and change with the brand.
3. **No Direct Style Modification**: Avoid creating ad-hoc `TextStyle` objects without checking if a theme text style exists.

## ✅ Mandatory Patterns

### 1. Use Semantic Aliases
Always reference colors by their functional role.

| Role | Token to Use |
| :--- | :--- |
| Main action / Brand | `AppColors.primary` |
| Complementary / Healing | `AppColors.secondary` |
| Backgrounds (Light) | `AppColors.bgLight` |
| Item Backgrounds | `AppColors.surfaceLight` |
| Subtitles / Hints | `AppColors.textSecondaryLight` |

### 2. Standard Suffixes
When defining tokens in `AppColors.dart`, use these suffixes for consistency:
- `...Light`: For light mode variants.
- `...Dark`: For dark mode variants.
- `...Gradient`: For linear/radial gradients.

### 3. Updating the Palette
To change the app's look (e.g., switching from Mint/Lavender to Coral/Lavender):
1. **Modify the internal value** in `AppColors.dart`.
2. **Keep the semantic member name** (e.g., `primary`) unchanged.
3. If a specific name must be removed, first ensure no page is using it directly.

## 🛠️ Implementation Example

**WRONG (Unstable):**
```dart
Container(
  color: AppColors.mintLight, // ERROR: If we remove mint, this breaks.
)
```

**RIGHT (Stable & Premium):**
```dart
Container(
  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight, // BEST: Theme-aware and semantic.
)
```

## 🔍 Verification Checklist
- [ ] Are there any hex codes in the file? (Should only be in `AppColors.dart`)
- [ ] Does the page use `AppColors.primary` instead of a specific color name?
- [ ] Does the UI support Light/Dark transitions using the correct tokens?
