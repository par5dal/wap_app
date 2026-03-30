// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get loginPageTitle => 'Login';

  @override
  String get loginPageSubtitle => 'Discover plans near you';

  @override
  String get loginPageEmailHint => 'Email';

  @override
  String get loginPagePasswordHint => 'Password';

  @override
  String get loginPageForgotPassword => 'Forgot your password?';

  @override
  String get loginPageLoginButton => 'Login';

  @override
  String get loginPageNoAccount => 'Don\'t have an account?';

  @override
  String get loginPageRegister => 'Sign Up';

  @override
  String get loginPageTermsAndPolicy =>
      'By continuing you accept the Terms and Privacy Policy';

  @override
  String get loginSuccessMessage => 'Login successful!';

  @override
  String get loginErrorMessage =>
      'Incorrect credentials or server error. Try again.';

  @override
  String get registerEmailVerifTitle => 'Confirm your email';

  @override
  String registerEmailVerifMessage(String email) {
    return 'We\'ve sent a confirmation email to $email. Please check your inbox and click the link to activate your account.';
  }

  @override
  String get ok => 'OK';

  @override
  String get registerPageTitle => 'Create Account';

  @override
  String get registerPageSubtitle => 'Start discovering amazing plans';

  @override
  String get registerPageRegisterButton => 'Create Account';

  @override
  String get registerPageLoginPrompt => 'Already have an account?';

  @override
  String get registerPageTermsAndPolicy =>
      'By signing up you accept the Terms and Privacy Policy';

  @override
  String get registerPageLoginLink => 'Login';

  @override
  String get authPageWelcome => 'Welcome!';

  @override
  String get authPageSubtitle => 'Discover plans near you';

  @override
  String get authPageEmailOrRegister => 'Login or sign up';

  @override
  String get authPageLogin => 'Login';

  @override
  String get authPageCreateAccount => 'Create your account';

  @override
  String get authPageContinueWithEmail => 'Continue with email';

  @override
  String get authPageContinueWithGoogle => 'Continue with Google';

  @override
  String get authPageContinueWithApple => 'Continue with Apple';

  @override
  String get authPageContinue => 'Continue';

  @override
  String get authPageGoBack => 'Go back';

  @override
  String get authPageChangeEmail => 'Change email';

  @override
  String get authPageAcceptTerms => 'I accept the terms and conditions';

  @override
  String get authPageMustAcceptTerms =>
      'You must accept the terms and conditions';

  @override
  String get authPageConfirmPassword => 'Confirm password';

  @override
  String get authPageConfirmPasswordRequired => 'Please confirm your password';

  @override
  String get authPagePasswordsDoNotMatch => 'Passwords do not match';

  @override
  String get validatorRequired => 'This field is required';

  @override
  String get validatorInvalidEmail => 'Invalid email format';

  @override
  String get validatorPasswordLength =>
      'Password must be at least 8 characters';

  @override
  String get googleSignInButton => 'Continue with Google';

  @override
  String get homePageTitle => 'Home';

  @override
  String get navBarProfile => 'Profile';

  @override
  String get navBarSearch => 'Search';

  @override
  String get navBarList => 'List';

  @override
  String get navBarLocation => 'Location';

  @override
  String get navBarLogin => 'Login';

  @override
  String get navBarLogout => 'Logout';

  @override
  String get eventCardDetails => 'Details';

  @override
  String get eventCardGo => 'Go';

  @override
  String get eventCardFree => 'Free';

  @override
  String eventCardFromPrice(String price) {
    return 'From $price';
  }

  @override
  String eventCardTodayAt(String time) {
    return 'Today, $time';
  }

  @override
  String eventCardDistance(String distance) {
    return '$distance km';
  }

  @override
  String get errorLocationDisabled => 'Location services are disabled.';

  @override
  String get errorLocationDenied => 'Location permissions are denied.';

  @override
  String get errorLocationDeniedForever =>
      'Location permissions are permanently denied. Please enable them in app settings.';

  @override
  String get errorLoadingEvents => 'Could not load nearby plans.';

  @override
  String get logoutDialogTitle => 'Logout';

  @override
  String get logoutDialogMessage => 'Are you sure you want to logout?';

  @override
  String get logoutDialogCancel => 'Cancel';

  @override
  String get logoutDialogConfirm => 'Logout';

  @override
  String get logoutSuccessMessage => 'Logged out successfully!';

  @override
  String get logoutErrorMessage => 'Error logging out. Try again.';

  @override
  String get profileTitle => 'Your Profile';

  @override
  String get profileTabProfile => 'Profile';

  @override
  String get profileTabFavorites => 'Favorites';

  @override
  String get profileTabFollowing => 'Promoters';

  @override
  String get profileFirstName => 'Name';

  @override
  String get profileFirstNameHint => 'Enter your name';

  @override
  String get profileLastName => 'Surnames';

  @override
  String get profileLastNameHint => 'Enter your surnames';

  @override
  String get profileDateOfBirth => 'Date of birth';

  @override
  String get profileAddress => 'Address';

  @override
  String get profileAddressHint => 'Street, number, city';

  @override
  String get profileSave => 'Save';

  @override
  String get profileOmit => 'Omit';

  @override
  String get profileSelectImageSource => 'Select image source';

  @override
  String get profileCamera => 'Camera';

  @override
  String get profileGallery => 'Gallery';

  @override
  String get profileRemoveAvatar => 'Remove profile picture';

  @override
  String get profileRemoveAvatarConfirmation =>
      'Are you sure you want to remove your profile picture?';

  @override
  String get cancel => 'Cancel';

  @override
  String get remove => 'Remove';

  @override
  String get profileUpdateSuccess => 'Profile updated successfully';

  @override
  String get profileNoFavorites => 'You don\'t have favorite plans';

  @override
  String get profileNoFollowing => 'You\'re not following any promoter';

  @override
  String get retry => 'Retry';

  @override
  String get eventDetailDescription => 'Description';

  @override
  String get eventDetailLocation => 'Location';

  @override
  String get eventDetailOpenMap => 'Get Directions';

  @override
  String get eventDetailOrganizer => 'Organizer';

  @override
  String get eventDetailViewProfile => 'View Profile';

  @override
  String get eventDetailFollow => 'Follow';

  @override
  String get eventDetailSave => 'Save';

  @override
  String get eventDetailBuyTicket => 'Buy Ticket';

  @override
  String get eventDetailSignUp => 'Sign me up!';

  @override
  String get promoterProfileEvents => 'Plans';

  @override
  String get promoterProfileFollowers => 'Followers';

  @override
  String get promoterProfileFollow => 'Follow';

  @override
  String get promoterProfileUnfollow => 'Unfollow';

  @override
  String get promoterProfileEventsList => 'Organizer\'s Plans';

  @override
  String get promoterProfileNoEvents => 'No published plans';

  @override
  String get authDialogTitle => 'Join WAP!';

  @override
  String get authDialogDescription =>
      'Login or sign up to access your profile, save favorite plans and much more';

  @override
  String get authDialogLogin => 'Login';

  @override
  String get authDialogRegister => 'Create account';

  @override
  String get favoriteAddedMessage => 'Added to favorites';

  @override
  String get favoriteRemovedMessage => 'Removed from favorites';

  @override
  String get followingAddedMessage => 'Now following this promoter';

  @override
  String get followingRemovedMessage => 'Stopped following promoter';

  @override
  String get favoriteSaved => 'Saved';

  @override
  String get favoriteAddToFavorites => 'Add to favorites';

  @override
  String get favoriteRemoveFromFavorites => 'Remove from favorites';

  @override
  String get locationBannerTitle => 'Location disabled';

  @override
  String get locationBannerMessage =>
      'To see plans near you, enable location services';

  @override
  String get locationBannerAction => 'Enable location';

  @override
  String get locationBannerDismiss => 'View all plans';

  @override
  String get noLocationEventsTitle => 'Showing all plans';

  @override
  String get noLocationEventsMessage =>
      'Enable location to see nearby plans first';

  @override
  String get eventFinishedBanner => 'This plan has already taken place';

  @override
  String get promoterProfileUpcoming => 'Upcoming';

  @override
  String get promoterProfilePast => 'Past';

  @override
  String get favoritesUpcoming => 'Upcoming';

  @override
  String get favoritesPast => 'Past';

  @override
  String get favoritesNoUpcoming => 'No upcoming plans in your favorites';

  @override
  String get favoritesNoPast => 'No past plans in your favorites';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionLanguage => 'Language';

  @override
  String get settingsLanguageDevice => 'Device language';

  @override
  String get settingsLanguageEs => 'Español';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsLanguagePt => 'Português';

  @override
  String get settingsLanguageSaved => 'Language saved';

  @override
  String get settingsSectionLegal => 'Legal';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsTermsOfUse => 'Terms of Use';

  @override
  String get settingsSectionAppearance => 'Appearance';

  @override
  String get settingsThemeSystem => 'Follow device';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeSaved => 'Theme saved';

  @override
  String get settingsSectionNotifications => 'Notifications';

  @override
  String get settingsNotifNewEvents => 'New plans from followed promoters';

  @override
  String get settingsNotifNewEventsDesc =>
      'Receive a push notification when a promoter you follow publishes a new plan';

  @override
  String get settingsNotifModerationEmail => 'Moderation emails';

  @override
  String get settingsNotifModerationEmailDesc =>
      'Receive an email when an admin approves or rejects one of your events';

  @override
  String get settingsNotifAllPaused => 'Mute all notifications';

  @override
  String get settingsNotifAllPausedDesc =>
      'Temporarily disable all notifications without losing your settings';

  @override
  String get settingsNotifSaved => 'Preferences saved';

  @override
  String get settingsNotifGuestBanner => 'Sign up to WAP and never miss a plan';

  @override
  String get settingsNotifGuestBannerCta => 'Sign up for free';

  @override
  String get settingsSectionPermissions => 'Permissions';

  @override
  String get settingsPermLocation => 'Location';

  @override
  String get settingsPermLocationDesc =>
      'Required to center the map on your current position';

  @override
  String get settingsPermNotifications => 'Notifications';

  @override
  String get settingsPermNotificationsDesc =>
      'To receive alerts about new plans from promoters you follow';

  @override
  String get settingsPermCamera => 'Camera & Photos';

  @override
  String get settingsPermCameraDesc => 'To upload or change your profile photo';

  @override
  String get settingsPermStatusGranted => 'Granted';

  @override
  String get settingsPermStatusDenied => 'Not granted';

  @override
  String get settingsPermStatusBlocked => 'Blocked';

  @override
  String get settingsPermOpenSettings => 'Open settings';

  @override
  String get settingsPermRevokeHint =>
      'To revoke this permission go to system settings';

  @override
  String get settingsPermActivateHint =>
      'To allow this permission go to your device settings';

  @override
  String get filterTitle => 'Filters';

  @override
  String get filterClear => 'Clear';

  @override
  String get filterApply => 'Apply';

  @override
  String get filterSectionDate => 'Date';

  @override
  String get filterDateAny => 'Any date';

  @override
  String get filterDateToday => 'Today';

  @override
  String get filterDateTomorrow => 'Tomorrow';

  @override
  String get filterDateThisWeek => 'This week';

  @override
  String get filterDateThisWeekend => 'This weekend';

  @override
  String get filterDateChoose => 'Choose date';

  @override
  String get filterDateFrom => 'From';

  @override
  String get filterDateTo => 'To';

  @override
  String get filterSectionCategory => 'Category';

  @override
  String get filterCategoryAll => 'All';

  @override
  String get filterSectionPrice => 'Price';

  @override
  String get filterOnlyFree => 'Free plans only';

  @override
  String get filterPriceMin => 'Minimum';

  @override
  String get filterPriceMax => 'Maximum';

  @override
  String get categoriesTitle => 'Plan Categories';

  @override
  String get categoriesError => 'Error loading categories';

  @override
  String get categoriesEmpty => 'No categories found';

  @override
  String get categoryPlansError => 'Error loading plans';

  @override
  String get categoryPlansEmpty => 'No plans';

  @override
  String get categoryPlansEmptyBody => 'No plans available\nin this category';

  @override
  String get plansListSearchHint => 'Search plans...';

  @override
  String get plansListEmpty => 'No plans visible on the map';

  @override
  String get plansListMoveMap => 'Move the map or adjust filters';

  @override
  String get toolbarDiscoverTitle => 'Explore WAP';

  @override
  String get toolbarDiscoverSubtitle => 'Discover plans and promoters';

  @override
  String get toolbarDiscoverCategories => 'Plans by Category';

  @override
  String get toolbarDiscoverCategoriesSubtitle =>
      'Explore plans organized by type';

  @override
  String get toolbarDiscoverPromoters => 'Promoters Directory';

  @override
  String get toolbarDiscoverPromotersSubtitle => 'Meet the plan organizers';

  @override
  String get toolbarDiscoverPromoterAccess => 'Promoter Access';

  @override
  String get toolbarDiscoverPromoterAccessSubtitle =>
      'Create and manage your plans on WAP';

  @override
  String get promotersTitle => 'Promoters Directory';

  @override
  String get promotersSearchHint => 'Search promoters...';

  @override
  String get promotersEmpty => 'No promoters found';

  @override
  String get promotersStatPlans => 'Plans';

  @override
  String get serverConnectionError => 'Error connecting to server';

  @override
  String get favoritesError => 'Error loading favorites';

  @override
  String get favoritesDeleteLabel => 'Delete';

  @override
  String get favoritesDeleteTitle => 'Delete favorite';

  @override
  String get favoritesDeleteConfirm =>
      'Do you want to remove this plan from your favorites?';

  @override
  String get followingUnfollowSwipeLabel => 'Unfollow';

  @override
  String get followingDialogTitle => 'Unfollow';

  @override
  String followingDialogBody(String name) {
    return 'Do you want to unfollow $name?';
  }

  @override
  String get eventDetailNoDescription => 'No description available.';

  @override
  String get eventDetailNoAddress => 'Address not available';

  @override
  String get eventDetailDefaultOrganizer => 'Plan Organizer';

  @override
  String get forgotPasswordPageTitle => 'Forgot your password?';

  @override
  String get forgotPasswordPageSubtitle =>
      'Enter your email and we\'ll send you a recovery link';

  @override
  String get forgotPasswordPageSendButton => 'Send link';

  @override
  String get forgotPasswordPageSuccessTitle => 'Check your email';

  @override
  String get forgotPasswordPageSuccessMessage =>
      'If the email is registered, you will receive a link shortly';

  @override
  String get forgotPasswordPageBackToLogin => 'Back to login';

  @override
  String get changePasswordPageTitle => 'Change password';

  @override
  String get changePasswordPageCurrentPassword => 'Current password';

  @override
  String get changePasswordPageNewPassword => 'New password';

  @override
  String get changePasswordPageConfirmPassword => 'Confirm new password';

  @override
  String get changePasswordPageSaveButton => 'Change password';

  @override
  String get changePasswordPageSuccess => 'Password changed successfully';

  @override
  String get changePasswordProfileTile => 'Change password';

  @override
  String get deleteAccountProfileTile => 'Delete account';

  @override
  String get deleteAccountConfirmTitle => 'Delete your account?';

  @override
  String get deleteAccountConfirmMessage =>
      'You will receive an email to confirm the deletion. This action is irreversible.';

  @override
  String get deleteAccountConfirmButton => 'Delete my account';

  @override
  String get deleteAccountSuccess => 'Check your email to confirm deletion';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsEmpty => 'You have no notifications';

  @override
  String get notificationsMarkAllRead => 'Mark all as read';

  @override
  String get notificationsDeleteAll => 'Delete all';

  @override
  String get notificationsDeleteConfirm =>
      'Are you sure you want to delete all notifications?';

  @override
  String get profilePromotersSectionFollowing => 'Promoters you follow';

  @override
  String get profilePromotersSectionBlocked => 'Blocked promoters';

  @override
  String get profileNoBlocked => 'You haven\'t blocked any promoters yet';

  @override
  String get profileUnblockDialogTitle => 'Unblock promoter';

  @override
  String profileUnblockDialogBody(String name) {
    return 'Do you want to unblock $name?';
  }

  @override
  String get profileUnblockLabel => 'Unblock';

  @override
  String get forceUpdateTitle => 'Update required';

  @override
  String get forceUpdateMessage =>
      'A new version is available with important improvements and fixes. Please update the app to continue.';

  @override
  String get forceUpdateButton => 'Update now';

  @override
  String get settingsSectionInfo => 'Information';

  @override
  String get settingsInfoVersion => 'Version';

  @override
  String get settingsInfoRateApp => 'Rate the app';

  @override
  String get noConnectionBanner => 'No internet connection';
}
