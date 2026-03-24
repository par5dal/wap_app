// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get loginPageTitle => 'Entrar';

  @override
  String get loginPageSubtitle => 'Descobre planos perto de ti';

  @override
  String get loginPageEmailHint => 'Correio Eletrónico';

  @override
  String get loginPagePasswordHint => 'Palavra-passe';

  @override
  String get loginPageForgotPassword => 'Esqueceste a tua palavra-passe?';

  @override
  String get loginPageLoginButton => 'Entrar';

  @override
  String get loginPageNoAccount => 'Não tens conta?';

  @override
  String get loginPageRegister => 'Regista-te';

  @override
  String get loginPageTermsAndPolicy =>
      'Ao continuar aceitas os Termos e a Política de Privacidade';

  @override
  String get loginSuccessMessage => 'Login efetuado com sucesso!';

  @override
  String get loginErrorMessage =>
      'Credenciais incorretas ou erro do servidor. Tenta novamente.';

  @override
  String get registerEmailVerifTitle => 'Confirma o teu email';

  @override
  String registerEmailVerifMessage(String email) {
    return 'Enviámos um email de confirmação para $email. Por favor, verifica a tua caixa de entrada e clica no link para ativar a conta.';
  }

  @override
  String get ok => 'OK';

  @override
  String get registerPageTitle => 'Criar Conta';

  @override
  String get registerPageSubtitle => 'Começa a descobrir planos incríveis';

  @override
  String get registerPageRegisterButton => 'Criar Conta';

  @override
  String get registerPageLoginPrompt => 'Já tens uma conta?';

  @override
  String get registerPageTermsAndPolicy =>
      'Ao registar-te aceitas os Termos e a Política de Privacidade';

  @override
  String get registerPageLoginLink => 'Entra';

  @override
  String get authPageWelcome => 'Bem-vindo!';

  @override
  String get authPageSubtitle => 'Descobre planos perto de ti';

  @override
  String get authPageEmailOrRegister => 'Entra ou regista-te';

  @override
  String get authPageLogin => 'Entrar';

  @override
  String get authPageCreateAccount => 'Cria a tua conta';

  @override
  String get authPageContinueWithEmail => 'Continuar com email';

  @override
  String get authPageContinueWithGoogle => 'Continuar com Google';

  @override
  String get authPageContinueWithApple => 'Continuar com Apple';

  @override
  String get authPageContinue => 'Continuar';

  @override
  String get authPageGoBack => 'Voltar';

  @override
  String get authPageChangeEmail => 'Alterar email';

  @override
  String get authPageAcceptTerms => 'Aceito os termos e condições';

  @override
  String get authPageMustAcceptTerms => 'Deves aceitar os termos e condições';

  @override
  String get authPageConfirmPassword => 'Confirmar palavra-passe';

  @override
  String get authPageConfirmPasswordRequired =>
      'Por favor confirma a tua palavra-passe';

  @override
  String get authPagePasswordsDoNotMatch => 'As palavras-passe não coincidem';

  @override
  String get validatorRequired => 'Este campo é obrigatório';

  @override
  String get validatorInvalidEmail => 'Formato de email inválido';

  @override
  String get validatorPasswordLength =>
      'A palavra-passe deve ter pelo menos 8 caracteres';

  @override
  String get googleSignInButton => 'Continuar com Google';

  @override
  String get homePageTitle => 'Início';

  @override
  String get navBarProfile => 'Perfil';

  @override
  String get navBarSearch => 'Pesquisar';

  @override
  String get navBarList => 'Lista';

  @override
  String get navBarLocation => 'Localização';

  @override
  String get navBarLogin => 'Entrar';

  @override
  String get navBarLogout => 'Sair';

  @override
  String get eventCardDetails => 'Detalhes';

  @override
  String get eventCardGo => 'Ir';

  @override
  String get eventCardFree => 'Grátis';

  @override
  String eventCardFromPrice(String price) {
    return 'A partir de $price';
  }

  @override
  String eventCardTodayAt(String time) {
    return 'Hoje, $time';
  }

  @override
  String eventCardDistance(String distance) {
    return '$distance km';
  }

  @override
  String get errorLocationDisabled =>
      'Os serviços de localização estão desativados.';

  @override
  String get errorLocationDenied =>
      'As permissões de localização foram negadas.';

  @override
  String get errorLocationDeniedForever =>
      'As permissões de localização estão permanentemente negadas. Ativa-as nas definições da app.';

  @override
  String get errorLoadingEvents =>
      'Não foi possível carregar os planos próximos.';

  @override
  String get logoutDialogTitle => 'Terminar Sessão';

  @override
  String get logoutDialogMessage =>
      'Tens a certeza que queres terminar sessão?';

  @override
  String get logoutDialogCancel => 'Cancelar';

  @override
  String get logoutDialogConfirm => 'Sair';

  @override
  String get logoutSuccessMessage => 'Sessão terminada com sucesso!';

  @override
  String get logoutErrorMessage => 'Erro ao terminar sessão. Tenta novamente.';

  @override
  String get profileTitle => 'O Teu Perfil';

  @override
  String get profileTabProfile => 'Perfil';

  @override
  String get profileTabFavorites => 'Favoritos';

  @override
  String get profileTabFollowing => 'Promotores';

  @override
  String get profileFirstName => 'Nome';

  @override
  String get profileFirstNameHint => 'Introduz o teu nome';

  @override
  String get profileLastName => 'Apelidos';

  @override
  String get profileLastNameHint => 'Introduz os teus apelidos';

  @override
  String get profileDateOfBirth => 'Data de nascimento';

  @override
  String get profileAddress => 'Morada';

  @override
  String get profileAddressHint => 'Rua, número, cidade';

  @override
  String get profileSave => 'Guardar';

  @override
  String get profileOmit => 'Omitir';

  @override
  String get profileSelectImageSource => 'Seleciona a origem da imagem';

  @override
  String get profileCamera => 'Câmara';

  @override
  String get profileGallery => 'Galeria';

  @override
  String get profileRemoveAvatar => 'Remover foto de perfil';

  @override
  String get profileRemoveAvatarConfirmation =>
      'Tens a certeza que queres remover a tua foto de perfil?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get remove => 'Remover';

  @override
  String get profileUpdateSuccess => 'Perfil atualizado com sucesso';

  @override
  String get profileNoFavorites => 'Não tens planos favoritos';

  @override
  String get profileNoFollowing => 'Não estás a seguir nenhum promotor';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get eventDetailDescription => 'Descrição';

  @override
  String get eventDetailLocation => 'Localização';

  @override
  String get eventDetailOpenMap => 'Como chegar';

  @override
  String get eventDetailOrganizer => 'Organizador';

  @override
  String get eventDetailViewProfile => 'Ver perfil';

  @override
  String get eventDetailFollow => 'Seguir';

  @override
  String get eventDetailSave => 'Guardar';

  @override
  String get eventDetailBuyTicket => 'Comprar Bilhete';

  @override
  String get eventDetailSignUp => 'Quero ir!';

  @override
  String get promoterProfileEvents => 'Planos';

  @override
  String get promoterProfileFollowers => 'Seguidores';

  @override
  String get promoterProfileFollow => 'Seguir';

  @override
  String get promoterProfileUnfollow => 'Deixar de seguir';

  @override
  String get promoterProfileEventsList => 'Planos do Organizador';

  @override
  String get promoterProfileNoEvents => 'Não há planos publicados';

  @override
  String get authDialogTitle => 'Junta-te ao WAP!';

  @override
  String get authDialogDescription =>
      'Entra ou regista-te para aceder ao teu perfil, guardar planos favoritos e muito mais';

  @override
  String get authDialogLogin => 'Entrar';

  @override
  String get authDialogRegister => 'Criar conta';

  @override
  String get favoriteAddedMessage => 'Adicionado aos favoritos';

  @override
  String get favoriteRemovedMessage => 'Removido dos favoritos';

  @override
  String get followingAddedMessage => 'Agora estás a seguir este promotor';

  @override
  String get followingRemovedMessage => 'Deixaste de seguir o promotor';

  @override
  String get favoriteSaved => 'Guardado';

  @override
  String get favoriteAddToFavorites => 'Adicionar aos favoritos';

  @override
  String get favoriteRemoveFromFavorites => 'Remover dos favoritos';

  @override
  String get locationBannerTitle => 'Localização desativada';

  @override
  String get locationBannerMessage =>
      'Para ver planos perto de ti, ativa os serviços de localização';

  @override
  String get locationBannerAction => 'Ativar localização';

  @override
  String get locationBannerDismiss => 'Ver todos os planos';

  @override
  String get noLocationEventsTitle => 'A mostrar todos os planos';

  @override
  String get noLocationEventsMessage =>
      'Ativa a localização para ver primeiro os planos próximos';

  @override
  String get eventFinishedBanner => 'Este plano já terminou';

  @override
  String get promoterProfileUpcoming => 'Próximos';

  @override
  String get promoterProfilePast => 'Passados';

  @override
  String get favoritesUpcoming => 'Próximos';

  @override
  String get favoritesPast => 'Passados';

  @override
  String get favoritesNoUpcoming => 'Não tens planos próximos nos favoritos';

  @override
  String get favoritesNoPast => 'Não tens planos passados nos favoritos';

  @override
  String get settingsTitle => 'Definições';

  @override
  String get settingsSectionLanguage => 'Idioma';

  @override
  String get settingsLanguageDevice => 'Idioma do dispositivo';

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
  String get settingsPrivacyPolicy => 'Política de Privacidade';

  @override
  String get settingsTermsOfUse => 'Termos de Utilização';

  @override
  String get settingsSectionAppearance => 'Aparência';

  @override
  String get settingsThemeSystem => 'Seguir dispositivo';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Escuro';

  @override
  String get settingsThemeSaved => 'Tema guardado';

  @override
  String get settingsSectionNotifications => 'Notificações';

  @override
  String get settingsNotifNewEvents => 'Novos planos de promotores seguidos';

  @override
  String get settingsNotifNewEventsDesc =>
      'Recebe uma notificação push quando um promotor que segues publica um novo plano';

  @override
  String get settingsNotifModerationEmail => 'Emails de moderação';

  @override
  String get settingsNotifModerationEmailDesc =>
      'Recebe um email quando um admin aprova ou rejeita um dos teus eventos';

  @override
  String get settingsNotifAllPaused => 'Silenciar todas as notificações';

  @override
  String get settingsNotifAllPausedDesc =>
      'Desativa todas as notificações temporariamente sem perder a tua configuração';

  @override
  String get settingsNotifSaved => 'Preferências guardadas';

  @override
  String get settingsNotifGuestBanner =>
      'Regista-te no WAP e não percas nenhum plano';

  @override
  String get settingsNotifGuestBannerCta => 'Regista-te grátis';

  @override
  String get settingsSectionPermissions => 'Permissões';

  @override
  String get settingsPermLocation => 'Localização';

  @override
  String get settingsPermLocationDesc =>
      'Necessária para centrar o mapa na tua posição atual';

  @override
  String get settingsPermNotifications => 'Notificações';

  @override
  String get settingsPermNotificationsDesc =>
      'Para receber alertas de novos planos de promotores que segues';

  @override
  String get settingsPermCamera => 'Câmara e fotos';

  @override
  String get settingsPermCameraDesc =>
      'Para carregar ou alterar a tua foto de perfil';

  @override
  String get settingsPermStatusGranted => 'Concedido';

  @override
  String get settingsPermStatusDenied => 'Não concedido';

  @override
  String get settingsPermStatusBlocked => 'Bloqueado';

  @override
  String get settingsPermOpenSettings => 'Abrir definições';

  @override
  String get settingsPermRevokeHint =>
      'Para revogar esta permissão vai às definições do sistema';

  @override
  String get settingsPermActivateHint =>
      'Para ativar esta permissão vai às definições do dispositivo';

  @override
  String get filterTitle => 'Filtros';

  @override
  String get filterClear => 'Limpar';

  @override
  String get filterApply => 'Aplicar';

  @override
  String get filterSectionDate => 'Data';

  @override
  String get filterDateAny => 'Qualquer data';

  @override
  String get filterDateToday => 'Hoje';

  @override
  String get filterDateTomorrow => 'Amanhã';

  @override
  String get filterDateThisWeek => 'Esta semana';

  @override
  String get filterDateThisWeekend => 'Este fim de semana';

  @override
  String get filterDateChoose => 'Escolher data';

  @override
  String get filterDateFrom => 'De';

  @override
  String get filterDateTo => 'Até';

  @override
  String get filterSectionCategory => 'Categoria';

  @override
  String get filterCategoryAll => 'Todas';

  @override
  String get filterSectionPrice => 'Preço';

  @override
  String get filterOnlyFree => 'Apenas planos gratuitos';

  @override
  String get filterPriceMin => 'Mínimo';

  @override
  String get filterPriceMax => 'Máximo';

  @override
  String get categoriesTitle => 'Categorias de Planos';

  @override
  String get categoriesError => 'Erro ao carregar categorias';

  @override
  String get categoriesEmpty => 'Nenhuma categoria encontrada';

  @override
  String get categoryPlansError => 'Erro ao carregar planos';

  @override
  String get categoryPlansEmpty => 'Sem planos';

  @override
  String get categoryPlansEmptyBody =>
      'Não há planos disponíveis\nnesta categoria';

  @override
  String get plansListSearchHint => 'Buscar planos...';

  @override
  String get plansListEmpty => 'Nenhum plano visível no mapa';

  @override
  String get plansListMoveMap => 'Mova o mapa ou ajuste os filtros';

  @override
  String get toolbarDiscoverTitle => 'Explorar WAP';

  @override
  String get toolbarDiscoverSubtitle => 'Descubra planos e promotores';

  @override
  String get toolbarDiscoverCategories => 'Planos por Categorias';

  @override
  String get toolbarDiscoverCategoriesSubtitle =>
      'Explore planos organizados por tipo';

  @override
  String get toolbarDiscoverPromoters => 'Diretório de Promotores';

  @override
  String get toolbarDiscoverPromotersSubtitle =>
      'Conheça os organizadores dos planos';

  @override
  String get promotersTitle => 'Diretório de Promotores';

  @override
  String get promotersSearchHint => 'Buscar promotores...';

  @override
  String get promotersEmpty => 'Nenhum promotor encontrado';

  @override
  String get promotersStatPlans => 'Planos';

  @override
  String get serverConnectionError => 'Erro ao conectar com o servidor';

  @override
  String get favoritesError => 'Erro ao carregar favoritos';

  @override
  String get favoritesDeleteLabel => 'Eliminar';

  @override
  String get favoritesDeleteTitle => 'Eliminar favorito';

  @override
  String get favoritesDeleteConfirm =>
      'Deseja remover este plano dos seus favoritos?';

  @override
  String get followingUnfollowSwipeLabel => 'Deixar de seguir';

  @override
  String get followingDialogTitle => 'Deixar de seguir';

  @override
  String followingDialogBody(String name) {
    return 'Deseja deixar de seguir $name?';
  }

  @override
  String get eventDetailNoDescription => 'Nenhuma descrição disponível.';

  @override
  String get eventDetailNoAddress => 'Endereço não disponível';

  @override
  String get eventDetailDefaultOrganizer => 'Organizador do Plano';

  @override
  String get forgotPasswordPageTitle => 'Esqueceste a tua senha?';

  @override
  String get forgotPasswordPageSubtitle =>
      'Introduz o teu email e enviaremos um link de recuperação';

  @override
  String get forgotPasswordPageSendButton => 'Enviar link';

  @override
  String get forgotPasswordPageSuccessTitle => 'Verifica o teu email';

  @override
  String get forgotPasswordPageSuccessMessage =>
      'Se o email estiver registado, receberás um link em breve';

  @override
  String get forgotPasswordPageBackToLogin => 'Voltar ao início de sessão';

  @override
  String get changePasswordPageTitle => 'Alterar senha';

  @override
  String get changePasswordPageCurrentPassword => 'Senha atual';

  @override
  String get changePasswordPageNewPassword => 'Nova senha';

  @override
  String get changePasswordPageConfirmPassword => 'Confirmar nova senha';

  @override
  String get changePasswordPageSaveButton => 'Alterar senha';

  @override
  String get changePasswordPageSuccess => 'Senha alterada com sucesso';

  @override
  String get changePasswordProfileTile => 'Alterar senha';

  @override
  String get deleteAccountProfileTile => 'Eliminar conta';

  @override
  String get deleteAccountConfirmTitle => 'Eliminar a tua conta?';

  @override
  String get deleteAccountConfirmMessage =>
      'Receberás um email para confirmar a eliminação. Esta ação é irreversível.';

  @override
  String get deleteAccountConfirmButton => 'Eliminar a minha conta';

  @override
  String get deleteAccountSuccess =>
      'Verifica o teu email para confirmar a eliminação';

  @override
  String get notificationsTitle => 'Notificações';

  @override
  String get notificationsEmpty => 'Não tens notificações';

  @override
  String get notificationsMarkAllRead => 'Marcar todas como lidas';

  @override
  String get notificationsDeleteAll => 'Eliminar todas';

  @override
  String get notificationsDeleteConfirm =>
      'Tens a certeza que queres eliminar todas as notificações?';

  @override
  String get profilePromotersSectionFollowing => 'Promotores que segues';

  @override
  String get profilePromotersSectionBlocked => 'Promotores bloqueados';

  @override
  String get profileNoBlocked => 'Ainda não bloqueaste nenhum promotor';

  @override
  String get profileUnblockDialogTitle => 'Desbloquear promotor';

  @override
  String profileUnblockDialogBody(String name) {
    return 'Queres desbloquear $name?';
  }

  @override
  String get profileUnblockLabel => 'Desbloquear';

  @override
  String get forceUpdateTitle => 'Atualização necessária';

  @override
  String get forceUpdateMessage =>
      'Há uma nova versão disponível com melhorias e correções importantes. Atualiza a app para continuar.';

  @override
  String get forceUpdateButton => 'Atualizar agora';

  @override
  String get settingsSectionInfo => 'Informação';

  @override
  String get settingsInfoVersion => 'Versão';

  @override
  String get settingsInfoRateApp => 'Avaliar a app';

  @override
  String get noConnectionBanner => 'Sem ligação à internet';
}
