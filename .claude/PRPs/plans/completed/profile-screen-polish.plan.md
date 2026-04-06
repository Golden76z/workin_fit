# Plan: Profile Screen Polish & Enhancement

## Summary
Redesign the profile header banner to be taller and left-align the avatar to make room for username (inside banner) and email (below banner). Add a bottom-right edit button on the banner that opens a real profile-edit bottom sheet. Add logout confirmation dialog. Replace the language page navigation with an inline modal/popup. Remove the duplicate "Edit profile" menu item from the Account block.

## User Story
As a user, I want a polished profile screen with easy access to edit my name, see my info clearly in the banner, confirm before logging out, and switch language without leaving the screen.

## Problem → Solution
- **Banner**: Too short (60px), avatar centered, username/email below → Taller banner (130px), avatar left-aligned inside banner, username inside banner, email pill below banner
- **Edit profile**: Coming-soon placeholder button hidden below stats → Real edit bottom sheet triggered by a pencil FAB at bottom-right of banner
- **Logout**: Immediate sign-out with no warning → Confirmation dialog via `AppDialog.showConfirm`
- **Language**: Full-page navigation push → Inline modal with flag-style options
- **Account menu**: Redundant "Edit profile" item → Removed

## Metadata
- **Complexity**: Medium
- **Source PRD**: N/A
- **PRD Phase**: N/A
- **Estimated Files**: 2 (profile_tab.dart, choose_language.dart kept for welcome flow)

---

## UX Design

### Before
```
┌──────────────────────────────────────────────┐
│  [gradient banner — 60px]                    │
├──────────────────────────────────────────────┤ ← avatar overlaps here (centered)
│         ○ Avatar ○                           │
│         Username                             │
│       📧 email@...                           │
│  [Edit Profile Button — full width]          │
│  Workouts | Programs | Total Time            │
└──────────────────────────────────────────────┘
```

### After
```
┌──────────────────────────────────────────────┐
│  [gradient banner — 130px]                   │
│  ○ Avatar  Username Here          [✏️ Edit]  │
│                                              │
└──────────────────────────────────────────────┘
│  📧 email@example.com                        │
│  Workouts | Programs | Total Time            │
└──────────────────────────────────────────────┘
```

### Interaction Changes
| Touchpoint | Before | After | Notes |
|---|---|---|---|
| Header layout | Avatar centered, info below | Avatar left in banner, username in banner | Edit FAB at banner bottom-right |
| Edit Profile button | Full-width gradient button below stats | Pencil FAB overlay on banner bottom-right | Opens `_EditProfileSheet` |
| "Edit profile" menu item | In Account menu list | **Removed** | Replaced by banner FAB |
| Logout button tap | Immediate logout | Opens `AppDialog.showConfirm` first | Destructive style |
| Language menu item | `Navigator.push` to `LanguageSelectionScreen` | `showDialog` with inline language picker | No navigation needed |

---

## Mandatory Reading

| Priority | File | Lines | Why |
|---|---|---|---|
| P0 | `lib/views/profile/profile_tab.dart` | 1–60 | Constants, providers, state class |
| P0 | `lib/views/profile/profile_tab.dart` | 380–517 | `_ProfileHeaderSliver` — entire header layout |
| P0 | `lib/views/profile/profile_tab.dart` | 97–128 | `_logout`, `_showComingSoon`, `_openLanguage` |
| P0 | `lib/views/profile/profile_tab.dart` | 313–350 | `_MenuList` items — where to remove Edit item |
| P1 | `lib/widgets/app_dialog.dart` | 1–105 | `AppDialog.showConfirm` static helper |
| P1 | `lib/services/firestore_service.dart` | 32–56 | `createOrUpdateUserProfile` — used for username save |
| P1 | `lib/core/theme/colors.dart` | all | Color constants for new widgets |
| P1 | `lib/core/theme/app_dimensions.dart` | all | `AppSpacing`, `AppRadii` constants |
| P2 | `lib/views/welcome/choose_language.dart` | all | Existing language logic — replicate in modal |
| P2 | `lib/providers/locale_provider.dart` | all | `localeProvider` / `setLocale` |

---

## Patterns to Mirror

### NAMING_CONVENTION
```dart
// SOURCE: lib/views/profile/profile_tab.dart:27-33
const double _kAvatarRadius = 52.0;
const double _kRingWidth = 8.0;
const double _kAvatarTotalRadius = _kAvatarRadius + _kRingWidth;
const double _kBannerHeight = _kAvatarTotalRadius;
const double _kProfileBlockRadius = AppRadii.lg;
// Private constants with _k prefix; private widgets with _Pascal prefix
```

