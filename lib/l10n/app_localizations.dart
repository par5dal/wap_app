import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt'),
  ];

  /// El título principal en la página de inicio de sesión
  ///
  /// In es, this message translates to:
  /// **'Iniciar Sesión'**
  String get loginPageTitle;

  /// No description provided for @loginPageSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Descubre planes cerca de ti'**
  String get loginPageSubtitle;

  /// No description provided for @loginPageEmailHint.
  ///
  /// In es, this message translates to:
  /// **'Correo Electrónico'**
  String get loginPageEmailHint;

  /// No description provided for @loginPagePasswordHint.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get loginPagePasswordHint;

  /// No description provided for @loginPageForgotPassword.
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu contraseña?'**
  String get loginPageForgotPassword;

  /// No description provided for @loginPageLoginButton.
  ///
  /// In es, this message translates to:
  /// **'Iniciar Sesión'**
  String get loginPageLoginButton;

  /// No description provided for @loginPageNoAccount.
  ///
  /// In es, this message translates to:
  /// **'¿No tienes cuenta?'**
  String get loginPageNoAccount;

  /// No description provided for @loginPageRegister.
  ///
  /// In es, this message translates to:
  /// **'Regístrate'**
  String get loginPageRegister;

  /// No description provided for @loginPageTermsAndPolicy.
  ///
  /// In es, this message translates to:
  /// **'Al continuar aceptas los Términos y la Política de Privacidad'**
  String get loginPageTermsAndPolicy;

  /// No description provided for @loginSuccessMessage.
  ///
  /// In es, this message translates to:
  /// **'¡Login exitoso!'**
  String get loginSuccessMessage;

  /// No description provided for @loginErrorMessage.
  ///
  /// In es, this message translates to:
  /// **'Credenciales incorrectas o error del servidor. Inténtalo de nuevo.'**
  String get loginErrorMessage;

  /// No description provided for @registerEmailVerifTitle.
  ///
  /// In es, this message translates to:
  /// **'Confirma tu email'**
  String get registerEmailVerifTitle;

  /// No description provided for @registerEmailVerifMessage.
  ///
  /// In es, this message translates to:
  /// **'Hemos enviado un correo de confirmación a {email}. Por favor, revisa tu bandeja de entrada y pulsa el enlace para activar tu cuenta.'**
  String registerEmailVerifMessage(String email);

  /// No description provided for @ok.
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get ok;

  /// No description provided for @registerPageTitle.
  ///
  /// In es, this message translates to:
  /// **'Crear Cuenta'**
  String get registerPageTitle;

  /// No description provided for @registerPageSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Empieza a descubrir planes increíbles'**
  String get registerPageSubtitle;

  /// No description provided for @registerPageRegisterButton.
  ///
  /// In es, this message translates to:
  /// **'Crear Cuenta'**
  String get registerPageRegisterButton;

  /// No description provided for @registerPageLoginPrompt.
  ///
  /// In es, this message translates to:
  /// **'¿Ya tienes una cuenta?'**
  String get registerPageLoginPrompt;

  /// No description provided for @registerPageTermsAndPolicy.
  ///
  /// In es, this message translates to:
  /// **'Al registrarte aceptas los Términos y la Política de Privacidad'**
  String get registerPageTermsAndPolicy;

  /// No description provided for @registerPageLoginLink.
  ///
  /// In es, this message translates to:
  /// **'Inicia Sesión'**
  String get registerPageLoginLink;

  /// No description provided for @authPageWelcome.
  ///
  /// In es, this message translates to:
  /// **'¡Bienvenido!'**
  String get authPageWelcome;

  /// No description provided for @authPageSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Descubre planes cerca de ti'**
  String get authPageSubtitle;

  /// No description provided for @authPageEmailOrRegister.
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión o regístrate'**
  String get authPageEmailOrRegister;

  /// No description provided for @authPageLogin.
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión'**
  String get authPageLogin;

  /// No description provided for @authPageCreateAccount.
  ///
  /// In es, this message translates to:
  /// **'Crea tu cuenta'**
  String get authPageCreateAccount;

  /// No description provided for @authPageContinueWithEmail.
  ///
  /// In es, this message translates to:
  /// **'Continuar con correo electrónico'**
  String get authPageContinueWithEmail;

  /// No description provided for @authPageContinueWithGoogle.
  ///
  /// In es, this message translates to:
  /// **'Continuar con Google'**
  String get authPageContinueWithGoogle;

  /// No description provided for @authPageContinueWithApple.
  ///
  /// In es, this message translates to:
  /// **'Continuar con Apple'**
  String get authPageContinueWithApple;

  /// No description provided for @authPageContinue.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get authPageContinue;

  /// No description provided for @authPageGoBack.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get authPageGoBack;

  /// No description provided for @authPageChangeEmail.
  ///
  /// In es, this message translates to:
  /// **'Cambiar email'**
  String get authPageChangeEmail;

  /// No description provided for @authPageAcceptTerms.
  ///
  /// In es, this message translates to:
  /// **'Acepto los términos y condiciones'**
  String get authPageAcceptTerms;

  /// No description provided for @authPageMustAcceptTerms.
  ///
  /// In es, this message translates to:
  /// **'Debes aceptar los términos y condiciones'**
  String get authPageMustAcceptTerms;

  /// No description provided for @authPageConfirmPassword.
  ///
  /// In es, this message translates to:
  /// **'Confirmar contraseña'**
  String get authPageConfirmPassword;

  /// No description provided for @authPageConfirmPasswordRequired.
  ///
  /// In es, this message translates to:
  /// **'Por favor confirma tu contraseña'**
  String get authPageConfirmPasswordRequired;

  /// No description provided for @authPagePasswordsDoNotMatch.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get authPagePasswordsDoNotMatch;

  /// No description provided for @validatorRequired.
  ///
  /// In es, this message translates to:
  /// **'Este campo es requerido'**
  String get validatorRequired;

  /// No description provided for @validatorInvalidEmail.
  ///
  /// In es, this message translates to:
  /// **'Formato de email inválido'**
  String get validatorInvalidEmail;

  /// No description provided for @validatorPasswordLength.
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe tener al menos 8 caracteres'**
  String get validatorPasswordLength;

  /// Texto para el botón de inicio de sesión con Google
  ///
  /// In es, this message translates to:
  /// **'Continuar con Google'**
  String get googleSignInButton;

  /// No description provided for @homePageTitle.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get homePageTitle;

  /// No description provided for @navBarProfile.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get navBarProfile;

  /// No description provided for @navBarSearch.
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get navBarSearch;

  /// No description provided for @navBarList.
  ///
  /// In es, this message translates to:
  /// **'Listado'**
  String get navBarList;

  /// No description provided for @navBarLocation.
  ///
  /// In es, this message translates to:
  /// **'Ubicación'**
  String get navBarLocation;

  /// No description provided for @navBarLogin.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get navBarLogin;

  /// No description provided for @navBarLogout.
  ///
  /// In es, this message translates to:
  /// **'Salir'**
  String get navBarLogout;

  /// No description provided for @eventCardDetails.
  ///
  /// In es, this message translates to:
  /// **'Detalles'**
  String get eventCardDetails;

  /// No description provided for @eventCardGo.
  ///
  /// In es, this message translates to:
  /// **'Ir'**
  String get eventCardGo;

  /// No description provided for @eventCardFree.
  ///
  /// In es, this message translates to:
  /// **'Gratis'**
  String get eventCardFree;

  /// No description provided for @eventCardFromPrice.
  ///
  /// In es, this message translates to:
  /// **'Desde {price}'**
  String eventCardFromPrice(String price);

  /// No description provided for @eventCardTodayAt.
  ///
  /// In es, this message translates to:
  /// **'Hoy, {time}'**
  String eventCardTodayAt(String time);

  /// No description provided for @eventCardDistance.
  ///
  /// In es, this message translates to:
  /// **'{distance} km'**
  String eventCardDistance(String distance);

  /// No description provided for @errorLocationDisabled.
  ///
  /// In es, this message translates to:
  /// **'Los servicios de ubicación están desactivados.'**
  String get errorLocationDisabled;

  /// No description provided for @errorLocationDenied.
  ///
  /// In es, this message translates to:
  /// **'Los permisos de ubicación fueron denegados.'**
  String get errorLocationDenied;

  /// No description provided for @errorLocationDeniedForever.
  ///
  /// In es, this message translates to:
  /// **'Los permisos de ubicación están permanentemente denegados. Actívalos en los ajustes de la app.'**
  String get errorLocationDeniedForever;

  /// No description provided for @errorLoadingEvents.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar los planes cercanos.'**
  String get errorLoadingEvents;

  /// No description provided for @logoutDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Cerrar Sesión'**
  String get logoutDialogTitle;

  /// No description provided for @logoutDialogMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres cerrar sesión?'**
  String get logoutDialogMessage;

  /// No description provided for @logoutDialogCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get logoutDialogCancel;

  /// No description provided for @logoutDialogConfirm.
  ///
  /// In es, this message translates to:
  /// **'Salir'**
  String get logoutDialogConfirm;

  /// No description provided for @logoutSuccessMessage.
  ///
  /// In es, this message translates to:
  /// **'¡Sesión cerrada correctamente!'**
  String get logoutSuccessMessage;

  /// No description provided for @logoutErrorMessage.
  ///
  /// In es, this message translates to:
  /// **'Error al cerrar sesión. Inténtalo de nuevo.'**
  String get logoutErrorMessage;

  /// No description provided for @profileTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu Perfil'**
  String get profileTitle;

  /// No description provided for @profileTabProfile.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get profileTabProfile;

  /// No description provided for @profileTabFavorites.
  ///
  /// In es, this message translates to:
  /// **'Favoritos'**
  String get profileTabFavorites;

  /// No description provided for @profileTabFollowing.
  ///
  /// In es, this message translates to:
  /// **'Promotores'**
  String get profileTabFollowing;

  /// No description provided for @profileFirstName.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get profileFirstName;

  /// No description provided for @profileFirstNameHint.
  ///
  /// In es, this message translates to:
  /// **'Introduce tu nombre'**
  String get profileFirstNameHint;

  /// No description provided for @profileLastName.
  ///
  /// In es, this message translates to:
  /// **'Apellidos'**
  String get profileLastName;

  /// No description provided for @profileLastNameHint.
  ///
  /// In es, this message translates to:
  /// **'Introduce tus apellidos'**
  String get profileLastNameHint;

  /// No description provided for @profileDateOfBirth.
  ///
  /// In es, this message translates to:
  /// **'Fecha de nacimiento'**
  String get profileDateOfBirth;

  /// No description provided for @profileAddress.
  ///
  /// In es, this message translates to:
  /// **'Dirección'**
  String get profileAddress;

  /// No description provided for @profileAddressHint.
  ///
  /// In es, this message translates to:
  /// **'Calle, número, ciudad'**
  String get profileAddressHint;

  /// No description provided for @profileSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get profileSave;

  /// No description provided for @profileOmit.
  ///
  /// In es, this message translates to:
  /// **'Omitir'**
  String get profileOmit;

  /// No description provided for @profileSelectImageSource.
  ///
  /// In es, this message translates to:
  /// **'Selecciona origen de imagen'**
  String get profileSelectImageSource;

  /// No description provided for @profileCamera.
  ///
  /// In es, this message translates to:
  /// **'Cámara'**
  String get profileCamera;

  /// No description provided for @profileGallery.
  ///
  /// In es, this message translates to:
  /// **'Galería'**
  String get profileGallery;

  /// No description provided for @profileRemoveAvatar.
  ///
  /// In es, this message translates to:
  /// **'Eliminar foto de perfil'**
  String get profileRemoveAvatar;

  /// No description provided for @profileRemoveAvatarConfirmation.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres eliminar tu foto de perfil?'**
  String get profileRemoveAvatarConfirmation;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @remove.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get remove;

  /// No description provided for @profileUpdateSuccess.
  ///
  /// In es, this message translates to:
  /// **'Perfil actualizado correctamente'**
  String get profileUpdateSuccess;

  /// No description provided for @profileNoFavorites.
  ///
  /// In es, this message translates to:
  /// **'No tienes planes favoritos'**
  String get profileNoFavorites;

  /// No description provided for @profileNoFollowing.
  ///
  /// In es, this message translates to:
  /// **'No sigues a ningún promotor'**
  String get profileNoFollowing;

  /// No description provided for @retry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// No description provided for @eventDetailDescription.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get eventDetailDescription;

  /// No description provided for @eventDetailLocation.
  ///
  /// In es, this message translates to:
  /// **'Ubicación'**
  String get eventDetailLocation;

  /// No description provided for @eventDetailOpenMap.
  ///
  /// In es, this message translates to:
  /// **'Cómo llegar'**
  String get eventDetailOpenMap;

  /// No description provided for @eventDetailOrganizer.
  ///
  /// In es, this message translates to:
  /// **'Organizador'**
  String get eventDetailOrganizer;

  /// No description provided for @eventDetailViewProfile.
  ///
  /// In es, this message translates to:
  /// **'Ver perfil'**
  String get eventDetailViewProfile;

  /// No description provided for @eventDetailFollow.
  ///
  /// In es, this message translates to:
  /// **'Seguir'**
  String get eventDetailFollow;

  /// No description provided for @eventDetailSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get eventDetailSave;

  /// No description provided for @eventDetailBuyTicket.
  ///
  /// In es, this message translates to:
  /// **'Comprar Entrada'**
  String get eventDetailBuyTicket;

  /// No description provided for @eventDetailSignUp.
  ///
  /// In es, this message translates to:
  /// **'¡Me apunto!'**
  String get eventDetailSignUp;

  /// No description provided for @promoterProfileEvents.
  ///
  /// In es, this message translates to:
  /// **'Planes'**
  String get promoterProfileEvents;

  /// No description provided for @promoterProfileFollowers.
  ///
  /// In es, this message translates to:
  /// **'Seguidores'**
  String get promoterProfileFollowers;

  /// No description provided for @promoterProfileFollow.
  ///
  /// In es, this message translates to:
  /// **'Seguir'**
  String get promoterProfileFollow;

  /// No description provided for @promoterProfileUnfollow.
  ///
  /// In es, this message translates to:
  /// **'Dejar de seguir'**
  String get promoterProfileUnfollow;

  /// No description provided for @promoterProfileEventsList.
  ///
  /// In es, this message translates to:
  /// **'Planes del Organizador'**
  String get promoterProfileEventsList;

  /// No description provided for @promoterProfileNoEvents.
  ///
  /// In es, this message translates to:
  /// **'No hay planes publicados'**
  String get promoterProfileNoEvents;

  /// No description provided for @authDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Únete a WAP!'**
  String get authDialogTitle;

  /// No description provided for @authDialogDescription.
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión o regístrate para acceder a tu perfil, guardar planes favoritos y mucho más'**
  String get authDialogDescription;

  /// No description provided for @authDialogLogin.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get authDialogLogin;

  /// No description provided for @authDialogRegister.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get authDialogRegister;

  /// No description provided for @favoriteAddedMessage.
  ///
  /// In es, this message translates to:
  /// **'Agregado a favoritos'**
  String get favoriteAddedMessage;

  /// No description provided for @favoriteRemovedMessage.
  ///
  /// In es, this message translates to:
  /// **'Eliminado de favoritos'**
  String get favoriteRemovedMessage;

  /// No description provided for @followingAddedMessage.
  ///
  /// In es, this message translates to:
  /// **'Ahora sigues a este promotor'**
  String get followingAddedMessage;

  /// No description provided for @followingRemovedMessage.
  ///
  /// In es, this message translates to:
  /// **'Has dejado de seguir al promotor'**
  String get followingRemovedMessage;

  /// No description provided for @favoriteSaved.
  ///
  /// In es, this message translates to:
  /// **'Guardado'**
  String get favoriteSaved;

  /// No description provided for @favoriteAddToFavorites.
  ///
  /// In es, this message translates to:
  /// **'Agregar a favoritos'**
  String get favoriteAddToFavorites;

  /// No description provided for @favoriteRemoveFromFavorites.
  ///
  /// In es, this message translates to:
  /// **'Quitar de favoritos'**
  String get favoriteRemoveFromFavorites;

  /// No description provided for @locationBannerTitle.
  ///
  /// In es, this message translates to:
  /// **'Ubicación desactivada'**
  String get locationBannerTitle;

  /// No description provided for @locationBannerMessage.
  ///
  /// In es, this message translates to:
  /// **'Para ver planes cerca de ti, activa los servicios de ubicación'**
  String get locationBannerMessage;

  /// No description provided for @locationBannerAction.
  ///
  /// In es, this message translates to:
  /// **'Activar ubicación'**
  String get locationBannerAction;

  /// No description provided for @locationBannerDismiss.
  ///
  /// In es, this message translates to:
  /// **'Ver todos los planes'**
  String get locationBannerDismiss;

  /// No description provided for @noLocationEventsTitle.
  ///
  /// In es, this message translates to:
  /// **'Mostrando todos los planes'**
  String get noLocationEventsTitle;

  /// No description provided for @noLocationEventsMessage.
  ///
  /// In es, this message translates to:
  /// **'Activa la ubicación para ver planes cercanos primero'**
  String get noLocationEventsMessage;

  /// No description provided for @eventFinishedBanner.
  ///
  /// In es, this message translates to:
  /// **'Este plan ya ha finalizado'**
  String get eventFinishedBanner;

  /// No description provided for @promoterProfileUpcoming.
  ///
  /// In es, this message translates to:
  /// **'Próximos'**
  String get promoterProfileUpcoming;

  /// No description provided for @promoterProfilePast.
  ///
  /// In es, this message translates to:
  /// **'Pasados'**
  String get promoterProfilePast;

  /// No description provided for @favoritesUpcoming.
  ///
  /// In es, this message translates to:
  /// **'Próximos'**
  String get favoritesUpcoming;

  /// No description provided for @favoritesPast.
  ///
  /// In es, this message translates to:
  /// **'Pasados'**
  String get favoritesPast;

  /// No description provided for @favoritesNoUpcoming.
  ///
  /// In es, this message translates to:
  /// **'No tienes planes próximos en favoritos'**
  String get favoritesNoUpcoming;

  /// No description provided for @favoritesNoPast.
  ///
  /// In es, this message translates to:
  /// **'No tienes planes pasados en favoritos'**
  String get favoritesNoPast;

  /// No description provided for @settingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get settingsTitle;

  /// No description provided for @settingsSectionLanguage.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get settingsSectionLanguage;

  /// No description provided for @settingsLanguageDevice.
  ///
  /// In es, this message translates to:
  /// **'Idioma del dispositivo'**
  String get settingsLanguageDevice;

  /// No description provided for @settingsLanguageEs.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get settingsLanguageEs;

  /// No description provided for @settingsLanguageEn.
  ///
  /// In es, this message translates to:
  /// **'English'**
  String get settingsLanguageEn;

  /// No description provided for @settingsLanguagePt.
  ///
  /// In es, this message translates to:
  /// **'Português'**
  String get settingsLanguagePt;

  /// No description provided for @settingsLanguageSaved.
  ///
  /// In es, this message translates to:
  /// **'Idioma guardado'**
  String get settingsLanguageSaved;

  /// No description provided for @settingsSectionLegal.
  ///
  /// In es, this message translates to:
  /// **'Legal'**
  String get settingsSectionLegal;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In es, this message translates to:
  /// **'Política de Privacidad'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsTermsOfUse.
  ///
  /// In es, this message translates to:
  /// **'Términos de Uso'**
  String get settingsTermsOfUse;

  /// No description provided for @settingsSectionAppearance.
  ///
  /// In es, this message translates to:
  /// **'Apariencia'**
  String get settingsSectionAppearance;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In es, this message translates to:
  /// **'Seguir al dispositivo'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeSaved.
  ///
  /// In es, this message translates to:
  /// **'Tema guardado'**
  String get settingsThemeSaved;

  /// No description provided for @settingsSectionNotifications.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get settingsSectionNotifications;

  /// No description provided for @settingsNotifNewEvents.
  ///
  /// In es, this message translates to:
  /// **'Nuevos planes de promotores seguidos'**
  String get settingsNotifNewEvents;

  /// No description provided for @settingsNotifNewEventsDesc.
  ///
  /// In es, this message translates to:
  /// **'Recibe una notificación push cuando un promotor que sigues publica un nuevo plan'**
  String get settingsNotifNewEventsDesc;

  /// No description provided for @settingsNotifModerationEmail.
  ///
  /// In es, this message translates to:
  /// **'Emails de moderación'**
  String get settingsNotifModerationEmail;

  /// No description provided for @settingsNotifModerationEmailDesc.
  ///
  /// In es, this message translates to:
  /// **'Recibe un email cuando un admin aprueba o rechaza uno de tus eventos'**
  String get settingsNotifModerationEmailDesc;

  /// No description provided for @settingsNotifAllPaused.
  ///
  /// In es, this message translates to:
  /// **'Silenciar todas las notificaciones'**
  String get settingsNotifAllPaused;

  /// No description provided for @settingsNotifAllPausedDesc.
  ///
  /// In es, this message translates to:
  /// **'Desactiva todas las notificaciones temporalmente sin perder tu configuración'**
  String get settingsNotifAllPausedDesc;

  /// No description provided for @settingsNotifSaved.
  ///
  /// In es, this message translates to:
  /// **'Preferencias guardadas'**
  String get settingsNotifSaved;

  /// No description provided for @settingsNotifGuestBanner.
  ///
  /// In es, this message translates to:
  /// **'Regístrate en WAP para no perderte ni un solo plan'**
  String get settingsNotifGuestBanner;

  /// No description provided for @settingsNotifGuestBannerCta.
  ///
  /// In es, this message translates to:
  /// **'Regístrate gratis'**
  String get settingsNotifGuestBannerCta;

  /// No description provided for @settingsSectionPermissions.
  ///
  /// In es, this message translates to:
  /// **'Permisos'**
  String get settingsSectionPermissions;

  /// No description provided for @settingsPermLocation.
  ///
  /// In es, this message translates to:
  /// **'Ubicación'**
  String get settingsPermLocation;

  /// No description provided for @settingsPermLocationDesc.
  ///
  /// In es, this message translates to:
  /// **'Necesaria para centrar el mapa en tu posición actual'**
  String get settingsPermLocationDesc;

  /// No description provided for @settingsPermNotifications.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get settingsPermNotifications;

  /// No description provided for @settingsPermNotificationsDesc.
  ///
  /// In es, this message translates to:
  /// **'Para recibir alertas de nuevos planes de promotores que sigues'**
  String get settingsPermNotificationsDesc;

  /// No description provided for @settingsPermCamera.
  ///
  /// In es, this message translates to:
  /// **'Cámara y fotos'**
  String get settingsPermCamera;

  /// No description provided for @settingsPermCameraDesc.
  ///
  /// In es, this message translates to:
  /// **'Para subir o cambiar tu foto de perfil'**
  String get settingsPermCameraDesc;

  /// No description provided for @settingsPermStatusGranted.
  ///
  /// In es, this message translates to:
  /// **'Concedido'**
  String get settingsPermStatusGranted;

  /// No description provided for @settingsPermStatusDenied.
  ///
  /// In es, this message translates to:
  /// **'No concedido'**
  String get settingsPermStatusDenied;

  /// No description provided for @settingsPermStatusBlocked.
  ///
  /// In es, this message translates to:
  /// **'Bloqueado'**
  String get settingsPermStatusBlocked;

  /// No description provided for @settingsPermOpenSettings.
  ///
  /// In es, this message translates to:
  /// **'Abrir ajustes'**
  String get settingsPermOpenSettings;

  /// No description provided for @settingsPermRevokeHint.
  ///
  /// In es, this message translates to:
  /// **'Para revocar este permiso ve a los ajustes del sistema'**
  String get settingsPermRevokeHint;

  /// No description provided for @settingsPermActivateHint.
  ///
  /// In es, this message translates to:
  /// **'Para activar este permiso ve a los ajustes del dispositivo'**
  String get settingsPermActivateHint;

  /// No description provided for @filterTitle.
  ///
  /// In es, this message translates to:
  /// **'Filtros'**
  String get filterTitle;

  /// No description provided for @filterClear.
  ///
  /// In es, this message translates to:
  /// **'Limpiar'**
  String get filterClear;

  /// No description provided for @filterApply.
  ///
  /// In es, this message translates to:
  /// **'Aplicar'**
  String get filterApply;

  /// No description provided for @filterSectionDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get filterSectionDate;

  /// No description provided for @filterDateAny.
  ///
  /// In es, this message translates to:
  /// **'Cualquier fecha'**
  String get filterDateAny;

  /// No description provided for @filterDateToday.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get filterDateToday;

  /// No description provided for @filterDateTomorrow.
  ///
  /// In es, this message translates to:
  /// **'Mañana'**
  String get filterDateTomorrow;

  /// No description provided for @filterDateThisWeek.
  ///
  /// In es, this message translates to:
  /// **'Esta semana'**
  String get filterDateThisWeek;

  /// No description provided for @filterDateThisWeekend.
  ///
  /// In es, this message translates to:
  /// **'Este fin de semana'**
  String get filterDateThisWeekend;

  /// No description provided for @filterDateChoose.
  ///
  /// In es, this message translates to:
  /// **'Elegir fecha'**
  String get filterDateChoose;

  /// No description provided for @filterDateFrom.
  ///
  /// In es, this message translates to:
  /// **'Desde'**
  String get filterDateFrom;

  /// No description provided for @filterDateTo.
  ///
  /// In es, this message translates to:
  /// **'Hasta'**
  String get filterDateTo;

  /// No description provided for @filterSectionCategory.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get filterSectionCategory;

  /// No description provided for @filterCategoryAll.
  ///
  /// In es, this message translates to:
  /// **'Todas'**
  String get filterCategoryAll;

  /// No description provided for @filterSectionPrice.
  ///
  /// In es, this message translates to:
  /// **'Precio'**
  String get filterSectionPrice;

  /// No description provided for @filterOnlyFree.
  ///
  /// In es, this message translates to:
  /// **'Solo planes gratuitos'**
  String get filterOnlyFree;

  /// No description provided for @filterPriceMin.
  ///
  /// In es, this message translates to:
  /// **'Mínimo'**
  String get filterPriceMin;

  /// No description provided for @filterPriceMax.
  ///
  /// In es, this message translates to:
  /// **'Máximo'**
  String get filterPriceMax;

  /// No description provided for @categoriesTitle.
  ///
  /// In es, this message translates to:
  /// **'Categorías de Planes'**
  String get categoriesTitle;

  /// No description provided for @categoriesError.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar las categorías'**
  String get categoriesError;

  /// No description provided for @categoriesEmpty.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron categorías'**
  String get categoriesEmpty;

  /// No description provided for @categoryPlansError.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar planes'**
  String get categoryPlansError;

  /// No description provided for @categoryPlansEmpty.
  ///
  /// In es, this message translates to:
  /// **'Sin planes'**
  String get categoryPlansEmpty;

  /// No description provided for @categoryPlansEmptyBody.
  ///
  /// In es, this message translates to:
  /// **'No hay planes disponibles\nen esta categoría'**
  String get categoryPlansEmptyBody;

  /// No description provided for @plansListSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar planes...'**
  String get plansListSearchHint;

  /// No description provided for @plansListEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay planes visibles en el mapa'**
  String get plansListEmpty;

  /// No description provided for @plansListMoveMap.
  ///
  /// In es, this message translates to:
  /// **'Mueve el mapa o ajusta los filtros'**
  String get plansListMoveMap;

  /// No description provided for @toolbarDiscoverTitle.
  ///
  /// In es, this message translates to:
  /// **'Explorar WAP'**
  String get toolbarDiscoverTitle;

  /// No description provided for @toolbarDiscoverSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Descubre planes y promotores'**
  String get toolbarDiscoverSubtitle;

  /// No description provided for @toolbarDiscoverCategories.
  ///
  /// In es, this message translates to:
  /// **'Planes por Categorías'**
  String get toolbarDiscoverCategories;

  /// No description provided for @toolbarDiscoverCategoriesSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Explora planes organizados por tipo'**
  String get toolbarDiscoverCategoriesSubtitle;

  /// No description provided for @toolbarDiscoverPromoters.
  ///
  /// In es, this message translates to:
  /// **'Directorio de Promotores'**
  String get toolbarDiscoverPromoters;

  /// No description provided for @toolbarDiscoverPromotersSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Conoce a los organizadores de planes'**
  String get toolbarDiscoverPromotersSubtitle;

  /// No description provided for @promotersTitle.
  ///
  /// In es, this message translates to:
  /// **'Directorio de Promotores'**
  String get promotersTitle;

  /// No description provided for @promotersSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar promotores...'**
  String get promotersSearchHint;

  /// No description provided for @promotersEmpty.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron promotores'**
  String get promotersEmpty;

  /// No description provided for @promotersStatPlans.
  ///
  /// In es, this message translates to:
  /// **'Planes'**
  String get promotersStatPlans;

  /// No description provided for @serverConnectionError.
  ///
  /// In es, this message translates to:
  /// **'Error al conectar con el servidor'**
  String get serverConnectionError;

  /// No description provided for @favoritesError.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar favoritos'**
  String get favoritesError;

  /// No description provided for @favoritesDeleteLabel.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get favoritesDeleteLabel;

  /// No description provided for @favoritesDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar favorito'**
  String get favoritesDeleteTitle;

  /// No description provided for @favoritesDeleteConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Quieres eliminar este plan de tus favoritos?'**
  String get favoritesDeleteConfirm;

  /// No description provided for @followingUnfollowSwipeLabel.
  ///
  /// In es, this message translates to:
  /// **'Dejar de seguir'**
  String get followingUnfollowSwipeLabel;

  /// No description provided for @followingDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Dejar de seguir'**
  String get followingDialogTitle;

  /// No description provided for @followingDialogBody.
  ///
  /// In es, this message translates to:
  /// **'¿Quieres dejar de seguir a {name}?'**
  String followingDialogBody(String name);

  /// No description provided for @eventDetailNoDescription.
  ///
  /// In es, this message translates to:
  /// **'No hay descripción disponible.'**
  String get eventDetailNoDescription;

  /// No description provided for @eventDetailNoAddress.
  ///
  /// In es, this message translates to:
  /// **'Dirección no disponible'**
  String get eventDetailNoAddress;

  /// No description provided for @eventDetailDefaultOrganizer.
  ///
  /// In es, this message translates to:
  /// **'Organizador del Plan'**
  String get eventDetailDefaultOrganizer;

  /// No description provided for @forgotPasswordPageTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu contraseña?'**
  String get forgotPasswordPageTitle;

  /// No description provided for @forgotPasswordPageSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Introduce tu email y te enviaremos un enlace de recuperación'**
  String get forgotPasswordPageSubtitle;

  /// No description provided for @forgotPasswordPageSendButton.
  ///
  /// In es, this message translates to:
  /// **'Enviar enlace'**
  String get forgotPasswordPageSendButton;

  /// No description provided for @forgotPasswordPageSuccessTitle.
  ///
  /// In es, this message translates to:
  /// **'Revisa tu correo'**
  String get forgotPasswordPageSuccessTitle;

  /// No description provided for @forgotPasswordPageSuccessMessage.
  ///
  /// In es, this message translates to:
  /// **'Si el email está registrado, recibirás un enlace en breve'**
  String get forgotPasswordPageSuccessMessage;

  /// No description provided for @forgotPasswordPageBackToLogin.
  ///
  /// In es, this message translates to:
  /// **'Volver al inicio de sesión'**
  String get forgotPasswordPageBackToLogin;

  /// No description provided for @changePasswordPageTitle.
  ///
  /// In es, this message translates to:
  /// **'Cambiar contraseña'**
  String get changePasswordPageTitle;

  /// No description provided for @changePasswordPageCurrentPassword.
  ///
  /// In es, this message translates to:
  /// **'Contraseña actual'**
  String get changePasswordPageCurrentPassword;

  /// No description provided for @changePasswordPageNewPassword.
  ///
  /// In es, this message translates to:
  /// **'Nueva contraseña'**
  String get changePasswordPageNewPassword;

  /// No description provided for @changePasswordPageConfirmPassword.
  ///
  /// In es, this message translates to:
  /// **'Confirmar nueva contraseña'**
  String get changePasswordPageConfirmPassword;

  /// No description provided for @changePasswordPageSaveButton.
  ///
  /// In es, this message translates to:
  /// **'Cambiar contraseña'**
  String get changePasswordPageSaveButton;

  /// No description provided for @changePasswordPageSuccess.
  ///
  /// In es, this message translates to:
  /// **'Contraseña cambiada correctamente'**
  String get changePasswordPageSuccess;

  /// No description provided for @changePasswordProfileTile.
  ///
  /// In es, this message translates to:
  /// **'Cambiar contraseña'**
  String get changePasswordProfileTile;

  /// No description provided for @deleteAccountProfileTile.
  ///
  /// In es, this message translates to:
  /// **'Eliminar cuenta'**
  String get deleteAccountProfileTile;

  /// No description provided for @deleteAccountConfirmTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar tu cuenta?'**
  String get deleteAccountConfirmTitle;

  /// No description provided for @deleteAccountConfirmMessage.
  ///
  /// In es, this message translates to:
  /// **'Recibirás un email para confirmar la eliminación. Esta acción es irreversible.'**
  String get deleteAccountConfirmMessage;

  /// No description provided for @deleteAccountConfirmButton.
  ///
  /// In es, this message translates to:
  /// **'Eliminar mi cuenta'**
  String get deleteAccountConfirmButton;

  /// No description provided for @deleteAccountSuccess.
  ///
  /// In es, this message translates to:
  /// **'Revisa tu correo para confirmar la eliminación'**
  String get deleteAccountSuccess;

  /// No description provided for @notificationsTitle.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get notificationsTitle;

  /// No description provided for @notificationsEmpty.
  ///
  /// In es, this message translates to:
  /// **'No tienes notificaciones'**
  String get notificationsEmpty;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In es, this message translates to:
  /// **'Marcar todas como leídas'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsDeleteAll.
  ///
  /// In es, this message translates to:
  /// **'Eliminar todas'**
  String get notificationsDeleteAll;

  /// No description provided for @notificationsDeleteConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Seguro que quieres eliminar todas las notificaciones?'**
  String get notificationsDeleteConfirm;

  /// No description provided for @profilePromotersSectionFollowing.
  ///
  /// In es, this message translates to:
  /// **'Promotores que sigues'**
  String get profilePromotersSectionFollowing;

  /// No description provided for @profilePromotersSectionBlocked.
  ///
  /// In es, this message translates to:
  /// **'Promotores bloqueados'**
  String get profilePromotersSectionBlocked;

  /// No description provided for @profileNoBlocked.
  ///
  /// In es, this message translates to:
  /// **'Aún no has bloqueado a ningún promotor'**
  String get profileNoBlocked;

  /// No description provided for @profileUnblockDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Desbloquear promotor'**
  String get profileUnblockDialogTitle;

  /// No description provided for @profileUnblockDialogBody.
  ///
  /// In es, this message translates to:
  /// **'¿Quieres desbloquear a {name}?'**
  String profileUnblockDialogBody(String name);

  /// No description provided for @profileUnblockLabel.
  ///
  /// In es, this message translates to:
  /// **'Desbloquear'**
  String get profileUnblockLabel;

  /// No description provided for @forceUpdateTitle.
  ///
  /// In es, this message translates to:
  /// **'Actualización requerida'**
  String get forceUpdateTitle;

  /// No description provided for @forceUpdateMessage.
  ///
  /// In es, this message translates to:
  /// **'Hay una nueva versión disponible con mejoras y correcciones importantes. Actualiza la app para continuar.'**
  String get forceUpdateMessage;

  /// No description provided for @forceUpdateButton.
  ///
  /// In es, this message translates to:
  /// **'Actualizar ahora'**
  String get forceUpdateButton;

  /// No description provided for @settingsSectionInfo.
  ///
  /// In es, this message translates to:
  /// **'Información'**
  String get settingsSectionInfo;

  /// No description provided for @settingsInfoVersion.
  ///
  /// In es, this message translates to:
  /// **'Versión'**
  String get settingsInfoVersion;

  /// No description provided for @settingsInfoRateApp.
  ///
  /// In es, this message translates to:
  /// **'Valorar la app'**
  String get settingsInfoRateApp;

  /// No description provided for @noConnectionBanner.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión a internet'**
  String get noConnectionBanner;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
