// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get loginPageTitle => 'Iniciar Sesión';

  @override
  String get loginPageSubtitle => 'Descubre planes cerca de ti';

  @override
  String get loginPageEmailHint => 'Correo Electrónico';

  @override
  String get loginPagePasswordHint => 'Contraseña';

  @override
  String get loginPageForgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get loginPageLoginButton => 'Iniciar Sesión';

  @override
  String get loginPageNoAccount => '¿No tienes cuenta?';

  @override
  String get loginPageRegister => 'Regístrate';

  @override
  String get loginPageTermsAndPolicy =>
      'Al continuar aceptas los Términos y la Política de Privacidad';

  @override
  String get loginSuccessMessage => '¡Login exitoso!';

  @override
  String get loginErrorMessage =>
      'Credenciales incorrectas o error del servidor. Inténtalo de nuevo.';

  @override
  String get registerEmailVerifTitle => 'Confirma tu email';

  @override
  String registerEmailVerifMessage(String email) {
    return 'Hemos enviado un correo de confirmación a $email. Por favor, revisa tu bandeja de entrada y pulsa el enlace para activar tu cuenta.';
  }

  @override
  String get ok => 'Aceptar';

  @override
  String get registerPageTitle => 'Crear Cuenta';

  @override
  String get registerPageSubtitle => 'Empieza a descubrir planes increíbles';

  @override
  String get registerPageRegisterButton => 'Crear Cuenta';

  @override
  String get registerPageLoginPrompt => '¿Ya tienes una cuenta?';

  @override
  String get registerPageTermsAndPolicy =>
      'Al registrarte aceptas los Términos y la Política de Privacidad';

  @override
  String get registerPageLoginLink => 'Inicia Sesión';

  @override
  String get authPageWelcome => '¡Bienvenido!';

  @override
  String get authPageSubtitle => 'Descubre planes cerca de ti';

  @override
  String get authPageEmailOrRegister => 'Inicia sesión o regístrate';

  @override
  String get authPageLogin => 'Inicia sesión';

  @override
  String get authPageCreateAccount => 'Crea tu cuenta';

  @override
  String get authPageContinueWithEmail => 'Continuar con correo electrónico';

  @override
  String get authPageContinueWithGoogle => 'Continuar con Google';

  @override
  String get authPageContinueWithApple => 'Continuar con Apple';

  @override
  String get authPageContinue => 'Continuar';

  @override
  String get authPageGoBack => 'Volver';

  @override
  String get authPageChangeEmail => 'Cambiar email';

  @override
  String get authPageAcceptTerms => 'Acepto los términos y condiciones';

  @override
  String get authPageMustAcceptTerms =>
      'Debes aceptar los términos y condiciones';

  @override
  String get authPageConfirmPassword => 'Confirmar contraseña';

  @override
  String get authPageConfirmPasswordRequired =>
      'Por favor confirma tu contraseña';

  @override
  String get authPagePasswordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get validatorRequired => 'Este campo es requerido';

  @override
  String get validatorInvalidEmail => 'Formato de email inválido';

  @override
  String get validatorPasswordLength =>
      'La contraseña debe tener al menos 8 caracteres';

  @override
  String get googleSignInButton => 'Continuar con Google';

  @override
  String get homePageTitle => 'Inicio';

  @override
  String get navBarProfile => 'Perfil';

  @override
  String get navBarSearch => 'Buscar';

  @override
  String get navBarList => 'Listado';

  @override
  String get navBarLocation => 'Ubicación';

  @override
  String get navBarLogin => 'Iniciar sesión';

  @override
  String get navBarLogout => 'Salir';

  @override
  String get eventCardDetails => 'Detalles';

  @override
  String get eventCardGo => 'Ir';

  @override
  String get eventCardFree => 'Gratis';

  @override
  String eventCardFromPrice(String price) {
    return 'Desde $price';
  }

  @override
  String eventCardTodayAt(String time) {
    return 'Hoy, $time';
  }

  @override
  String eventCardTomorrowAt(String time) {
    return 'Mañana, $time';
  }

  @override
  String eventCardOngoing(String date) {
    return 'En curso · hasta $date';
  }

  @override
  String eventCardDistance(String distance) {
    return '$distance km';
  }

  @override
  String get errorLocationDisabled =>
      'Los servicios de ubicación están desactivados.';

  @override
  String get errorLocationDenied =>
      'Los permisos de ubicación fueron denegados.';

  @override
  String get errorLocationDeniedForever =>
      'Los permisos de ubicación están permanentemente denegados. Actívalos en los ajustes de la app.';

  @override
  String get errorLoadingEvents => 'No se pudieron cargar los planes cercanos.';

  @override
  String get logoutDialogTitle => 'Cerrar Sesión';

  @override
  String get logoutDialogMessage =>
      '¿Estás seguro de que quieres cerrar sesión?';

  @override
  String get logoutDialogCancel => 'Cancelar';

  @override
  String get logoutDialogConfirm => 'Salir';

  @override
  String get logoutSuccessMessage => '¡Sesión cerrada correctamente!';

  @override
  String get logoutErrorMessage =>
      'Error al cerrar sesión. Inténtalo de nuevo.';

  @override
  String get profileTitle => 'Tu Perfil';

  @override
  String get profileTabProfile => 'Perfil';

  @override
  String get profileTabFavorites => 'Favoritos';

  @override
  String get profileTabFollowing => 'Promotores';

  @override
  String get profileFirstName => 'Nombre';

  @override
  String get profileFirstNameHint => 'Introduce tu nombre';

  @override
  String get profileLastName => 'Apellidos';

  @override
  String get profileLastNameHint => 'Introduce tus apellidos';

  @override
  String get profileDateOfBirth => 'Fecha de nacimiento';

  @override
  String get profileAddress => 'Dirección';

  @override
  String get profileAddressHint => 'Calle, número, ciudad';

  @override
  String get profileSave => 'Guardar';

  @override
  String get profileOmit => 'Omitir';

  @override
  String get profileSelectImageSource => 'Selecciona origen de imagen';

  @override
  String get profileCamera => 'Cámara';

  @override
  String get profileGallery => 'Galería';

  @override
  String get profileRemoveAvatar => 'Eliminar foto de perfil';

  @override
  String get profileRemoveAvatarConfirmation =>
      '¿Estás seguro de que quieres eliminar tu foto de perfil?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get remove => 'Eliminar';

  @override
  String get profileUpdateSuccess => 'Perfil actualizado correctamente';

  @override
  String get profileNoFavorites => 'No tienes planes favoritos';

  @override
  String get profileNoFollowing => 'No sigues a ningún promotor';

  @override
  String get retry => 'Reintentar';

  @override
  String eventDetailEndDate(String date) {
    return 'Hasta el $date';
  }

  @override
  String get eventDetailDescription => 'Descripción';

  @override
  String get eventDetailSource => 'Fuente';

  @override
  String get eventDetailLocation => 'Ubicación';

  @override
  String get eventDetailOpenMap => 'Cómo llegar';

  @override
  String get eventDetailOrganizer => 'Organizador';

  @override
  String get eventDetailViewProfile => 'Ver perfil';

  @override
  String get eventDetailFollow => 'Seguir';

  @override
  String get eventDetailSave => 'Guardar';

  @override
  String get eventDetailBuyTicket => 'Comprar Entrada';

  @override
  String get eventDetailSignUp => '¡Me apunto!';

  @override
  String get promoterProfileEvents => 'Planes';

  @override
  String get promoterProfileFollowers => 'Seguidores';

  @override
  String get promoterProfileFollow => 'Seguir';

  @override
  String get promoterProfileUnfollow => 'Dejar de seguir';

  @override
  String get promoterProfileEventsList => 'Planes del Organizador';

  @override
  String get promoterProfileNoEvents => 'No hay planes publicados';

  @override
  String get authDialogTitle => '¡Únete a WAP!';

  @override
  String get authDialogDescription =>
      'Inicia sesión o regístrate para acceder a tu perfil, guardar planes favoritos y mucho más';

  @override
  String get authDialogLogin => 'Iniciar sesión';

  @override
  String get authDialogRegister => 'Crear cuenta';

  @override
  String get favoriteAddedMessage => 'Agregado a favoritos';

  @override
  String get favoriteRemovedMessage => 'Eliminado de favoritos';

  @override
  String get followingAddedMessage => 'Ahora sigues a este promotor';

  @override
  String get followingRemovedMessage => 'Has dejado de seguir al promotor';

  @override
  String get favoriteSaved => 'Guardado';

  @override
  String get favoriteAddToFavorites => 'Agregar a favoritos';

  @override
  String get favoriteRemoveFromFavorites => 'Quitar de favoritos';

  @override
  String get locationBannerTitle => 'Ubicación desactivada';

  @override
  String get locationBannerMessage =>
      'Para ver planes cerca de ti, activa los servicios de ubicación';

  @override
  String get locationBannerAction => 'Activar ubicación';

  @override
  String get locationBannerDismiss => 'Ver todos los planes';

  @override
  String get noLocationEventsTitle => 'Mostrando todos los planes';

  @override
  String get noLocationEventsMessage =>
      'Activa la ubicación para ver planes cercanos primero';

  @override
  String get eventFinishedBanner => 'Este plan ya ha finalizado';

  @override
  String get promoterProfileUpcoming => 'Próximos';

  @override
  String get promoterProfilePast => 'Pasados';

  @override
  String get favoritesUpcoming => 'Próximos';

  @override
  String get favoritesPast => 'Pasados';

  @override
  String get favoritesNoUpcoming => 'No tienes planes próximos en favoritos';

  @override
  String get favoritesNoPast => 'No tienes planes pasados en favoritos';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsSectionLanguage => 'Idioma';

  @override
  String get settingsLanguageDevice => 'Idioma del dispositivo';

  @override
  String get settingsLanguageEs => 'Español';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsLanguagePt => 'Português';

  @override
  String get settingsLanguageSaved => 'Idioma guardado';

  @override
  String get settingsSectionLegal => 'Legal';

  @override
  String get settingsPrivacyPolicy => 'Política de Privacidad';

  @override
  String get settingsTermsOfUse => 'Términos de Uso';

  @override
  String get settingsSectionAppearance => 'Apariencia';

  @override
  String get settingsThemeSystem => 'Seguir al dispositivo';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Oscuro';

  @override
  String get settingsThemeSaved => 'Tema guardado';

  @override
  String get settingsSectionNotifications => 'Notificaciones';

  @override
  String get settingsNotifNewEvents => 'Nuevos planes de promotores seguidos';

  @override
  String get settingsNotifNewEventsDesc =>
      'Recibe una notificación push cuando un promotor que sigues publica un nuevo plan';

  @override
  String get settingsNotifModerationEmail => 'Emails de moderación';

  @override
  String get settingsNotifModerationEmailDesc =>
      'Recibe un email cuando un admin aprueba o rechaza uno de tus planes';

  @override
  String get settingsNotifAllPaused => 'Silenciar todas las notificaciones';

  @override
  String get settingsNotifAllPausedDesc =>
      'Desactiva todas las notificaciones temporalmente sin perder tu configuración';

  @override
  String get settingsNotifSaved => 'Preferencias guardadas';

  @override
  String get settingsNotifGuestBanner =>
      'Regístrate en WAP para no perderte ni un solo plan';

  @override
  String get settingsNotifGuestBannerCta => 'Regístrate gratis';

  @override
  String get settingsSectionPermissions => 'Permisos';

  @override
  String get settingsPermLocation => 'Ubicación';

  @override
  String get settingsPermLocationDesc =>
      'Necesaria para centrar el mapa en tu posición actual';

  @override
  String get settingsPermNotifications => 'Notificaciones';

  @override
  String get settingsPermNotificationsDesc =>
      'Para recibir alertas de nuevos planes de promotores que sigues';

  @override
  String get settingsPermCamera => 'Cámara y fotos';

  @override
  String get settingsPermCameraDesc => 'Para subir o cambiar tu foto de perfil';

  @override
  String get settingsPermStatusGranted => 'Concedido';

  @override
  String get settingsPermStatusDenied => 'No concedido';

  @override
  String get settingsPermStatusBlocked => 'Bloqueado';

  @override
  String get settingsPermOpenSettings => 'Abrir ajustes';

  @override
  String get settingsPermRevokeHint =>
      'Para revocar este permiso ve a los ajustes del sistema';

  @override
  String get settingsPermActivateHint =>
      'Para activar este permiso ve a los ajustes del dispositivo';

  @override
  String get filterTitle => 'Filtros';

  @override
  String get filterClear => 'Limpiar';

  @override
  String get filterApply => 'Aplicar';

  @override
  String get filterSectionDate => 'Fecha';

  @override
  String get filterDateAny => 'Cualquier fecha';

  @override
  String get filterDateToday => 'Hoy';

  @override
  String get filterDateTomorrow => 'Mañana';

  @override
  String get filterDateThisWeek => 'Esta semana';

  @override
  String get filterDateThisWeekend => 'Este fin de semana';

  @override
  String get filterDateChoose => 'Elegir fecha';

  @override
  String get filterDateFrom => 'Desde';

  @override
  String get filterDateTo => 'Hasta';

  @override
  String get filterSectionCategory => 'Categoría';

  @override
  String get filterCategoryAll => 'Todas';

  @override
  String get filterSectionPrice => 'Precio';

  @override
  String get filterOnlyFree => 'Solo planes gratuitos';

  @override
  String get filterPriceMin => 'Mínimo';

  @override
  String get filterPriceMax => 'Máximo';

  @override
  String get categoriesTitle => 'Categorías de Planes';

  @override
  String get categoriesError => 'Error al cargar las categorías';

  @override
  String get categoriesEmpty => 'No se encontraron categorías';

  @override
  String get categoryPlansError => 'Error al cargar planes';

  @override
  String get categoryPlansEmpty => 'Sin planes';

  @override
  String get categoryPlansEmptyBody =>
      'No hay planes disponibles\nen esta categoría';

  @override
  String get plansListSearchHint => 'Buscar planes...';

  @override
  String get plansListEmpty => 'No hay planes visibles en el mapa';

  @override
  String get plansListMoveMap => 'Mueve el mapa o ajusta los filtros';

  @override
  String get toolbarDiscoverTitle => 'Explorar WAP';

  @override
  String get toolbarDiscoverSubtitle => 'Descubre planes y promotores';

  @override
  String get toolbarDiscoverCategories => 'Planes por Categorías';

  @override
  String get toolbarDiscoverCategoriesSubtitle =>
      'Explora planes organizados por tipo';

  @override
  String get toolbarDiscoverPromoters => 'Directorio de Promotores';

  @override
  String get toolbarDiscoverPromotersSubtitle =>
      'Conoce a los organizadores de planes';

  @override
  String get toolbarDiscoverPromoterAccess => 'Acceso para Promotores';

  @override
  String get toolbarDiscoverPromoterAccessSubtitle =>
      'Crea y gestiona tus planes en WAP';

  @override
  String get promotersTitle => 'Directorio de Promotores';

  @override
  String get promotersSearchHint => 'Buscar promotores...';

  @override
  String get promotersEmpty => 'No se encontraron promotores';

  @override
  String get promotersStatPlans => 'Planes';

  @override
  String get serverConnectionError => 'Error al conectar con el servidor';

  @override
  String get favoritesError => 'Error al cargar favoritos';

  @override
  String get favoritesDeleteLabel => 'Eliminar';

  @override
  String get favoritesDeleteTitle => 'Eliminar favorito';

  @override
  String get favoritesDeleteConfirm =>
      '¿Quieres eliminar este plan de tus favoritos?';

  @override
  String get followingUnfollowSwipeLabel => 'Dejar de seguir';

  @override
  String get followingDialogTitle => 'Dejar de seguir';

  @override
  String followingDialogBody(String name) {
    return '¿Quieres dejar de seguir a $name?';
  }

  @override
  String get eventDetailNoDescription => 'No hay descripción disponible.';

  @override
  String get eventDetailNoAddress => 'Dirección no disponible';

  @override
  String get eventDetailDefaultOrganizer => 'Organizador del Plan';

  @override
  String get forgotPasswordPageTitle => '¿Olvidaste tu contraseña?';

  @override
  String get forgotPasswordPageSubtitle =>
      'Introduce tu email y te enviaremos un enlace de recuperación';

  @override
  String get forgotPasswordPageSendButton => 'Enviar enlace';

  @override
  String get forgotPasswordPageSuccessTitle => 'Revisa tu correo';

  @override
  String get forgotPasswordPageSuccessMessage =>
      'Si el email está registrado, recibirás un enlace en breve';

  @override
  String get forgotPasswordPageBackToLogin => 'Volver al inicio de sesión';

  @override
  String get changePasswordPageTitle => 'Cambiar contraseña';

  @override
  String get changePasswordPageCurrentPassword => 'Contraseña actual';

  @override
  String get changePasswordPageNewPassword => 'Nueva contraseña';

  @override
  String get changePasswordPageConfirmPassword => 'Confirmar nueva contraseña';

  @override
  String get changePasswordPageSaveButton => 'Cambiar contraseña';

  @override
  String get changePasswordPageSuccess => 'Contraseña cambiada correctamente';

  @override
  String get changePasswordProfileTile => 'Cambiar contraseña';

  @override
  String get deleteAccountProfileTile => 'Eliminar cuenta';

  @override
  String get deleteAccountConfirmTitle => '¿Eliminar tu cuenta?';

  @override
  String get deleteAccountConfirmMessage =>
      'Recibirás un email para confirmar la eliminación. Esta acción es irreversible.';

  @override
  String get deleteAccountConfirmButton => 'Eliminar mi cuenta';

  @override
  String get deleteAccountSuccess =>
      'Revisa tu correo para confirmar la eliminación';

  @override
  String get notificationsTitle => 'Notificaciones';

  @override
  String get notificationsEmpty => 'No tienes notificaciones';

  @override
  String get notificationsMarkAllRead => 'Marcar todas como leídas';

  @override
  String get notificationsDeleteAll => 'Eliminar todas';

  @override
  String get notificationsDeleteConfirm =>
      '¿Seguro que quieres eliminar todas las notificaciones?';

  @override
  String get profilePromotersSectionFollowing => 'Promotores que sigues';

  @override
  String get profilePromotersSectionBlocked => 'Promotores bloqueados';

  @override
  String get profileNoBlocked => 'Aún no has bloqueado a ningún promotor';

  @override
  String get profileUnblockDialogTitle => 'Desbloquear promotor';

  @override
  String profileUnblockDialogBody(String name) {
    return '¿Quieres desbloquear a $name?';
  }

  @override
  String get profileUnblockLabel => 'Desbloquear';

  @override
  String get forceUpdateTitle => 'Actualización requerida';

  @override
  String get forceUpdateMessage =>
      'Hay una nueva versión disponible con mejoras y correcciones importantes. Actualiza la app para continuar.';

  @override
  String get forceUpdateButton => 'Actualizar ahora';

  @override
  String get settingsSectionTutorials => 'Tutoriales';

  @override
  String get settingsTutorialReplay => 'Volver a ver el tutorial';

  @override
  String get settingsTutorialReplayDesc =>
      'Se mostrará la próxima vez que abras la app';

  @override
  String get settingsTutorialReplayConfirm =>
      'Reinicia la app para ver el tutorial';

  @override
  String get onboardingSlide1Title => '¡Bienvenido a WAP!';

  @override
  String get onboardingSlide1Subtitle =>
      'La app que conecta personas con planes increíbles cerca de ellas. Descúbrela en 30 segundos.';

  @override
  String get onboardingSlide2Title => 'Miles de planes cerca de ti';

  @override
  String get onboardingSlide2Subtitle =>
      'Explora el mapa, filtra por categoría y encuentra tu próximo plan perfecto en tiempo real.';

  @override
  String get onboardingSlide3Title => 'Guarda lo que te gusta';

  @override
  String get onboardingSlide3Subtitle =>
      'Marca tus planes favoritos, sigue a tus promotores preferidos y recibe notificaciones cuando publiquen algo nuevo.';

  @override
  String get onboardingSlide4Title => '¿Tienes planes que compartir?';

  @override
  String get onboardingSlide4Subtitle =>
      'Crea tu perfil de promotor, publica tus planes y llega a miles de personas cerca de ti.';

  @override
  String get onboardingNext => 'Siguiente';

  @override
  String get onboardingSkip => 'Saltar';

  @override
  String get onboardingStart => 'Empezar';

  @override
  String get settingsSectionInfo => 'Información';

  @override
  String get settingsInfoVersion => 'Versión';

  @override
  String get settingsInfoRateApp => 'Valorar la app';

  @override
  String get noConnectionBanner => 'Sin conexión a internet';

  @override
  String get next => 'Siguiente';

  @override
  String get back => 'Atrás';

  @override
  String get delete => 'Eliminar';

  @override
  String get fieldRequired => 'Este campo es obligatorio';

  @override
  String get genericError => 'Algo salió mal. Por favor, inténtalo de nuevo.';

  @override
  String get forPromotersHeroTitle => 'Llega a más personas con tus planes';

  @override
  String get forPromotersHeroSubtitle =>
      'Publica tus planes, gestiona las ventas y haz crecer tu audiencia.';

  @override
  String get forPromotersBenefitsTitle => 'Lo que obtienes como promotor';

  @override
  String get forPromotersBenefit1Title => 'Crea y publica planes';

  @override
  String get forPromotersBenefit1Desc =>
      'Configura tu plan en minutos con nuestro asistente paso a paso.';

  @override
  String get forPromotersBenefit2Title => 'Sigue tu rendimiento';

  @override
  String get forPromotersBenefit2Desc =>
      'Monitorea visitas, favoritos y engagement en tiempo real.';

  @override
  String get forPromotersBenefit3Title => 'Llega a audiencias locales';

  @override
  String get forPromotersBenefit3Desc =>
      'Tus planes aparecen en el mapa para usuarios cercanos.';

  @override
  String get forPromotersBenefit4Title => 'Gestión sencilla';

  @override
  String get forPromotersBenefit4Desc =>
      'Edita, publica, pausa o elimina tus planes en cualquier momento.';

  @override
  String get forPromotersCtaRegister => 'Regístrate gratis';

  @override
  String get forPromotersCtaLogin => '¿Ya tienes cuenta? Inicia sesión';

  @override
  String get upgradeToPromoterTitle => 'Hazte promotor';

  @override
  String get upgradeToPromoterHeroTitle =>
      'Lleva tus planes al siguiente nivel';

  @override
  String get upgradeToPromoterHeroSubtitle =>
      'Mejora tu cuenta para empezar a publicar planes y llegar a miles de personas.';

  @override
  String get upgradeToPromoterBenefitsTitle => 'Ventajas de ser promotor';

  @override
  String get upgradeToPromoterBenefit1 => 'Crea y publica planes en el mapa';

  @override
  String get upgradeToPromoterBenefit2 =>
      'Panel de análisis con visitas y favoritos';

  @override
  String get upgradeToPromoterBenefit3 =>
      'Gestiona tus locales y detalles de plan';

  @override
  String get upgradeToPromoterBenefit4 =>
      'Haz crecer tu audiencia de seguidores';

  @override
  String get upgradeToPromoterCta => 'Mejorar mi cuenta';

  @override
  String get upgradeToPromoterSuccess => '¡Tu cuenta ha sido mejorada!';

  @override
  String get dashboardTitle => 'Mis Planes';

  @override
  String get dashboardTabActive => 'Activos';

  @override
  String get dashboardTabFinished => 'Finalizados';

  @override
  String get dashboardCreateEvent => 'Crear plan';

  @override
  String get dashboardStatsTotalEvents => 'Total planes';

  @override
  String get dashboardStatsActiveEvents => 'Activos';

  @override
  String get dashboardStatsTotalViews => 'Visitas';

  @override
  String get dashboardStatsTotalFavorites => 'Favoritos';

  @override
  String get dashboardStatsFollowers => 'Seguidores';

  @override
  String get dashboardSearchHint => 'Buscar mis planes…';

  @override
  String get dashboardNoEvents => 'Aún no tienes planes. ¡Crea el primero!';

  @override
  String get dashboardDeleteEvent => 'Eliminar plan';

  @override
  String get dashboardDeleteEventTitle => '¿Eliminar este plan?';

  @override
  String get dashboardDeleteEventConfirm => 'Esta acción no se puede deshacer.';

  @override
  String get manageEventCreateTitle => 'Crear plan';

  @override
  String get manageEventEditTitle => 'Editar plan';

  @override
  String get manageEventStep1 => 'Detalles';

  @override
  String get manageEventStep2 => 'Local';

  @override
  String get manageEventStep3 => 'Imágenes';

  @override
  String get manageEventStep4 => 'Publicar';

  @override
  String get manageEventTitle => 'Título';

  @override
  String get manageEventTitleHint => 'Dale un nombre genial a tu plan';

  @override
  String get manageEventDescription => 'Descripción';

  @override
  String get manageEventDescriptionHint =>
      'Cuéntale a la gente qué pueden esperar';

  @override
  String get manageEventPrice => 'Precio (€)';

  @override
  String get manageEventPriceHint => '0 para planes gratuitos';

  @override
  String get manageEventDates => 'Fechas';

  @override
  String get manageEventStartDate => 'Inicio';

  @override
  String get manageEventEndDate => 'Fin';

  @override
  String get manageEventCategories => 'Categorías';

  @override
  String get manageEventPickDates => 'Seleccionar fechas';

  @override
  String get manageEventEndBeforeStart =>
      'La fecha de fin debe ser posterior a la de inicio';

  @override
  String get manageEventPickCategory => 'Selecciona al menos una categoría';

  @override
  String get manageEventInvalidPrice => 'Introduce un precio válido';

  @override
  String get manageEventMyVenues => 'Mis locales';

  @override
  String get manageEventSearchVenue => 'Buscar';

  @override
  String get manageEventNoSavedVenues => 'No tienes locales guardados';

  @override
  String get manageEventSearchPlaceholder => 'Buscar local o dirección…';

  @override
  String get manageEventNoResults => 'Sin resultados';

  @override
  String get manageEventVenue => 'Local';

  @override
  String get manageEventImagesTitle => 'Imágenes del plan';

  @override
  String get manageEventImagesSubtitle =>
      'Añade hasta 3 imágenes. La primera será la foto de portada.';

  @override
  String get manageEventImageSourceCamera => 'Cámara';

  @override
  String get manageEventImageSourceGallery => 'Galería';

  @override
  String get manageEventCameraPermissionDenied =>
      'Se necesita permiso de cámara para tomar fotos';

  @override
  String get settings => 'Ajustes';

  @override
  String get manageEventAddImage => 'Añadir imagen';

  @override
  String get manageEventFree => 'Gratis';

  @override
  String get manageEventPreviewBadge => 'Vista previa';

  @override
  String get manageEventPrimaryImage => 'Portada';

  @override
  String get manageEventImage => 'Imagen';

  @override
  String get manageEventImagesCount => 'Imágenes';

  @override
  String get manageEventReviewTitle => 'Revisar y publicar';

  @override
  String get manageEventSaveDraft => 'Guardar borrador';

  @override
  String get manageEventPublish => 'Enviar a revisión';

  @override
  String get manageEventCreateSuccess => '¡Plan creado con éxito!';

  @override
  String get manageEventUpdateSuccess => '¡Plan actualizado con éxito!';

  @override
  String get eventStatusPublished => 'Publicado';

  @override
  String get eventStatusFinished => 'Finalizado';

  @override
  String get eventStatusCancelled => 'Cancelado';

  @override
  String get eventStatusPendingApproval => 'En revisión';

  @override
  String get eventStatusRejected => 'Rechazado';

  @override
  String get eventStatusDraft => 'Borrador';

  @override
  String get eventStatusUnpublish => 'Despublicar';

  @override
  String get eventStatusDescription => 'Descripción';

  @override
  String get categoryAddMore => 'Agregar más categorías';

  @override
  String get closeAction => 'Cerrar';
}