### DIALOG_CONFIRM_PATTERN
```dart
// SOURCE: lib/widgets/app_dialog.dart:71-105
final confirmed = await AppDialog.showConfirm(
  context: context,
  title: 'Log out',
  message: 'Are you sure you want to log out?',
  confirmLabel: 'Log out',
  cancelLabel: 'Cancel',
  icon: Icons.logout_rounded,
  iconColor: AppColors.error,
  destructive: true,
);
if (confirmed == true) { /* proceed */ }
```

### MODAL_BOTTOM_SHEET_PATTERN
```dart
// SOURCE: lib/views/profile/profile_tab.dart:1444-1484 (remove-friend dialog variant)
// Use showModalBottomSheet for the edit profile sheet:
await showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (_) => _EditProfileSheet(username: username, userId: user.uid, email: email),
);
```

### SHOW_DIALOG_PATTERN
```dart
// SOURCE: lib/widgets/app_dialog.dart:82-104
showDialog<void>(
  context: context,
  builder: (_) => AppDialog(
    title: 'Language',
    icon: Icons.language_rounded,
    actions: [...],
  ),
);
```

### RIVERPOD_CONSUMER_STATE
```dart
// SOURCE: lib/views/profile/profile_tab.dart:57-94
class _ProfileTabState extends ConsumerState<ProfileTab>
    with AutomaticKeepAliveClientMixin<ProfileTab> {
  // Use ref.read for actions, ref.watch in build
  // mounted check before setState
  // ref.invalidate to refresh providers
}
```

### FIRESTORE_UPDATE_PATTERN
```dart
// SOURCE: lib/services/firestore_service.dart:32-56
await FirestoreService().createOrUpdateUserProfile(
  userId: user.uid,
  username: newUsername.trim(),
  email: user.email ?? '',
);
await user.updateDisplayName(newUsername.trim());
ref.invalidate(_userProfileProvider);
```

### TEXT_FIELD_STYLING
```dart
// SOURCE: consistent with app dark theme
TextField(
  controller: _controller,
  style: const TextStyle(color: AppColors.textPrimary),
  decoration: InputDecoration(
    filled: true,
    fillColor: AppColors.surfaceVariant,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadii.md),
      borderSide: BorderSide(color: AppColors.primary.withValues(alpha: AppOpacity.muted)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadii.md),
      borderSide: const BorderSide(color: AppColors.primary),
    ),
    hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: AppOpacity.half)),
  ),
),
```

### LANGUAGE_OPTION_ROW
```dart
// SOURCE: lib/views/welcome/choose_language.dart:26-42 (simplified from screen to widget)
// Replicate locale logic: ref.read(localeProvider.notifier).setLocale('en')
// Show checkmark on current locale
```

---

## Files to Change

| File | Action | Justification |
|---|---|---|
| `lib/views/profile/profile_tab.dart` | UPDATE | All 7 changes live here |

Only one file needs to change. The `LanguageSelectionScreen` in `choose_language.dart` stays for the welcome flow.

---

## NOT Building

- Settings screen (still shows "Coming soon")
- Privacy screen (still shows "Coming soon")
- Full profile stats wiring (keep existing hardcoded values for now)
- Friends tab changes
- New navigation routes
- Any backend changes beyond `createOrUpdateUserProfile`

---

## Step-by-Step Tasks

### Task 1: Increase Banner Height & Update Avatar Position
- **ACTION**: Change `_kBannerHeight` from `_kAvatarTotalRadius` (60) to a larger constant `130.0`
- **IMPLEMENT**:
  ```dart
  // REPLACE lines 27-31:
  const double _kAvatarRadius = 52.0;
  const double _kRingWidth = 8.0;
  const double _kAvatarTotalRadius = _kAvatarRadius + _kRingWidth; // 60
  const double _kBannerHeight = 130.0;  // ← was _kAvatarTotalRadius (60)
  const double _kProfileBlockRadius = AppRadii.lg;
  ```
- **MIRROR**: NAMING_CONVENTION
- **GOTCHA**: `_kBannerHeight` is used in two places: banner `SizedBox` height and avatar `Positioned.top`. Both will need updating in Task 2.
- **VALIDATE**: Banner visually taller, avatar previously at center still compiles

