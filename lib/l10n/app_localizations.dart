import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'AlbumLog'**
  String get appTitle;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @qa.
  ///
  /// In en, this message translates to:
  /// **'QA'**
  String get qa;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About AlbumLog'**
  String get aboutTitle;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0 (Beta Testing)'**
  String get version;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'AlbumLog is the personal journal for music lovers. Our mission is to allow every music enthusiast to catalog, rate, and share their musical discoveries in a simple way.'**
  String get aboutDescription;

  /// No description provided for @developedBy.
  ///
  /// In en, this message translates to:
  /// **'Developed by'**
  String get developedBy;

  /// No description provided for @shareAlbum.
  ///
  /// In en, this message translates to:
  /// **'Share album'**
  String get shareAlbum;

  /// No description provided for @selectAtLeastOneStar.
  ///
  /// In en, this message translates to:
  /// **'Please select at least 1 star'**
  String get selectAtLeastOneStar;

  /// No description provided for @reviewSavedCloud.
  ///
  /// In en, this message translates to:
  /// **'Review saved locally and backed up to the cloud!'**
  String get reviewSavedCloud;

  /// No description provided for @reviewSavedLocal.
  ///
  /// In en, this message translates to:
  /// **'Review saved to your local collection! (Sign in to back it up)'**
  String get reviewSavedLocal;

  /// No description provided for @errorSaving.
  ///
  /// In en, this message translates to:
  /// **'Error while saving:'**
  String get errorSaving;

  /// No description provided for @whatDidYouThink.
  ///
  /// In en, this message translates to:
  /// **'What did you think about this album?'**
  String get whatDidYouThink;

  /// No description provided for @writeReview.
  ///
  /// In en, this message translates to:
  /// **'Write your review (optional)'**
  String get writeReview;

  /// No description provided for @publishReview.
  ///
  /// In en, this message translates to:
  /// **'Publish review'**
  String get publishReview;

  /// No description provided for @similarAlbums.
  ///
  /// In en, this message translates to:
  /// **'Similar albums'**
  String get similarAlbums;

  /// No description provided for @shareMessage.
  ///
  /// In en, this message translates to:
  /// **'Check out this amazing album I found on AlbumLog!'**
  String get shareMessage;

  /// No description provided for @byArtist.
  ///
  /// In en, this message translates to:
  /// **'by'**
  String get byArtist;

  /// No description provided for @downloadApp.
  ///
  /// In en, this message translates to:
  /// **'Download the app and build your collection!'**
  String get downloadApp;

  /// No description provided for @exploreAlbums.
  ///
  /// In en, this message translates to:
  /// **'Explore Albums'**
  String get exploreAlbums;

  /// No description provided for @searchAlbumArtist.
  ///
  /// In en, this message translates to:
  /// **'Search album or artist...'**
  String get searchAlbumArtist;

  /// No description provided for @searchYourFavoriteAlbum.
  ///
  /// In en, this message translates to:
  /// **'Search for your favorite album or artist...'**
  String get searchYourFavoriteAlbum;

  /// No description provided for @searching.
  ///
  /// In en, this message translates to:
  /// **'Searching online...'**
  String get searching;

  /// No description provided for @noAlbumsFound.
  ///
  /// In en, this message translates to:
  /// **'No albums found.'**
  String get noAlbumsFound;

  /// No description provided for @serverUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Server unavailable.'**
  String get serverUnavailable;

  /// No description provided for @requestTimeout.
  ///
  /// In en, this message translates to:
  /// **'Request timed out.'**
  String get requestTimeout;

  /// No description provided for @connectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection failed.'**
  String get connectionFailed;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @unknownArtist.
  ///
  /// In en, this message translates to:
  /// **'Unknown artist'**
  String get unknownArtist;

  /// No description provided for @lastFmDescription.
  ///
  /// In en, this message translates to:
  /// **'Album obtained from the Last.fm database'**
  String get lastFmDescription;

  /// No description provided for @homeWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to your music journal'**
  String get homeWelcome;

  /// No description provided for @homeDescription.
  ///
  /// In en, this message translates to:
  /// **'AlbumLog is the place where your favorite albums come to life. Here you don\'t just listen to music—you experience it, review it, and share it.'**
  String get homeDescription;

  /// No description provided for @personalReviews.
  ///
  /// In en, this message translates to:
  /// **'Personal Reviews'**
  String get personalReviews;

  /// No description provided for @personalReviewsDescription.
  ///
  /// In en, this message translates to:
  /// **'Rate each album from 1 to 5 stars and leave your opinion.'**
  String get personalReviewsDescription;

  /// No description provided for @community.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get community;

  /// No description provided for @communityDescription.
  ///
  /// In en, this message translates to:
  /// **'Follow your friends and discover what they\'re listening to.'**
  String get communityDescription;

  /// No description provided for @myMusicProfile.
  ///
  /// In en, this message translates to:
  /// **'My Music Profile'**
  String get myMusicProfile;

  /// No description provided for @googleUser.
  ///
  /// In en, this message translates to:
  /// **'Google User'**
  String get googleUser;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get logout;

  /// No description provided for @logoutSuccess.
  ///
  /// In en, this message translates to:
  /// **'Signed out successfully'**
  String get logoutSuccess;

  /// No description provided for @syncCloud.
  ///
  /// In en, this message translates to:
  /// **'Sync your account to the cloud'**
  String get syncCloud;

  /// No description provided for @syncCloudDescription.
  ///
  /// In en, this message translates to:
  /// **'Sign in to back up your reviews and ratings.'**
  String get syncCloudDescription;

  /// No description provided for @signInGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInGoogle;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome,'**
  String get welcome;

  /// No description provided for @authenticationError.
  ///
  /// In en, this message translates to:
  /// **'Authentication error:'**
  String get authenticationError;

  /// No description provided for @accountPreferences.
  ///
  /// In en, this message translates to:
  /// **'My Account & Preferences'**
  String get accountPreferences;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @favoriteGenre.
  ///
  /// In en, this message translates to:
  /// **'Favorite Music Genre'**
  String get favoriteGenre;

  /// No description provided for @myRatedAlbums.
  ///
  /// In en, this message translates to:
  /// **'My Rated Albums'**
  String get myRatedAlbums;

  /// No description provided for @albums.
  ///
  /// In en, this message translates to:
  /// **'albums'**
  String get albums;

  /// No description provided for @noSavedAlbums.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any albums saved locally.\nRate albums from the search screen!'**
  String get noSavedAlbums;

  /// No description provided for @localRecordDeleted.
  ///
  /// In en, this message translates to:
  /// **'Record deleted from local storage'**
  String get localRecordDeleted;

  /// No description provided for @qaTitle.
  ///
  /// In en, this message translates to:
  /// **'Beta Testing QA'**
  String get qaTitle;

  /// No description provided for @qaDescription.
  ///
  /// In en, this message translates to:
  /// **'Please rate the following aspects (0 to 5 stars):'**
  String get qaDescription;

  /// No description provided for @stars.
  ///
  /// In en, this message translates to:
  /// **'stars'**
  String get stars;

  /// No description provided for @minimum.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get minimum;

  /// No description provided for @maximum.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get maximum;

  /// No description provided for @sendResults.
  ///
  /// In en, this message translates to:
  /// **'SUBMIT RESULTS'**
  String get sendResults;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @visualAspect.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get visualAspect;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @changeTheme.
  ///
  /// In en, this message translates to:
  /// **'Change the theme for the entire application'**
  String get changeTheme;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @spanishChile.
  ///
  /// In en, this message translates to:
  /// **'Spanish (Chile)'**
  String get spanishChile;

  /// No description provided for @userDefaultName.
  ///
  /// In en, this message translates to:
  /// **'AlbumLog User'**
  String get userDefaultName;

  /// No description provided for @comments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get comments;

  /// No description provided for @loginToComment.
  ///
  /// In en, this message translates to:
  /// **'You must sign in to comment.'**
  String get loginToComment;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @noComment.
  ///
  /// In en, this message translates to:
  /// **'No comment'**
  String get noComment;

  /// No description provided for @beFirstComment.
  ///
  /// In en, this message translates to:
  /// **'Be the first to comment.'**
  String get beFirstComment;

  /// No description provided for @writeComment.
  ///
  /// In en, this message translates to:
  /// **'Write a comment...'**
  String get writeComment;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @viewPublicProfile.
  ///
  /// In en, this message translates to:
  /// **'View Public Profile'**
  String get viewPublicProfile;

  /// No description provided for @allGenres.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allGenres;

  /// No description provided for @rock.
  ///
  /// In en, this message translates to:
  /// **'Rock'**
  String get rock;

  /// No description provided for @pop.
  ///
  /// In en, this message translates to:
  /// **'Pop'**
  String get pop;

  /// No description provided for @metal.
  ///
  /// In en, this message translates to:
  /// **'Metal'**
  String get metal;

  /// No description provided for @jazz.
  ///
  /// In en, this message translates to:
  /// **'Jazz'**
  String get jazz;

  /// No description provided for @electronic.
  ///
  /// In en, this message translates to:
  /// **'Electronic'**
  String get electronic;

  /// No description provided for @hipHop.
  ///
  /// In en, this message translates to:
  /// **'Hip-Hop'**
  String get hipHop;

  /// No description provided for @noCommentsYet.
  ///
  /// In en, this message translates to:
  /// **'There are no comments yet.'**
  String get noCommentsYet;

  /// No description provided for @profileOf.
  ///
  /// In en, this message translates to:
  /// **'Profile of {name}'**
  String profileOf(Object name);

  /// No description provided for @errorLoadingProfile.
  ///
  /// In en, this message translates to:
  /// **'Error loading profile information'**
  String get errorLoadingProfile;

  /// No description provided for @favoriteGenreLabel.
  ///
  /// In en, this message translates to:
  /// **'Favorite Genre: {genre}'**
  String favoriteGenreLabel(Object genre);

  /// No description provided for @notSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get notSpecified;

  /// No description provided for @sendFriendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send Friend Request'**
  String get sendFriendRequest;

  /// No description provided for @friendsRemove.
  ///
  /// In en, this message translates to:
  /// **'Friends (Remove)'**
  String get friendsRemove;

  /// No description provided for @pendingRequestCancel.
  ///
  /// In en, this message translates to:
  /// **'Pending Request (Cancel)'**
  String get pendingRequestCancel;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @musicActivity.
  ///
  /// In en, this message translates to:
  /// **'Music Activity'**
  String get musicActivity;

  /// No description provided for @userNoReviews.
  ///
  /// In en, this message translates to:
  /// **'This user hasn\'t shared any reviews yet.'**
  String get userNoReviews;

  /// No description provided for @album.
  ///
  /// In en, this message translates to:
  /// **'Album'**
  String get album;

  /// No description provided for @ratingLabel.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get ratingLabel;

  /// No description provided for @userSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search music lovers...'**
  String get userSearchHint;

  /// No description provided for @searchUserMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a username to search'**
  String get searchUserMessage;

  /// No description provided for @noUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get noUsersFound;

  /// No description provided for @noFavoriteGenre.
  ///
  /// In en, this message translates to:
  /// **'No favorite genre'**
  String get noFavoriteGenre;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
