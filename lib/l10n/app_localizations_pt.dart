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
  String eventCardTomorrowAt(String time) {
    return 'Amanhã, $time';
  }

  @override
  String eventCardOngoing(String date) {
    return 'Em curso · até $date';
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
  String eventDetailEndDate(String date) {
    return 'Até $date';
  }

  @override
  String get eventDetailDescription => 'Descrição';

  @override
  String get eventDetailSource => 'Origem';

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
      'Recebe um email quando um admin aprova ou rejeita um dos teus planos';

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
  String get toolbarDiscoverPromoterAccess => 'Acesso para Promotores';

  @override
  String get toolbarDiscoverPromoterAccessSubtitle =>
      'Crie e gerencie seus planos no WAP';

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
  String get settingsSectionTutorials => 'Tutoriais';

  @override
  String get settingsTutorialReplay => 'Ver o tutorial novamente';

  @override
  String get settingsTutorialReplayDesc =>
      'Será mostrado na próxima vez que abrir a app';

  @override
  String get settingsTutorialReplayConfirm =>
      'Reinicia a app para ver o tutorial';

  @override
  String get onboardingSlide1Title => 'Bem-vindo ao WAP!';

  @override
  String get onboardingSlide1Subtitle =>
      'A app que conecta pessoas com planos incríveis perto delas. Descobre-a em 30 segundos.';

  @override
  String get onboardingSlide2Title => 'Milhares de planos perto de ti';

  @override
  String get onboardingSlide2Subtitle =>
      'Explora o mapa, filtra por categoria e encontra o teu próximo plano perfeito em tempo real.';

  @override
  String get onboardingSlide3Title => 'Guarda o que gostas';

  @override
  String get onboardingSlide3Subtitle =>
      'Marca os teus planos favoritos, segue os teus promotores preferidos e recebe notificações quando publicarem algo novo.';

  @override
  String get onboardingSlide4Title => 'Tens planos para partilhar?';

  @override
  String get onboardingSlide4Subtitle =>
      'Cria o teu perfil de promotor, publica os teus planos e alcança milhares de pessoas perto de ti.';

  @override
  String get onboardingNext => 'Seguinte';

  @override
  String get onboardingSkip => 'Saltar';

  @override
  String get onboardingStart => 'Começar';

  @override
  String get settingsSectionInfo => 'Informação';

  @override
  String get settingsInfoVersion => 'Versão';

  @override
  String get settingsInfoRateApp => 'Avaliar a app';

  @override
  String get noConnectionBanner => 'Sem ligação à internet';

  @override
  String get next => 'Seguinte';

  @override
  String get back => 'Voltar';

  @override
  String get delete => 'Eliminar';

  @override
  String get fieldRequired => 'Este campo é obrigatório';

  @override
  String get genericError => 'Algo correu mal. Por favor, tente novamente.';

  @override
  String get forPromotersHeroTitle => 'Alcance mais pessoas com os seus planos';

  @override
  String get forPromotersHeroSubtitle =>
      'Publique os seus planos, gira as vendas e aumente a sua audiência.';

  @override
  String get forPromotersBenefitsTitle => 'O que obtém como promotor';

  @override
  String get forPromotersBenefit1Title => 'Crie e publique planos';

  @override
  String get forPromotersBenefit1Desc =>
      'Configure o seu plano em minutos com o nosso assistente passo a passo.';

  @override
  String get forPromotersBenefit2Title => 'Acompanhe o seu desempenho';

  @override
  String get forPromotersBenefit2Desc =>
      'Monitorize visualizações, favoritos e engagement em tempo real.';

  @override
  String get forPromotersBenefit3Title => 'Alcance audiências locais';

  @override
  String get forPromotersBenefit3Desc =>
      'Os seus planos aparecem no mapa para utilizadores próximos.';

  @override
  String get forPromotersBenefit4Title => 'Gestão simples';

  @override
  String get forPromotersBenefit4Desc =>
      'Edite, publique, pause ou elimine os seus planos a qualquer momento.';

  @override
  String get forPromotersCtaRegister => 'Registar gratuitamente';

  @override
  String get forPromotersCtaLogin => 'Já tem conta? Iniciar sessão';

  @override
  String get upgradeToPromoterTitle => 'Torne-se Promotor';

  @override
  String get upgradeToPromoterHeroTitle =>
      'Leve os seus planos ao próximo nível';

  @override
  String get upgradeToPromoterHeroSubtitle =>
      'Atualize a sua conta para começar a publicar planos e alcançar milhares de pessoas.';

  @override
  String get upgradeToPromoterBenefitsTitle => 'Vantagens de ser promotor';

  @override
  String get upgradeToPromoterBenefit1 => 'Crie e publique planos no mapa';

  @override
  String get upgradeToPromoterBenefit2 =>
      'Painel de análise com visualizações e favoritos';

  @override
  String get upgradeToPromoterBenefit3 =>
      'Gira os seus locais e detalhes dos planos';

  @override
  String get upgradeToPromoterBenefit4 =>
      'Aumente a sua audiência de seguidores';

  @override
  String get upgradeToPromoterCta => 'Atualizar a minha conta';

  @override
  String get upgradeToPromoterSuccess => 'A sua conta foi atualizada!';

  @override
  String get dashboardTitle => 'Os Meus Planos';

  @override
  String get dashboardTabActive => 'Ativos';

  @override
  String get dashboardTabFinished => 'Finalizados';

  @override
  String get dashboardCreateEvent => 'Criar plano';

  @override
  String get dashboardStatsTotalEvents => 'Total de planos';

  @override
  String get dashboardStatsActiveEvents => 'Ativos';

  @override
  String get dashboardStatsTotalViews => 'Visualizações';

  @override
  String get dashboardStatsTotalFavorites => 'Favoritos';

  @override
  String get dashboardStatsFollowers => 'Seguidores';

  @override
  String get dashboardSearchHint => 'Pesquisar os meus planos…';

  @override
  String get dashboardNoEvents => 'Ainda não tem planos. Crie o primeiro!';

  @override
  String get dashboardDeleteEvent => 'Eliminar plano';

  @override
  String get dashboardDeleteEventTitle => 'Eliminar este plano?';

  @override
  String get dashboardDeleteEventConfirm => 'Esta ação não pode ser desfeita.';

  @override
  String get manageEventCreateTitle => 'Criar plano';

  @override
  String get manageEventEditTitle => 'Editar plano';

  @override
  String get manageEventStep1 => 'Detalhes';

  @override
  String get manageEventStep2 => 'Local';

  @override
  String get manageEventStep3 => 'Imagens';

  @override
  String get manageEventStep4 => 'Publicar';

  @override
  String get manageEventTitle => 'Título';

  @override
  String get manageEventTitleHint => 'Dê um nome fantástico ao seu plano';

  @override
  String get manageEventDescription => 'Descrição';

  @override
  String get manageEventDescriptionHint =>
      'Conte às pessoas o que podem esperar';

  @override
  String get manageEventPrice => 'Preço (€)';

  @override
  String get manageEventPriceHint => '0 para planos gratuitos';

  @override
  String get manageEventDates => 'Datas';

  @override
  String get manageEventStartDate => 'Início';

  @override
  String get manageEventEndDate => 'Fim';

  @override
  String get manageEventCategories => 'Categorias';

  @override
  String get manageEventPickDates => 'Selecionar datas';

  @override
  String get manageEventEndBeforeStart =>
      'A data de fim deve ser posterior à de início';

  @override
  String get manageEventPickCategory => 'Selecione pelo menos uma categoria';

  @override
  String get manageEventInvalidPrice => 'Introduza um preço válido';

  @override
  String get manageEventMyVenues => 'Os meus locais';

  @override
  String get manageEventSearchVenue => 'Pesquisar';

  @override
  String get manageEventNoSavedVenues => 'Não tem locais guardados';

  @override
  String get manageEventSearchPlaceholder => 'Pesquisar local ou endereço…';

  @override
  String get manageEventNoResults => 'Sem resultados';

  @override
  String get manageEventVenue => 'Local';

  @override
  String get manageEventImagesTitle => 'Imagens do plano';

  @override
  String get manageEventImagesSubtitle =>
      'Adicione até 3 imagens. A primeira será a foto de capa.';

  @override
  String get manageEventImageSourceCamera => 'Câmara';

  @override
  String get manageEventImageSourceGallery => 'Galeria';

  @override
  String get manageEventCameraPermissionDenied =>
      'É necessária permissão de câmara para tirar fotos';

  @override
  String get settings => 'Definições';

  @override
  String get manageEventAddImage => 'Adicionar imagem';

  @override
  String get manageEventFree => 'Grátis';

  @override
  String get manageEventPreviewBadge => 'Pré-visualização';

  @override
  String get manageEventPrimaryImage => 'Capa';

  @override
  String get manageEventImage => 'Imagem';

  @override
  String get manageEventImagesCount => 'Imagens';

  @override
  String get manageEventReviewTitle => 'Rever e publicar';

  @override
  String get manageEventSaveDraft => 'Guardar rascunho';

  @override
  String get manageEventPublish => 'Enviar para revisão';

  @override
  String get manageEventCreateSuccess => 'Plano criado com sucesso!';

  @override
  String get manageEventUpdateSuccess => 'Plano atualizado com sucesso!';

  @override
  String get eventStatusPublished => 'Publicado';

  @override
  String get eventStatusFinished => 'Finalizado';

  @override
  String get eventStatusCancelled => 'Cancelado';

  @override
  String get eventStatusPendingApproval => 'Em revisão';

  @override
  String get eventStatusRejected => 'Rejeitado';

  @override
  String get eventStatusDraft => 'Rascunho';

  @override
  String get eventStatusUnpublish => 'Desativar publicação';

  @override
  String get eventStatusDescription => 'Descrição';

  @override
  String get categoryAddMore => 'Adicionar mais categorias';

  @override
  String get closeAction => 'Fechar';
}