### Task 2: Redesign `_ProfileHeaderSliver` — Left Avatar + Username in Banner + Email Below
- **ACTION**: Restructure the `_ProfileHeaderSliver.build` method completely
- **IMPLEMENT**: Replace the current `Stack` + `Column` layout with a new layout where:
  1. The banner section uses a `Stack` with the gradient background + avatar (left-aligned) + username text (right of avatar) + edit FAB (bottom-right corner)
  2. The white section below contains email badge (left) and stats row

  ```dart
  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;
    final double bannerContentHeight = _kBannerHeight; // 130
    final double totalBannerHeight = bannerContentHeight + topPadding;

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // ── Banner: gradient bg + avatar left + username + edit FAB ──
          SizedBox(
            height: totalBannerHeight,
            child: Stack(
              children: <Widget>[
                // Gradient background
                const Positioned.fill(child: AppTopBarBackground()),

                // Avatar — left-aligned, vertically centered in banner content area
                Positioned(
                  top: topPadding + (bannerContentHeight - _kAvatarTotalRadius * 2) / 2,
                  left: AppSpacing.lg,
                  child: _AvatarWidget(
                    photoUrl: photoUrl,
                    uploading: uploadingImage,
                    onTap: onEditAvatar,
                  ),
                ),

                // Username — to the right of avatar, vertically centered
                Positioned(
                  top: topPadding + (bannerContentHeight - 28) / 2,  // 28 ≈ text height
                  left: AppSpacing.lg + _kAvatarTotalRadius * 2 + AppSpacing.md,
                  right: 56, // leave room for edit FAB
                  child: Text(
                    username,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'AppFontMedium',
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),

                // Edit FAB — bottom-right of banner
                Positioned(
                  bottom: AppSpacing.sm,
                  right: AppSpacing.md,
                  child: _BannerEditButton(onTap: onEditProfile),
                ),
              ],
            ),
          ),

          // ── White info section below banner ──
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.md,
              AppSpacing.xl,
              AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Email badge — left-aligned below banner
                if (email != null && email!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: AppOpacity.faint),
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: AppOpacity.muted),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.mail_outline_rounded,
                          size: 12,
                          color: AppColors.textSecondary.withValues(alpha: AppOpacity.prominent),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          email!,
                          style: TextStyle(
                            color: AppColors.textSecondary.withValues(alpha: 0.85),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: AppSpacing.lg),

                // Inline stats row — centered
                _InlineStats(isFrench: isFrench),
              ],
            ),
          ),
        ],
      ),
    );
  }
  ```
- **MIRROR**: NAMING_CONVENTION, RIVERPOD_CONSUMER_STATE
- **GOTCHA**: The `_ProfileHeaderSliver` no longer renders `_EditProfileButton` (the full-width one). Remove any reference to it. The `onEditProfile` callback is now wired to `_BannerEditButton`.
- **VALIDATE**: Hot reload shows taller banner, avatar on left with username beside it, email below banner

### Task 3: Add `_BannerEditButton` Widget
- **ACTION**: Create a new small pencil-icon button for the banner bottom-right
- **IMPLEMENT**: Add after `_EditProfileButton` class (which can be deleted or kept for other use):
  ```dart
  class _BannerEditButton extends StatelessWidget {
    final VoidCallback onTap;
    const _BannerEditButton({required this.onTap});

    @override
    Widget build(BuildContext context) {
      return Material(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xxs + 2,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const <Widget>[
                Icon(Icons.edit_rounded, size: 14, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'Edit',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
  ```
- **MIRROR**: NAMING_CONVENTION
- **IMPORTS**: None new — uses existing imports
- **VALIDATE**: Edit button appears at bottom-right of banner with white glass-style styling

