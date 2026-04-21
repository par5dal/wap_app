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
  String eventCardTomorrowAt(String time) {
    return 'Tomorrow, $time';
  }

  @override
  String eventCardOngoing(String date) {
    return 'Ongoing · until $date';
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
  String eventDetailEndDate(String date) {
    return 'Until $date';
  }

  @override
  String get eventDetailDescription => 'Description';

  @override
  String get eventDetailSource => 'Source';

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
      'Receive an email when an admin approves or rejects one of your plans';

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
  String get settingsSectionTutorials => 'Tutorials';

  @override
  String get settingsTutorialReplay => 'Watch the tutorial again';

  @override
  String get settingsTutorialReplayDesc =>
      'It will be shown the next time you open the app';

  @override
  String get settingsTutorialReplayConfirm =>
      'Restart the app to see the tutorial';

  @override
  String get onboardingSlide1Title => 'Welcome to WAP!';

  @override
  String get onboardingSlide1Subtitle =>
      'The app that connects people with amazing plans near them. Discover it in 30 seconds.';

  @override
  String get onboardingSlide2Title => 'Thousands of plans near you';

  @override
  String get onboardingSlide2Subtitle =>
      'Explore the map, filter by category and find your next perfect plan in real time.';

  @override
  String get onboardingSlide3Title => 'Save what you love';

  @override
  String get onboardingSlide3Subtitle =>
      'Mark your favourite plans, follow your promoters and get notified when they post something new.';

  @override
  String get onboardingSlide4Title => 'Got plans worth sharing?';

  @override
  String get onboardingSlide4Subtitle =>
      'Create your promoter profile, publish your plans and reach thousands of people near you.';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingStart => 'Get started';

  @override
  String get settingsSectionInfo => 'Information';

  @override
  String get settingsInfoVersion => 'Version';

  @override
  String get settingsInfoRateApp => 'Rate the app';

  @override
  String get noConnectionBanner => 'No internet connection';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get delete => 'Delete';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get genericError => 'Something went wrong. Please try again.';

  @override
  String get forPromotersHeroTitle => 'Reach more people with your plans';

  @override
  String get forPromotersHeroSubtitle =>
      'Publish your plans, manage ticket sales and grow your audience.';

  @override
  String get forPromotersBenefitsTitle => 'What you get as a promoter';

  @override
  String get forPromotersBenefit1Title => 'Create & publish plans';

  @override
  String get forPromotersBenefit1Desc =>
      'Set up your plan in minutes with our step-by-step wizard.';

  @override
  String get forPromotersBenefit2Title => 'Track your performance';

  @override
  String get forPromotersBenefit2Desc =>
      'Monitor views, favorites and engagement in real time.';

  @override
  String get forPromotersBenefit3Title => 'Reach local audiences';

  @override
  String get forPromotersBenefit3Desc =>
      'Your plans appear on the map for users nearby.';

  @override
  String get forPromotersBenefit4Title => 'Simple management';

  @override
  String get forPromotersBenefit4Desc =>
      'Edit, publish, pause or delete your plans at any time.';

  @override
  String get forPromotersCtaRegister => 'Register for free';

  @override
  String get forPromotersCtaLogin => 'Already have an account? Login';

  @override
  String get upgradeToPromoterTitle => 'Become a Promoter';

  @override
  String get upgradeToPromoterHeroTitle => 'Take your plans to the next level';

  @override
  String get upgradeToPromoterHeroSubtitle =>
      'Upgrade your account to start publishing plans and reaching thousands of people.';

  @override
  String get upgradeToPromoterBenefitsTitle => 'Promoter benefits';

  @override
  String get upgradeToPromoterBenefit1 => 'Create and publish plans on the map';

  @override
  String get upgradeToPromoterBenefit2 =>
      'Analytics dashboard with views and favorites';

  @override
  String get upgradeToPromoterBenefit3 => 'Manage your venues and plan details';

  @override
  String get upgradeToPromoterBenefit4 => 'Grow your audience of followers';

  @override
  String get upgradeToPromoterCta => 'Upgrade my account';

  @override
  String get upgradeToPromoterSuccess => 'Your account has been upgraded!';

  @override
  String get dashboardTitle => 'My Plans';

  @override
  String get dashboardTabActive => 'Active';

  @override
  String get dashboardTabFinished => 'Finished';

  @override
  String get dashboardCreateEvent => 'Create plan';

  @override
  String get dashboardStatsTotalEvents => 'Total plans';

  @override
  String get dashboardStatsActiveEvents => 'Active';

  @override
  String get dashboardStatsTotalViews => 'Views';

  @override
  String get dashboardStatsTotalFavorites => 'Favorites';

  @override
  String get dashboardStatsFollowers => 'Followers';

  @override
  String get dashboardSearchHint => 'Search my plans…';

  @override
  String get dashboardNoEvents => 'No plans yet. Create your first one!';

  @override
  String get dashboardDeleteEvent => 'Delete plan';

  @override
  String get dashboardDeleteEventTitle => 'Delete this plan?';

  @override
  String get dashboardDeleteEventConfirm => 'This action cannot be undone.';

  @override
  String get manageEventCreateTitle => 'Create plan';

  @override
  String get manageEventEditTitle => 'Edit plan';

  @override
  String get manageEventStep1 => 'Details';

  @override
  String get manageEventStep2 => 'Venue';

  @override
  String get manageEventStep3 => 'Images';

  @override
  String get manageEventStep4 => 'Publish';

  @override
  String get manageEventTitle => 'Title';

  @override
  String get manageEventTitleHint => 'Give your plan a great name';

  @override
  String get manageEventDescription => 'Description';

  @override
  String get manageEventDescriptionHint => 'Tell people what to expect';

  @override
  String get manageEventPrice => 'Price (€)';

  @override
  String get manageEventPriceHint => '0 for free plans';

  @override
  String get manageEventDates => 'Dates';

  @override
  String get manageEventStartDate => 'Start';

  @override
  String get manageEventEndDate => 'End';

  @override
  String get manageEventCategories => 'Categories';

  @override
  String get manageEventPickDates => 'Pick dates';

  @override
  String get manageEventEndBeforeStart => 'End date must be after start date';

  @override
  String get manageEventPickCategory => 'Select at least one category';

  @override
  String get manageEventInvalidPrice => 'Enter a valid price';

  @override
  String get manageEventMyVenues => 'My venues';

  @override
  String get manageEventSearchVenue => 'Search';

  @override
  String get manageEventNoSavedVenues => 'No saved venues';

  @override
  String get manageEventSearchPlaceholder => 'Search for a venue or address…';

  @override
  String get manageEventNoResults => 'No results found';

  @override
  String get manageEventVenue => 'Venue';

  @override
  String get manageEventImagesTitle => 'Plan images';

  @override
  String get manageEventImagesSubtitle =>
      'Add up to 3 images. The first one will be the cover photo.';

  @override
  String get manageEventImageSourceCamera => 'Camera';

  @override
  String get manageEventImageSourceGallery => 'Gallery';

  @override
  String get manageEventCameraPermissionDenied =>
      'Camera permission is required to take photos';

  @override
  String get settings => 'Settings';

  @override
  String get manageEventAddImage => 'Add image';

  @override
  String get manageEventFree => 'Free';

  @override
  String get manageEventPreviewBadge => 'Preview';

  @override
  String get manageEventPrimaryImage => 'Cover';

  @override
  String get manageEventImage => 'Image';

  @override
  String get manageEventImagesCount => 'Images';

  @override
  String get manageEventReviewTitle => 'Review & Publish';

  @override
  String get manageEventSaveDraft => 'Save as draft';

  @override
  String get manageEventPublish => 'Submit for review';

  @override
  String get manageEventCreateSuccess => 'Plan created successfully!';

  @override
  String get manageEventUpdateSuccess => 'Plan updated successfully!';

  @override
  String get eventStatusPublished => 'Published';

  @override
  String get eventStatusFinished => 'Finished';

  @override
  String get eventStatusCancelled => 'Cancelled';

  @override
  String get eventStatusPendingApproval => 'Pending approval';

  @override
  String get eventStatusRejected => 'Rejected';

  @override
  String get eventStatusDraft => 'Draft';

  @override
  String get eventStatusUnpublish => 'Unpublish';

  @override
  String get eventStatusDescription => 'Description';

  @override
  String get categoryAddMore => 'Add more categories';

  @override
  String get closeAction => 'Close';
}
