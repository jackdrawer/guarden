# Context: Phase 12 - Visual Analytics & Categorization (Updated)

## Overview
This phase adds visualization of subscription costs, categorization, and expands user preferences with automatic support for future languages and currencies.

## Implementation Decisions

### 📊 1. Analytics & Visuals
- **Scope**: Monthly Subscription Expenses breakdown.
- **Format**: **Pie Chart** for visualization.

### 🏷️ 2. Categorization
- **Structure**: Hybrid (Fixed defaults + Custom strings).
- **List Mapping**: Dynamic chips for filtering.

### ⚙️ 3. Preferences (Scalable)
- **Automatic Language Support**: The settings menu must dynamically iterate over `AppLocale.values`. This ensures that when a new language file is added to `i18n/`, it appears in settings automatically.
- **Automatic Currency Support**: Use `CurrencyUtils.getCommonCurrencies()` for the list. Adding a currency to the utility will automatically update Dashboard filters and Settings.

## Code Context
- **Dynamic iteration**: Use `AppLocale.values.map((l) => l.name)` style logic in UI.
- **Global Invalidation**: Ensure settings changes trigger dependent provider invalidations where necessary.