### Task 4: Implement `_EditProfileSheet` Bottom Sheet
- **ACTION**: Create a stateful bottom sheet widget for editing the username
- **IMPLEMENT**: Add new class `_EditProfileSheet` at the bottom of profile_tab.dart:
  ```dart
  class _EditProfileSheet extends ConsumerStatefulWidget {
    final String currentUsername;
    final String userId;
    final String? email;

    const _EditProfileSheet({
      required this.currentUsername,
      required this.userId,
      this.email,
    });

    @override
    ConsumerState<_EditProfileSheet> createState() => _EditProfileSheetState();
  }

  class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
    late final TextEditingController _controller;
    bool _saving = false;

    @override
    void initState() {
      super.initState();
      _controller = TextEditingController(text: widget.currentUsername);
    }

    @override
    void dispose() {
      _controller.dispose();
      super.dispose();
    }

    Future<void> _save() async {
      final newName = _controller.text.trim();
      if (newName.isEmpty || newName == widget.currentUsername) {
        Navigator.of(context).pop();
        return;
      }
      setState(() => _saving = true);
      try {
        await FirestoreService().createOrUpdateUserProfile(
          userId: widget.userId,
          username: newName,
          email: widget.email ?? '',
        );
        // Also update Firebase Auth displayName
        final user = ref.read(currentUserProvider);
        await user?.updateDisplayName(newName);
        ref.invalidate(_userProfileProvider);
        if (mounted) Navigator.of(context).pop();
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update profile.')),
          );
        }
      } finally {
        if (mounted) setState(() => _saving = false);
      }
    }

    @override
    Widget build(BuildContext context) {
      final bool isFrench = Localizations.localeOf(context)
          .languageCode.toLowerCase().startsWith('fr');
      final double bottomPadding = MediaQuery.of(context).viewInsets.bottom;

      return Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.lg + bottomPadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary.withValues(alpha: AppOpacity.half),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              isFrench ? 'Modifier le profil' : 'Edit Profile',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontFamily: 'AppFontMedium',
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              isFrench ? 'Nom d\'utilisateur' : 'Username',
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: AppOpacity.prominent),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            TextField(
              controller: _controller,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surfaceVariant,
                hintText: isFrench ? 'Votre nom' : 'Your name',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: AppOpacity.half),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  borderSide: BorderSide(
                    color: AppColors.primary.withValues(alpha: AppOpacity.muted),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  borderSide: BorderSide(
                    color: AppColors.babyBlueIce.withValues(alpha: AppOpacity.half),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: _saving ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: BorderSide(
                        color: AppColors.babyBlueIce.withValues(alpha: AppOpacity.half),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.md),
                      ),
                    ),
                    child: Text(isFrench ? 'Annuler' : 'Cancel'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.md),
                      ),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            isFrench ? 'Sauvegarder' : 'Save',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }
  ```
- **MIRROR**: RIVERPOD_CONSUMER_STATE, FIRESTORE_UPDATE_PATTERN, TEXT_FIELD_STYLING
- **IMPORTS**: No new imports needed — all are already imported in profile_tab.dart
- **GOTCHA**: `_userProfileProvider` is a file-private provider — it's accessible within the same file. `currentUserProvider` is already imported.
- **VALIDATE**: Tapping Edit opens sheet, typing a name and saving updates Firestore and refreshes the username displayed in the banner

### Task 5: Wire Edit Button to `_EditProfileSheet`
- **ACTION**: Replace `onEditProfile: () => _showComingSoon(isFrench)` with the actual bottom sheet call in `_ProfileTabState`
- **IMPLEMENT**: In `_ProfileTabState`, add a new method `_openEditProfile`:
  ```dart
  Future<void> _openEditProfile(String username) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditProfileSheet(
        currentUsername: username,
        userId: user.uid,
        email: user.email,
      ),
    );
  }
  ```
  Then in `build`, pass it to `_ProfileHeaderSliver`:
  ```dart
  onEditProfile: () => _openEditProfile(username),
  ```
- **MIRROR**: MODAL_BOTTOM_SHEET_PATTERN
- **GOTCHA**: `username` comes from `profileAsync.when(...)` — it's available as a local variable in `build`. Pass it to `_openEditProfile` at call time.
- **VALIDATE**: Edit button opens bottom sheet. After save, username updates in banner without restart.

### Task 6: Add Logout Confirmation Dialog
- **ACTION**: Wrap `_logout()` with `AppDialog.showConfirm` before executing
- **IMPLEMENT**: Modify `_ProfileTabState` — replace the `_logout()` call site in the ListView (line ~354) by adding a new method `_confirmLogout`:
  ```dart
  Future<void> _confirmLogout(bool isFrench) async {
    final confirmed = await AppDialog.showConfirm(
      context: context,
      title: isFrench ? 'Se déconnecter ?' : 'Log out?',
      message: isFrench
          ? 'Êtes-vous sûr de vouloir vous déconnecter ?'
          : 'Are you sure you want to log out?',
      confirmLabel: isFrench ? 'Déconnecter' : 'Log out',
      cancelLabel: isFrench ? 'Annuler' : 'Cancel',
      icon: Icons.logout_rounded,
      iconColor: AppColors.error,
      destructive: true,
    );
    if (confirmed == true) {
      await _logout();
    }
  }
  ```
  Then update the `_LogoutButton` call in the `ListView`:
  ```dart
  // BEFORE:
  _LogoutButton(
    label: isFrench ? 'Se déconnecter' : 'Log out',
    onTap: _logout,
  ),
  // AFTER:
  _LogoutButton(
    label: isFrench ? 'Se déconnecter' : 'Log out',
    onTap: () => _confirmLogout(isFrench),
  ),
  ```
- **MIRROR**: DIALOG_CONFIRM_PATTERN
- **IMPORTS**: `AppDialog` — already imported via `app_dialog.dart`? Check: `lib/widgets/app_dialog.dart`. If not imported, add: `import 'package:workin_fit/widgets/app_dialog.dart';`
- **GOTCHA**: `_logout()` uses `Navigator.pushAndRemoveUntil` — ensure `mounted` is still checked inside it (already is at line 99).
- **VALIDATE**: Tapping "Log out" button shows dialog. Cancel dismisses. Confirm logs out.

### Task 7: Replace Language Page with Modal
- **ACTION**: Replace `_openLanguage()` Navigator.push with an inline showDialog containing language options
- **IMPLEMENT**: Replace `_openLanguage()` in `_ProfileTabState`:
  ```dart
  void _openLanguage() {
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => _LanguagePickerDialog(),
    );
  }
  ```
  Add a new private widget `_LanguagePickerDialog`:
  ```dart
  class _LanguagePickerDialog extends ConsumerWidget {
    const _LanguagePickerDialog();

    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final bool isFrench = Localizations.localeOf(context)
          .languageCode.toLowerCase().startsWith('fr');
      final Locale currentLocale = Localizations.localeOf(context);

      return AppDialog(
        title: isFrench ? 'Langue' : 'Language',
        icon: Icons.language_rounded,
        iconColor: AppColors.primary,
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _LanguageOption(
                flag: '🇬🇧',
                label: 'English',
                isSelected: !isFrench,
                onTap: () {
                  ref.read(localeProvider.notifier).setLocale('en');
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: AppSpacing.xs),
              _LanguageOption(
                flag: '🇫🇷',
                label: 'Français',
                isSelected: isFrench,
                onTap: () {
                  ref.read(localeProvider.notifier).setLocale('fr');
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
        actions: <AppDialogAction<dynamic>>[
          AppDialogAction<bool>(
            label: isFrench ? 'Fermer' : 'Close',
            returnValue: false,
          ),
        ],
      );
    }
  }

  class _LanguageOption extends StatelessWidget {
    final String flag;
    final String label;
    final bool isSelected;
    final VoidCallback onTap;

    const _LanguageOption({
      required this.flag,
      required this.label,
      required this.isSelected,
      required this.onTap,
    });

    @override
    Widget build(BuildContext context) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: AppOpacity.faint)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: AppOpacity.muted)
                  : AppColors.babyBlueIce.withValues(alpha: AppOpacity.half),
            ),
          ),
          child: Row(
            children: <Widget>[
              Text(flag, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
            ],
          ),
        ),
      );
    }
  }
  ```
- **MIRROR**: SHOW_DIALOG_PATTERN, LANGUAGE_OPTION_ROW
- **IMPORTS**: `localeProvider` already imported. `AppDialog` — add import if missing.
- **GOTCHA**: `AppDialog` needs `body` widget. The `actions` list with a single Cancel uses horizontal layout (≤2 actions = row). The dialog closes automatically when a language is selected via `Navigator.of(context).pop()` inside `_LanguageOption.onTap`.
- **VALIDATE**: Language menu item opens a modal with English/French options. Current language is checked. Switching language changes the UI immediately and dismisses the dialog.

### Task 8: Remove "Edit profile" from Account Menu
- **ACTION**: Delete the `_MenuItem` for 'Edit profile' from `_MenuList` in the Profile tab's ListView (lines ~321-327)
- **IMPLEMENT**: In `_ProfileTabState.build`, remove this item from the list:
  ```dart
  // DELETE this item:
  _MenuItem(
    icon: Icons.edit_rounded,
    label: isFrench ? 'Modifier le profil' : 'Edit profile',
    onTap: () => _showComingSoon(isFrench),
  ),
  ```
- **GOTCHA**: The `_MenuList` renders dividers between items using `isLast` flag. After removing Edit, the order becomes: Trophies, Language, Settings, Privacy. Verify `isLast: true` is still only on Privacy.
- **VALIDATE**: Account section shows 4 items (Trophies, Language, Settings, Privacy) without Edit profile.

### Task 9: Delete Unused `_EditProfileButton` Widget
- **ACTION**: Remove the `_EditProfileButton` class entirely since it's replaced by `_BannerEditButton`
- **IMPLEMENT**: Delete lines 602-655 (`_EditProfileButton` class) from profile_tab.dart
- **GOTCHA**: Ensure no other reference to `_EditProfileButton` exists — search with grep first
- **VALIDATE**: File compiles without `_EditProfileButton`

---

## Testing Strategy

### Manual Test Checklist
- [ ] Banner is taller and visually distinct
- [ ] Avatar appears on the left with correct spacing
- [ ] Username appears inside the banner to the right of the avatar
- [ ] Email badge appears below the banner in the white section
- [ ] Edit button (pencil) appears at bottom-right of banner
- [ ] Tapping Edit opens the bottom sheet with the current username pre-filled
- [ ] Typing a new name and saving updates the banner username without restart
- [ ] Saving shows a loading spinner, then closes the sheet
- [ ] Logout button opens a confirmation dialog with destructive style
- [ ] Canceling the logout dialog does not log out
- [ ] Confirming the logout navigates to auth screen
- [ ] Language menu item opens a modal (not a new page)
- [ ] Current language has a checkmark in the modal
- [ ] Switching language closes the modal and updates the UI
- [ ] Account block has only 4 items (no "Edit profile")
- [ ] No regressions in Friends tab
- [ ] No regressions in Stats & Graph navigation

### Edge Cases Checklist
- [ ] Username is empty → Save with empty input → No crash, no save (navigator pops)
- [ ] Network failure during username save → SnackBar shown, spinner stopped
- [ ] Very long username → Text ellipsis in banner
- [ ] No email → Email badge not shown
- [ ] French locale → All text in French (dialog titles, buttons)

---

## Validation Commands

### Static Analysis
```bash
flutter analyze lib/views/profile/profile_tab.dart
```
EXPECT: Zero errors, zero warnings

### Build Check
```bash
flutter build apk --debug 2>&1 | tail -5
```
EXPECT: Build succeeds

### Manual Validation
1. `flutter run` → Navigate to Profile tab
2. Verify banner height, avatar position, username placement
3. Tap Edit button → verify bottom sheet
4. Change username → verify update
5. Tap Logout → verify dialog → Cancel → verify no logout
6. Tap Language → verify modal → switch → verify UI update
7. Verify Account section has no "Edit profile" item

---

## Acceptance Criteria
- [ ] All 9 tasks completed
- [ ] Static analysis clean
- [ ] All manual tests pass
- [ ] No `_EditProfileButton` class remaining
- [ ] No Navigator.push to LanguageSelectionScreen from profile
- [ ] Logout requires confirmation
- [ ] Edit profile bottom sheet saves to Firestore and Firebase Auth

## Completion Checklist
- [ ] Banner height constant `_kBannerHeight = 130.0`
- [ ] Avatar left-positioned inside banner
- [ ] Username in banner (white text)
- [ ] Email below banner in white section
- [ ] `_BannerEditButton` replaces `_EditProfileButton`
- [ ] `_EditProfileSheet` implemented and wired
- [ ] `_confirmLogout` wraps `_logout`
- [ ] `_LanguagePickerDialog` and `_LanguageOption` implemented
- [ ] "Edit profile" menu item removed from `_MenuList`
- [ ] `_EditProfileButton` class deleted

## Risks
| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Avatar doesn't fit in new banner | Low | Visual glitch | Adjust `_kBannerHeight` or avatar vertical centering formula |
| Username too long overflows banner | Medium | Layout break | `maxLines: 2, overflow: TextOverflow.ellipsis` on username text |
| `AppDialog` import missing | Low | Compile error | Add `import 'package:workin_fit/widgets/app_dialog.dart';` |
| `localeProvider` import missing in dialog | Low | Compile error | `_LanguagePickerDialog` is in same file where `choose_language.dart` was imported — verify import exists |
| `_userProfileProvider` private symbol | None | — | `_EditProfileSheet` is in same file, so it can access it |

## Notes
- `choose_language.dart` stays unchanged — it's still used in the welcome/onboarding flow
- `_showComingSoon` helper can remain for Settings and Privacy items
- The `_InlineStats` widget stays unchanged; only its position in the layout changes (moves below the email badge)
- The `_ProfileHeaderSliver` constructor gains no new parameters — `onEditProfile` callback already exists; only its call site changes to pass `username`
