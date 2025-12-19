import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

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
    Locale('hi')
  ];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'Mr Muscle'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @todayReport.
  ///
  /// In en, this message translates to:
  /// **'Today Report'**
  String get todayReport;

  /// No description provided for @reportFor.
  ///
  /// In en, this message translates to:
  /// **'Report for {date}'**
  String reportFor(String date);

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @discover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discover;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// No description provided for @goodNight.
  ///
  /// In en, this message translates to:
  /// **'Good Night'**
  String get goodNight;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back! 👋'**
  String get welcomeBack;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @letsBegin.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Begin'**
  String get letsBegin;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @steps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get steps;

  /// No description provided for @stepsToday.
  ///
  /// In en, this message translates to:
  /// **'Steps Today'**
  String get stepsToday;

  /// No description provided for @dailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily Goal'**
  String get dailyGoal;

  /// No description provided for @stepCounter.
  ///
  /// In en, this message translates to:
  /// **'Step Counter'**
  String get stepCounter;

  /// No description provided for @stepsRemaining.
  ///
  /// In en, this message translates to:
  /// **'steps remaining'**
  String get stepsRemaining;

  /// No description provided for @goalAchieved.
  ///
  /// In en, this message translates to:
  /// **'Goal Achieved!'**
  String get goalAchieved;

  /// No description provided for @keepGoing.
  ///
  /// In en, this message translates to:
  /// **'Keep Going!'**
  String get keepGoing;

  /// No description provided for @walking.
  ///
  /// In en, this message translates to:
  /// **'Walking'**
  String get walking;

  /// No description provided for @stopped.
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get stopped;

  /// No description provided for @tracking.
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get tracking;

  /// No description provided for @water.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get water;

  /// No description provided for @waterIntake.
  ///
  /// In en, this message translates to:
  /// **'water intake'**
  String get waterIntake;

  /// No description provided for @glasses.
  ///
  /// In en, this message translates to:
  /// **'Glasses'**
  String get glasses;

  /// No description provided for @glassesLeft.
  ///
  /// In en, this message translates to:
  /// **'glasses left'**
  String get glassesLeft;

  /// No description provided for @stayHydrated.
  ///
  /// In en, this message translates to:
  /// **'Stay Hydrated'**
  String get stayHydrated;

  /// No description provided for @drinkWater.
  ///
  /// In en, this message translates to:
  /// **'Drink Water'**
  String get drinkWater;

  /// No description provided for @sleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleep;

  /// No description provided for @sleepTracking.
  ///
  /// In en, this message translates to:
  /// **'Sleep Tracking'**
  String get sleepTracking;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hours;

  /// No description provided for @sleepQuality.
  ///
  /// In en, this message translates to:
  /// **'Sleep Quality'**
  String get sleepQuality;

  /// No description provided for @goodSleep.
  ///
  /// In en, this message translates to:
  /// **'Good Sleep'**
  String get goodSleep;

  /// No description provided for @bedtime.
  ///
  /// In en, this message translates to:
  /// **'Bedtime'**
  String get bedtime;

  /// No description provided for @wakeUp.
  ///
  /// In en, this message translates to:
  /// **'Wake Up'**
  String get wakeUp;

  /// No description provided for @excellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent!'**
  String get excellent;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// No description provided for @fair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get fair;

  /// No description provided for @poor.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get poor;

  /// No description provided for @veryPoor.
  ///
  /// In en, this message translates to:
  /// **'Very Poor'**
  String get veryPoor;

  /// No description provided for @bmi.
  ///
  /// In en, this message translates to:
  /// **'BMI'**
  String get bmi;

  /// No description provided for @bmiCalculator.
  ///
  /// In en, this message translates to:
  /// **'BMI Calculator'**
  String get bmiCalculator;

  /// No description provided for @bodyMassIndex.
  ///
  /// In en, this message translates to:
  /// **'Body Mass Index'**
  String get bodyMassIndex;

  /// No description provided for @calculate.
  ///
  /// In en, this message translates to:
  /// **'Calculate'**
  String get calculate;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @workouts.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get workouts;

  /// No description provided for @workoutPlans.
  ///
  /// In en, this message translates to:
  /// **'Workout Plans'**
  String get workoutPlans;

  /// No description provided for @myWorkouts.
  ///
  /// In en, this message translates to:
  /// **'My Workouts'**
  String get myWorkouts;

  /// No description provided for @startWorkout.
  ///
  /// In en, this message translates to:
  /// **'Start Workout'**
  String get startWorkout;

  /// No description provided for @exercises.
  ///
  /// In en, this message translates to:
  /// **'exercises'**
  String get exercises;

  /// No description provided for @sets.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get sets;

  /// No description provided for @reps.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get reps;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @restTime.
  ///
  /// In en, this message translates to:
  /// **'Rest Time'**
  String get restTime;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @workoutPlan.
  ///
  /// In en, this message translates to:
  /// **'Workout Plan'**
  String get workoutPlan;

  /// No description provided for @knowYourWorkoutPlans.
  ///
  /// In en, this message translates to:
  /// **'Know Your Workout Plans'**
  String get knowYourWorkoutPlans;

  /// No description provided for @nutrition.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get nutrition;

  /// No description provided for @recipes.
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get recipes;

  /// No description provided for @allRecipes.
  ///
  /// In en, this message translates to:
  /// **'All Recipes'**
  String get allRecipes;

  /// No description provided for @ingredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  /// No description provided for @cookingSteps.
  ///
  /// In en, this message translates to:
  /// **'Cooking Steps'**
  String get cookingSteps;

  /// No description provided for @prepTime.
  ///
  /// In en, this message translates to:
  /// **'Prep Time'**
  String get prepTime;

  /// No description provided for @cookTime.
  ///
  /// In en, this message translates to:
  /// **'Cook Time'**
  String get cookTime;

  /// No description provided for @servings.
  ///
  /// In en, this message translates to:
  /// **'servings'**
  String get servings;

  /// No description provided for @calories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get calories;

  /// No description provided for @protein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get protein;

  /// No description provided for @carbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get carbs;

  /// No description provided for @fat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get fat;

  /// No description provided for @meals.
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get meals;

  /// No description provided for @loadingNutritionData.
  ///
  /// In en, this message translates to:
  /// **'Loading nutrition data...'**
  String get loadingNutritionData;

  /// No description provided for @healthyRecipes.
  ///
  /// In en, this message translates to:
  /// **'Healthy Recipes'**
  String get healthyRecipes;

  /// No description provided for @viewYourPersonalizedDiet.
  ///
  /// In en, this message translates to:
  /// **'View Your Personalized Diet'**
  String get viewYourPersonalizedDiet;

  /// No description provided for @todaysResult.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Result'**
  String get todaysResult;

  /// No description provided for @bodyComposition.
  ///
  /// In en, this message translates to:
  /// **'Body Composition'**
  String get bodyComposition;

  /// No description provided for @muscleMass.
  ///
  /// In en, this message translates to:
  /// **'Muscle Mass'**
  String get muscleMass;

  /// No description provided for @bodyFat.
  ///
  /// In en, this message translates to:
  /// **'Body Fat'**
  String get bodyFat;

  /// No description provided for @bodyWater.
  ///
  /// In en, this message translates to:
  /// **'Body Water'**
  String get bodyWater;

  /// No description provided for @boneMass.
  ///
  /// In en, this message translates to:
  /// **'Bone Mass'**
  String get boneMass;

  /// No description provided for @visceralFat.
  ///
  /// In en, this message translates to:
  /// **'Visceral Fat'**
  String get visceralFat;

  /// No description provided for @awareness.
  ///
  /// In en, this message translates to:
  /// **'Awareness'**
  String get awareness;

  /// No description provided for @articles.
  ///
  /// In en, this message translates to:
  /// **'Articles'**
  String get articles;

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Read More'**
  String get readMore;

  /// No description provided for @learnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn More'**
  String get learnMore;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @shop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shop;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCart;

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @buy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get buy;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'हिंदी'**
  String get hindi;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightMode;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @verifyYourPhone.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Phone 📱'**
  String get verifyYourPhone;

  /// No description provided for @enterPhoneToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number to sign in to your account'**
  String get enterPhoneToSignIn;

  /// No description provided for @verificationCodeSent.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification code to'**
  String get verificationCodeSent;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @enterYourPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterYourPhoneNumber;

  /// No description provided for @enterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get enterOtp;

  /// No description provided for @enterSixDigitOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter 6-digit OTP'**
  String get enterSixDigitOtp;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @resendCodeIn.
  ///
  /// In en, this message translates to:
  /// **'Resend code in'**
  String get resendCodeIn;

  /// No description provided for @didntReceiveCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code?'**
  String get didntReceiveCode;

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @termsAcceptanceRequired.
  ///
  /// In en, this message translates to:
  /// **'Terms acceptance is required to proceed'**
  String get termsAcceptanceRequired;

  /// No description provided for @termsAccepted.
  ///
  /// In en, this message translates to:
  /// **'Terms accepted on login screen'**
  String get termsAccepted;

  /// No description provided for @agreeToTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms and Conditions'**
  String get agreeToTerms;

  /// No description provided for @phoneNotRegistered.
  ///
  /// In en, this message translates to:
  /// **'Phone Number Not Registered'**
  String get phoneNotRegistered;

  /// No description provided for @phoneNotInCrm.
  ///
  /// In en, this message translates to:
  /// **'This phone number is not registered in our CRM system.'**
  String get phoneNotInCrm;

  /// No description provided for @contactClubHead.
  ///
  /// In en, this message translates to:
  /// **'Please contact your club head to register your phone number in the system.'**
  String get contactClubHead;

  /// No description provided for @whereverYouAre.
  ///
  /// In en, this message translates to:
  /// **'Wherever You Are'**
  String get whereverYouAre;

  /// No description provided for @health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// No description provided for @isNumberOne.
  ///
  /// In en, this message translates to:
  /// **' Is Number One'**
  String get isNumberOne;

  /// No description provided for @noInstantWay.
  ///
  /// In en, this message translates to:
  /// **'There is no instant way to a healthy life'**
  String get noInstantWay;

  /// No description provided for @addImageToAssets.
  ///
  /// In en, this message translates to:
  /// **'Add your image to\nassets/images/fitness_women.jpg'**
  String get addImageToAssets;

  /// No description provided for @fitnessStrengthPower.
  ///
  /// In en, this message translates to:
  /// **'FITNESS • STRENGTH • POWER'**
  String get fitnessStrengthPower;

  /// No description provided for @stepsDetails.
  ///
  /// In en, this message translates to:
  /// **'Steps Details'**
  String get stepsDetails;

  /// No description provided for @usingSimulatedStepData.
  ///
  /// In en, this message translates to:
  /// **'Using Simulated Step Data'**
  String get usingSimulatedStepData;

  /// No description provided for @simulatedStepDataMessage.
  ///
  /// In en, this message translates to:
  /// **'The app is currently using simulated step data because device step tracking is not available. Grant activity recognition permission to use your phone\'s built-in pedometer for accurate step counting.'**
  String get simulatedStepDataMessage;

  /// No description provided for @enableRealSteps.
  ///
  /// In en, this message translates to:
  /// **'Enable Real Steps'**
  String get enableRealSteps;

  /// No description provided for @attemptingToSetupStepTracking.
  ///
  /// In en, this message translates to:
  /// **'Attempting to setup step tracking...'**
  String get attemptingToSetupStepTracking;

  /// No description provided for @errorSettingUpStepTracking.
  ///
  /// In en, this message translates to:
  /// **'Error setting up step tracking: {error}'**
  String errorSettingUpStepTracking(Object error);

  /// No description provided for @todaysCount.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Count'**
  String get todaysCount;

  /// No description provided for @dayCount.
  ///
  /// In en, this message translates to:
  /// **'{day}\'s Count'**
  String dayCount(Object day);

  /// No description provided for @stepsToGoal.
  ///
  /// In en, this message translates to:
  /// **'{steps} steps to goal'**
  String stepsToGoal(Object steps);

  /// No description provided for @trackingSteps.
  ///
  /// In en, this message translates to:
  /// **'Tracking Steps'**
  String get trackingSteps;

  /// No description provided for @mon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get mon;

  /// No description provided for @tue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tue;

  /// No description provided for @wed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wed;

  /// No description provided for @thu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thu;

  /// No description provided for @fri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get fri;

  /// No description provided for @sat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get sat;

  /// No description provided for @sun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sun;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @setGoal.
  ///
  /// In en, this message translates to:
  /// **'Set Goal ({goal})'**
  String setGoal(Object goal);

  /// No description provided for @shareSteps.
  ///
  /// In en, this message translates to:
  /// **'Share Steps'**
  String get shareSteps;

  /// No description provided for @setGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Goal'**
  String get setGoalTitle;

  /// No description provided for @refreshData.
  ///
  /// In en, this message translates to:
  /// **'Refresh Data'**
  String get refreshData;

  /// No description provided for @dataRefreshed.
  ///
  /// In en, this message translates to:
  /// **'Data refreshed!'**
  String get dataRefreshed;

  /// No description provided for @viewHistory.
  ///
  /// In en, this message translates to:
  /// **'View History'**
  String get viewHistory;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @setDailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Set Daily Goal'**
  String get setDailyGoal;

  /// No description provided for @dailyStepsGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily Steps Goal'**
  String get dailyStepsGoal;

  /// No description provided for @egTenThousand.
  ///
  /// In en, this message translates to:
  /// **'e.g., 10000'**
  String get egTenThousand;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @goalUpdatedTo.
  ///
  /// In en, this message translates to:
  /// **'Goal updated to {goal} steps!'**
  String goalUpdatedTo(Object goal);

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'{feature} coming soon!'**
  String comingSoon(Object feature);

  /// No description provided for @hourlySteps.
  ///
  /// In en, this message translates to:
  /// **'Hourly Steps'**
  String get hourlySteps;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'on'**
  String get on;

  /// No description provided for @goal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goal;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'remaining'**
  String get remaining;

  /// No description provided for @quickAdd.
  ///
  /// In en, this message translates to:
  /// **'Quick Add'**
  String get quickAdd;

  /// No description provided for @customAmount.
  ///
  /// In en, this message translates to:
  /// **'Custom Amount'**
  String get customAmount;

  /// No description provided for @todaysIntake.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Intake'**
  String get todaysIntake;

  /// No description provided for @noIntakeYet.
  ///
  /// In en, this message translates to:
  /// **'No intake yet today'**
  String get noIntakeYet;

  /// No description provided for @startDrinking.
  ///
  /// In en, this message translates to:
  /// **'Start drinking water!'**
  String get startDrinking;

  /// No description provided for @addedWaterSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Added {amount}ml water successfully!'**
  String addedWaterSuccessfully(Object amount);

  /// No description provided for @waterIntakeRemovedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Water intake removed successfully!'**
  String get waterIntakeRemovedSuccessfully;

  /// No description provided for @failedToAddWater.
  ///
  /// In en, this message translates to:
  /// **'Failed to add water'**
  String get failedToAddWater;

  /// No description provided for @failedToRemoveWater.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove water'**
  String get failedToRemoveWater;

  /// No description provided for @failedToUpdateGoal.
  ///
  /// In en, this message translates to:
  /// **'Failed to update goal'**
  String get failedToUpdateGoal;

  /// No description provided for @todaysIntakeHasBeenReset.
  ///
  /// In en, this message translates to:
  /// **'Today\'s intake has been reset'**
  String get todaysIntakeHasBeenReset;

  /// No description provided for @failedToResetIntake.
  ///
  /// In en, this message translates to:
  /// **'Failed to reset intake'**
  String get failedToResetIntake;

  /// No description provided for @addCustomAmount.
  ///
  /// In en, this message translates to:
  /// **'Add Custom Amount'**
  String get addCustomAmount;

  /// No description provided for @enterWaterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter the amount of water you drank'**
  String get enterWaterAmount;

  /// No description provided for @amountMl.
  ///
  /// In en, this message translates to:
  /// **'Amount (ml)'**
  String get amountMl;

  /// No description provided for @egAmount.
  ///
  /// In en, this message translates to:
  /// **'e.g., 350'**
  String get egAmount;

  /// No description provided for @typeOptional.
  ///
  /// In en, this message translates to:
  /// **'Type (optional)'**
  String get typeOptional;

  /// No description provided for @egPostWorkout.
  ///
  /// In en, this message translates to:
  /// **'e.g., Post-workout, With meal'**
  String get egPostWorkout;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @deleteIntake.
  ///
  /// In en, this message translates to:
  /// **'Delete Intake'**
  String get deleteIntake;

  /// No description provided for @deleteIntakeConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this water intake entry?'**
  String get deleteIntakeConfirmation;

  /// No description provided for @goalAchievedTitle.
  ///
  /// In en, this message translates to:
  /// **'🎉 Goal Achieved!'**
  String get goalAchievedTitle;

  /// No description provided for @goalAchievedMessage.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! You\'ve reached your daily water goal of {goal}ml. Keep up the great hydration!'**
  String goalAchievedMessage(Object goal);

  /// No description provided for @awesome.
  ///
  /// In en, this message translates to:
  /// **'Awesome!'**
  String get awesome;

  /// No description provided for @currentGoal.
  ///
  /// In en, this message translates to:
  /// **'Current: {goal}ml'**
  String currentGoal(int goal);

  /// No description provided for @viewStatistics.
  ///
  /// In en, this message translates to:
  /// **'View Statistics'**
  String get viewStatistics;

  /// No description provided for @seeHydrationStats.
  ///
  /// In en, this message translates to:
  /// **'See your hydration stats'**
  String get seeHydrationStats;

  /// No description provided for @resetToday.
  ///
  /// In en, this message translates to:
  /// **'Reset Today'**
  String get resetToday;

  /// No description provided for @clearAllIntake.
  ///
  /// In en, this message translates to:
  /// **'Clear all intake for today'**
  String get clearAllIntake;

  /// No description provided for @seePastDaysIntake.
  ///
  /// In en, this message translates to:
  /// **'See past days intake'**
  String get seePastDaysIntake;

  /// No description provided for @setYourDailyWaterGoal.
  ///
  /// In en, this message translates to:
  /// **'Set your daily water intake goal'**
  String get setYourDailyWaterGoal;

  /// No description provided for @dailyWaterGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily Water Goal (ml)'**
  String get dailyWaterGoal;

  /// No description provided for @recommendedAmount.
  ///
  /// In en, this message translates to:
  /// **'Recommended: 2000-3000ml'**
  String get recommendedAmount;

  /// No description provided for @setGoalButton.
  ///
  /// In en, this message translates to:
  /// **'Set Goal'**
  String get setGoalButton;

  /// No description provided for @goalUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Goal updated successfully!'**
  String get goalUpdatedSuccessfully;

  /// No description provided for @resetTodayTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Today\'s Intake'**
  String get resetTodayTitle;

  /// No description provided for @resetTodayConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset all water intake for today? This action cannot be undone.'**
  String get resetTodayConfirmation;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @waterStatistics.
  ///
  /// In en, this message translates to:
  /// **'Water Statistics'**
  String get waterStatistics;

  /// No description provided for @loadingStatistics.
  ///
  /// In en, this message translates to:
  /// **'Loading statistics...'**
  String get loadingStatistics;

  /// No description provided for @totalIntake.
  ///
  /// In en, this message translates to:
  /// **'Total Intake'**
  String get totalIntake;

  /// No description provided for @averageDaily.
  ///
  /// In en, this message translates to:
  /// **'Average Daily'**
  String get averageDaily;

  /// No description provided for @bestDay.
  ///
  /// In en, this message translates to:
  /// **'Best Day'**
  String get bestDay;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @completionPercentage.
  ///
  /// In en, this message translates to:
  /// **'{percentage}% of daily goal'**
  String completionPercentage(Object percentage);

  /// No description provided for @failedToLoadStatistics.
  ///
  /// In en, this message translates to:
  /// **'Failed to load statistics: {error}'**
  String failedToLoadStatistics(Object error);

  /// No description provided for @waterIntakeHistory.
  ///
  /// In en, this message translates to:
  /// **'Water Intake History'**
  String get waterIntakeHistory;

  /// No description provided for @noHistoryAvailable.
  ///
  /// In en, this message translates to:
  /// **'No history available'**
  String get noHistoryAvailable;

  /// No description provided for @startTrackingHistory.
  ///
  /// In en, this message translates to:
  /// **'Start tracking to see your history'**
  String get startTrackingHistory;

  /// No description provided for @almostThere.
  ///
  /// In en, this message translates to:
  /// **'Almost there!'**
  String get almostThere;

  /// No description provided for @goalAchievedStatus.
  ///
  /// In en, this message translates to:
  /// **'Goal Achieved!'**
  String get goalAchievedStatus;

  /// No description provided for @keepItUp.
  ///
  /// In en, this message translates to:
  /// **'Keep it up!'**
  String get keepItUp;

  /// No description provided for @drinksCount.
  ///
  /// In en, this message translates to:
  /// **'{count} drinks'**
  String drinksCount(int count);

  /// No description provided for @pleaseEnterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount (1-2000ml)'**
  String get pleaseEnterValidAmount;

  /// No description provided for @deleteWaterIntake.
  ///
  /// In en, this message translates to:
  /// **'Delete Water Intake'**
  String get deleteWaterIntake;

  /// No description provided for @deleteWaterIntakeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {amount}ml intake from {time}?'**
  String deleteWaterIntakeConfirm(String amount, String time);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @hydrationGoalAchieved.
  ///
  /// In en, this message translates to:
  /// **'Hydration Goal Achieved! 🎉'**
  String get hydrationGoalAchieved;

  /// No description provided for @greatJobReachedGoal.
  ///
  /// In en, this message translates to:
  /// **'Great job! You\'ve reached your daily water intake goal of {goal}ml.'**
  String greatJobReachedGoal(int goal);

  /// No description provided for @energyDipFighter.
  ///
  /// In en, this message translates to:
  /// **'Energy Dip Fighter ⚡'**
  String get energyDipFighter;

  /// No description provided for @beatAfternoonSlump.
  ///
  /// In en, this message translates to:
  /// **'Beat the afternoon slump with water'**
  String get beatAfternoonSlump;

  /// No description provided for @dehydrationCausesFatigue.
  ///
  /// In en, this message translates to:
  /// **'Dehydration can cause fatigue'**
  String get dehydrationCausesFatigue;

  /// No description provided for @morningBooster.
  ///
  /// In en, this message translates to:
  /// **'Morning Booster ☀️'**
  String get morningBooster;

  /// No description provided for @startDayHydrated.
  ///
  /// In en, this message translates to:
  /// **'Start your day hydrated'**
  String get startDayHydrated;

  /// No description provided for @waterJumpstartsMetabolism.
  ///
  /// In en, this message translates to:
  /// **'Water jumpstarts your metabolism'**
  String get waterJumpstartsMetabolism;

  /// No description provided for @preworkoutHydration.
  ///
  /// In en, this message translates to:
  /// **'Pre-Workout Hydration 💪'**
  String get preworkoutHydration;

  /// No description provided for @stayHydratedDuringExercise.
  ///
  /// In en, this message translates to:
  /// **'Stay hydrated during exercise'**
  String get stayHydratedDuringExercise;

  /// No description provided for @waterImprovesPerformance.
  ///
  /// In en, this message translates to:
  /// **'Water improves performance'**
  String get waterImprovesPerformance;

  /// No description provided for @bedtimeHydration.
  ///
  /// In en, this message translates to:
  /// **'Bedtime Hydration 🌙'**
  String get bedtimeHydration;

  /// No description provided for @drinkWaterBeforeSleep.
  ///
  /// In en, this message translates to:
  /// **'Drink water before sleep'**
  String get drinkWaterBeforeSleep;

  /// No description provided for @hydrationSupportsRecovery.
  ///
  /// In en, this message translates to:
  /// **'Hydration supports recovery'**
  String get hydrationSupportsRecovery;

  /// No description provided for @stayOnTrack.
  ///
  /// In en, this message translates to:
  /// **'Stay on Track! 🎯'**
  String get stayOnTrack;

  /// No description provided for @keepUpGoodWork.
  ///
  /// In en, this message translates to:
  /// **'Keep up the good work'**
  String get keepUpGoodWork;

  /// No description provided for @consistencyIsKey.
  ///
  /// In en, this message translates to:
  /// **'Consistency is key to health'**
  String get consistencyIsKey;

  /// No description provided for @hydrationStatistics.
  ///
  /// In en, this message translates to:
  /// **'Hydration Statistics'**
  String get hydrationStatistics;

  /// No description provided for @currentStreakDays.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreakDays;

  /// No description provided for @goalAchievement.
  ///
  /// In en, this message translates to:
  /// **'Goal Achievement'**
  String get goalAchievement;

  /// No description provided for @goalAchievementDays.
  ///
  /// In en, this message translates to:
  /// **'{achieved}/{total} days'**
  String goalAchievementDays(int achieved, int total);

  /// No description provided for @averageDailyIntake.
  ///
  /// In en, this message translates to:
  /// **'Average Daily'**
  String get averageDailyIntake;

  /// No description provided for @thisWeekTotal.
  ///
  /// In en, this message translates to:
  /// **'This Week Total'**
  String get thisWeekTotal;

  /// No description provided for @todaysProgress.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Progress'**
  String get todaysProgress;

  /// No description provided for @percentOfDailyGoal.
  ///
  /// In en, this message translates to:
  /// **'{percentage}% of daily goal'**
  String percentOfDailyGoal(int percentage);

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @waterIntakeHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Water Intake History'**
  String get waterIntakeHistoryTitle;

  /// No description provided for @sleepReport.
  ///
  /// In en, this message translates to:
  /// **'Sleep Report'**
  String get sleepReport;

  /// No description provided for @todaysSleep.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Sleep'**
  String get todaysSleep;

  /// No description provided for @hSleep.
  ///
  /// In en, this message translates to:
  /// **'{hours}h Sleep'**
  String hSleep(String hours);

  /// No description provided for @greatSleepQuality.
  ///
  /// In en, this message translates to:
  /// **'Great Sleep Quality!'**
  String get greatSleepQuality;

  /// No description provided for @percentQuality.
  ///
  /// In en, this message translates to:
  /// **'{quality}% Quality'**
  String percentQuality(int quality);

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @setSleepSchedule.
  ///
  /// In en, this message translates to:
  /// **'Set Sleep Schedule'**
  String get setSleepSchedule;

  /// No description provided for @setSleepTarget.
  ///
  /// In en, this message translates to:
  /// **'Set Sleep Target'**
  String get setSleepTarget;

  /// No description provided for @setSleepTargetWithTime.
  ///
  /// In en, this message translates to:
  /// **'Set Sleep Target ({time})'**
  String setSleepTargetWithTime(String time);

  /// No description provided for @sleepReminders.
  ///
  /// In en, this message translates to:
  /// **'Sleep Reminders'**
  String get sleepReminders;

  /// No description provided for @shareSleepData.
  ///
  /// In en, this message translates to:
  /// **'Share Sleep Data'**
  String get shareSleepData;

  /// No description provided for @setYourIdealBedtimeAndWakeup.
  ///
  /// In en, this message translates to:
  /// **'Set your ideal bedtime and wake-up time'**
  String get setYourIdealBedtimeAndWakeup;

  /// No description provided for @sleepDuration.
  ///
  /// In en, this message translates to:
  /// **'Sleep Duration: {hours}h {minutes}m'**
  String sleepDuration(int hours, int minutes);

  /// No description provided for @saveSchedule.
  ///
  /// In en, this message translates to:
  /// **'Save Schedule'**
  String get saveSchedule;

  /// No description provided for @sleepScheduleUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Sleep schedule updated successfully!'**
  String get sleepScheduleUpdatedSuccessfully;

  /// No description provided for @pleaseEnterValidTimes.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid times (hours: 0-23, minutes: 0-59)'**
  String get pleaseEnterValidTimes;

  /// No description provided for @setYourIdealSleepDuration.
  ///
  /// In en, this message translates to:
  /// **'Set your ideal sleep duration goal'**
  String get setYourIdealSleepDuration;

  /// No description provided for @sleepTarget.
  ///
  /// In en, this message translates to:
  /// **'Sleep Target'**
  String get sleepTarget;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get minutes;

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'Target: {time}'**
  String target(String time);

  /// No description provided for @sleepTargetSetTo.
  ///
  /// In en, this message translates to:
  /// **'Sleep target set to {time}!'**
  String sleepTargetSetTo(String time);

  /// No description provided for @pleaseEnterValidHoursAndMinutes.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid hours (4-12) and minutes (0-59)'**
  String get pleaseEnterValidHoursAndMinutes;

  /// No description provided for @setTarget.
  ///
  /// In en, this message translates to:
  /// **'Set Target'**
  String get setTarget;

  /// No description provided for @sleepDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Sleep Duration'**
  String get sleepDurationLabel;

  /// No description provided for @sleepQualityLabel.
  ///
  /// In en, this message translates to:
  /// **'Sleep Quality'**
  String get sleepQualityLabel;

  /// No description provided for @deepSleep.
  ///
  /// In en, this message translates to:
  /// **'Deep Sleep'**
  String get deepSleep;

  /// No description provided for @hoursLabel.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hoursLabel;

  /// No description provided for @deepSleepHours.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours'**
  String deepSleepHours(String hours);

  /// No description provided for @recheck.
  ///
  /// In en, this message translates to:
  /// **'Recheck'**
  String get recheck;

  /// No description provided for @heightInCm.
  ///
  /// In en, this message translates to:
  /// **'Height (in cm)'**
  String get heightInCm;

  /// No description provided for @weightInKg.
  ///
  /// In en, this message translates to:
  /// **'Weight (in kg)'**
  String get weightInKg;

  /// No description provided for @underweight.
  ///
  /// In en, this message translates to:
  /// **'Underweight'**
  String get underweight;

  /// No description provided for @normal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get normal;

  /// No description provided for @overweight.
  ///
  /// In en, this message translates to:
  /// **'Overweight'**
  String get overweight;

  /// No description provided for @obese.
  ///
  /// In en, this message translates to:
  /// **'Obese'**
  String get obese;

  /// No description provided for @yourBMI.
  ///
  /// In en, this message translates to:
  /// **'Your BMI'**
  String get yourBMI;

  /// No description provided for @bmiResult.
  ///
  /// In en, this message translates to:
  /// **'BMI Result'**
  String get bmiResult;

  /// No description provided for @healthyRange.
  ///
  /// In en, this message translates to:
  /// **'Healthy Range: 18.5 - 24.9'**
  String get healthyRange;

  /// No description provided for @yourBMIis.
  ///
  /// In en, this message translates to:
  /// **'Your BMI is'**
  String get yourBMIis;

  /// No description provided for @bmiUnderweightDescription.
  ///
  /// In en, this message translates to:
  /// **'A BMI less than 18.5 indicates that you may be underweight. It\'s important to consult with a healthcare provider.'**
  String get bmiUnderweightDescription;

  /// No description provided for @bmiNormalDescription.
  ///
  /// In en, this message translates to:
  /// **'A BMI of 18.5 - 24.9 indicates that you are at a healthy weight for your height. By maintaining a healthy weight, you lower your risk of developing serious health problems.'**
  String get bmiNormalDescription;

  /// No description provided for @bmiOverweightDescription.
  ///
  /// In en, this message translates to:
  /// **'A BMI of 25 - 29.9 indicates that you may be overweight. Consider consulting with a healthcare provider about healthy weight management.'**
  String get bmiOverweightDescription;

  /// No description provided for @bmiObeseDescription.
  ///
  /// In en, this message translates to:
  /// **'A BMI of 30 or higher indicates obesity. It\'s recommended to consult with a healthcare provider about healthy weight management strategies.'**
  String get bmiObeseDescription;

  /// No description provided for @medicalReferences.
  ///
  /// In en, this message translates to:
  /// **'Medical References'**
  String get medicalReferences;

  /// No description provided for @viewMedicalReferences.
  ///
  /// In en, this message translates to:
  /// **'View Medical References'**
  String get viewMedicalReferences;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @profilePicture.
  ///
  /// In en, this message translates to:
  /// **'Profile Picture'**
  String get profilePicture;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @editableInformation.
  ///
  /// In en, this message translates to:
  /// **'Editable Information'**
  String get editableInformation;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @readOnlyInformation.
  ///
  /// In en, this message translates to:
  /// **'Read-Only Information'**
  String get readOnlyInformation;

  /// No description provided for @clubCode.
  ///
  /// In en, this message translates to:
  /// **'Club Code'**
  String get clubCode;

  /// No description provided for @joinDate.
  ///
  /// In en, this message translates to:
  /// **'Join Date'**
  String get joinDate;

  /// No description provided for @membershipDuration.
  ///
  /// In en, this message translates to:
  /// **'Membership Duration'**
  String get membershipDuration;

  /// No description provided for @membershipFees.
  ///
  /// In en, this message translates to:
  /// **'Membership Fees'**
  String get membershipFees;

  /// No description provided for @months.
  ///
  /// In en, this message translates to:
  /// **'{count} months'**
  String months(int count);

  /// No description provided for @unsavedChanges.
  ///
  /// In en, this message translates to:
  /// **'Unsaved Changes'**
  String get unsavedChanges;

  /// No description provided for @unsavedChangesMessage.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Do you want to discard them?'**
  String get unsavedChangesMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @nameIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameIsRequired;

  /// No description provided for @phoneNumberIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneNumberIsRequired;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @failedToUpdateProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get failedToUpdateProfile;

  /// No description provided for @accountability.
  ///
  /// In en, this message translates to:
  /// **'Accountability'**
  String get accountability;

  /// No description provided for @myProgress.
  ///
  /// In en, this message translates to:
  /// **'My Progress'**
  String get myProgress;

  /// No description provided for @uploadNew.
  ///
  /// In en, this message translates to:
  /// **'Upload New'**
  String get uploadNew;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @selectImageSource.
  ///
  /// In en, this message translates to:
  /// **'Select Image Source'**
  String get selectImageSource;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get noDescription;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @blockUser.
  ///
  /// In en, this message translates to:
  /// **'Block User'**
  String get blockUser;

  /// No description provided for @deleteImage.
  ///
  /// In en, this message translates to:
  /// **'Delete Image'**
  String get deleteImage;

  /// No description provided for @deleteImageConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this image? This action cannot be undone.'**
  String get deleteImageConfirmation;

  /// No description provided for @imageDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Image deleted successfully'**
  String get imageDeletedSuccessfully;

  /// No description provided for @failedToDeleteImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete image'**
  String get failedToDeleteImage;

  /// No description provided for @cannotDeleteInvalidId.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete: Invalid image ID'**
  String get cannotDeleteInvalidId;

  /// No description provided for @imageNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Image not available'**
  String get imageNotAvailable;

  /// No description provided for @noImagesSelected.
  ///
  /// In en, this message translates to:
  /// **'No images selected'**
  String get noImagesSelected;

  /// No description provided for @tapButtonToAddPhotos.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button below to add\nprogress photos with description'**
  String get tapButtonToAddPhotos;

  /// No description provided for @tapHereToStart.
  ///
  /// In en, this message translates to:
  /// **'Tap here to start'**
  String get tapHereToStart;

  /// No description provided for @results.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get results;

  /// No description provided for @myResults.
  ///
  /// In en, this message translates to:
  /// **'My Results'**
  String get myResults;

  /// No description provided for @uploadResult.
  ///
  /// In en, this message translates to:
  /// **'Upload Result'**
  String get uploadResult;

  /// No description provided for @noResultsYet.
  ///
  /// In en, this message translates to:
  /// **'No results yet'**
  String get noResultsYet;

  /// No description provided for @uploadFirstProgressPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload your first progress photo to get started!'**
  String get uploadFirstProgressPhoto;

  /// No description provided for @addImages.
  ///
  /// In en, this message translates to:
  /// **'Add Images'**
  String get addImages;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @describeYourProgress.
  ///
  /// In en, this message translates to:
  /// **'Describe your progress...'**
  String get describeYourProgress;

  /// No description provided for @currentWeight.
  ///
  /// In en, this message translates to:
  /// **'Current Weight'**
  String get currentWeight;

  /// No description provided for @uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get uploading;

  /// No description provided for @resultDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Result deleted successfully'**
  String get resultDeletedSuccessfully;

  /// No description provided for @failedToDeleteResult.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete result'**
  String get failedToDeleteResult;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String daysAgo(int days);

  /// No description provided for @myDietPlan.
  ///
  /// In en, this message translates to:
  /// **'My Diet Plan'**
  String get myDietPlan;

  /// No description provided for @yourPersonalizedNutritionGuide.
  ///
  /// In en, this message translates to:
  /// **'Your personalized nutrition guide'**
  String get yourPersonalizedNutritionGuide;

  /// No description provided for @failedToLoadDietPlan.
  ///
  /// In en, this message translates to:
  /// **'Failed to load diet plan'**
  String get failedToLoadDietPlan;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'RETRY'**
  String get retry;

  /// No description provided for @noDietPlanAvailable.
  ///
  /// In en, this message translates to:
  /// **'No diet plan available'**
  String get noDietPlanAvailable;

  /// No description provided for @personalizedNutritionPlan.
  ///
  /// In en, this message translates to:
  /// **'Personalized Nutrition Plan'**
  String get personalizedNutritionPlan;

  /// No description provided for @defaultNutritionPlan.
  ///
  /// In en, this message translates to:
  /// **'Default Nutrition Plan'**
  String get defaultNutritionPlan;

  /// No description provided for @kcal.
  ///
  /// In en, this message translates to:
  /// **'kcal'**
  String get kcal;

  /// No description provided for @additionalNotes.
  ///
  /// In en, this message translates to:
  /// **'Additional Notes'**
  String get additionalNotes;

  /// No description provided for @breakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get breakfast;

  /// No description provided for @midMorningSnack.
  ///
  /// In en, this message translates to:
  /// **'Mid-Morning Snack'**
  String get midMorningSnack;

  /// No description provided for @lunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get lunch;

  /// No description provided for @eveningSnack.
  ///
  /// In en, this message translates to:
  /// **'Evening Snack'**
  String get eveningSnack;

  /// No description provided for @dinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get dinner;

  /// No description provided for @nightSnack.
  ///
  /// In en, this message translates to:
  /// **'Night Snack'**
  String get nightSnack;

  /// No description provided for @allWorkoutPlans.
  ///
  /// In en, this message translates to:
  /// **'All Workout Plans'**
  String get allWorkoutPlans;

  /// No description provided for @currentActivePlan.
  ///
  /// In en, this message translates to:
  /// **'Current Active Plan'**
  String get currentActivePlan;

  /// No description provided for @noWorkoutPlansFound.
  ///
  /// In en, this message translates to:
  /// **'No Workout Plans Found'**
  String get noWorkoutPlansFound;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @unableToLoadWorkoutPlans.
  ///
  /// In en, this message translates to:
  /// **'Unable to Load Workout Plans'**
  String get unableToLoadWorkoutPlans;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @weeks.
  ///
  /// In en, this message translates to:
  /// **'Weeks'**
  String get weeks;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @todaysWorkout.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Workout'**
  String get todaysWorkout;

  /// No description provided for @exercisePlanned.
  ///
  /// In en, this message translates to:
  /// **'{count} exercise planned'**
  String exercisePlanned(int count);

  /// No description provided for @exercisesPlanned.
  ///
  /// In en, this message translates to:
  /// **'{count} exercises planned'**
  String exercisesPlanned(int count);

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ready;

  /// No description provided for @empty.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get empty;

  /// No description provided for @instructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructions;

  /// No description provided for @noExercisesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Exercises Available'**
  String get noExercisesAvailable;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Data Available'**
  String get noDataAvailable;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @hard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hard;

  /// No description provided for @difficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @startCooking.
  ///
  /// In en, this message translates to:
  /// **'Start Cooking'**
  String get startCooking;

  /// No description provided for @aboutThisRecipe.
  ///
  /// In en, this message translates to:
  /// **'About This Recipe'**
  String get aboutThisRecipe;

  /// No description provided for @healthBenefits.
  ///
  /// In en, this message translates to:
  /// **'Health Benefits'**
  String get healthBenefits;

  /// No description provided for @heartHealthy.
  ///
  /// In en, this message translates to:
  /// **'Heart Healthy'**
  String get heartHealthy;

  /// No description provided for @heartHealthyDesc.
  ///
  /// In en, this message translates to:
  /// **'Low in saturated fats and rich in nutrients'**
  String get heartHealthyDesc;

  /// No description provided for @highProtein.
  ///
  /// In en, this message translates to:
  /// **'High Protein'**
  String get highProtein;

  /// No description provided for @highProteinDesc.
  ///
  /// In en, this message translates to:
  /// **'Supports muscle growth and repair'**
  String get highProteinDesc;

  /// No description provided for @naturalIngredients.
  ///
  /// In en, this message translates to:
  /// **'Natural Ingredients'**
  String get naturalIngredients;

  /// No description provided for @naturalIngredientsDesc.
  ///
  /// In en, this message translates to:
  /// **'Made with wholesome, natural components'**
  String get naturalIngredientsDesc;

  /// No description provided for @addedToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Added to favorites!'**
  String get addedToFavorites;

  /// No description provided for @removedFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites!'**
  String get removedFromFavorites;

  /// No description provided for @searchRecipesIngredients.
  ///
  /// In en, this message translates to:
  /// **'Search recipes, ingredients...'**
  String get searchRecipesIngredients;

  /// No description provided for @favoritesFeatureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Favorites feature coming soon!'**
  String get favoritesFeatureComingSoon;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @snacks.
  ///
  /// In en, this message translates to:
  /// **'Snacks'**
  String get snacks;

  /// No description provided for @beverages.
  ///
  /// In en, this message translates to:
  /// **'Beverages'**
  String get beverages;

  /// No description provided for @noRecipesFound.
  ///
  /// In en, this message translates to:
  /// **'No recipes found'**
  String get noRecipesFound;

  /// No description provided for @tryAdjustingFilters.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters or search terms'**
  String get tryAdjustingFilters;

  /// No description provided for @searchProductsBrands.
  ///
  /// In en, this message translates to:
  /// **'Search products, brands, and more...'**
  String get searchProductsBrands;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found for \"{query}\"'**
  String noProductsFound(String query);

  /// No description provided for @noProductsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No products available'**
  String get noProductsAvailable;

  /// No description provided for @oopsSomethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Oops! Something went wrong'**
  String get oopsSomethingWentWrong;

  /// No description provided for @buyNow.
  ///
  /// In en, this message translates to:
  /// **'Buy Now'**
  String get buyNow;

  /// No description provided for @addedToCart.
  ///
  /// In en, this message translates to:
  /// **'Added to cart'**
  String get addedToCart;

  /// No description provided for @failedToAddToCart.
  ///
  /// In en, this message translates to:
  /// **'Failed to add to cart'**
  String get failedToAddToCart;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @bestMatch.
  ///
  /// In en, this message translates to:
  /// **'Best Match'**
  String get bestMatch;

  /// No description provided for @priceLowToHigh.
  ///
  /// In en, this message translates to:
  /// **'Price: Low to High'**
  String get priceLowToHigh;

  /// No description provided for @priceHighToLow.
  ///
  /// In en, this message translates to:
  /// **'Price: High to Low'**
  String get priceHighToLow;

  /// No description provided for @highestRated.
  ///
  /// In en, this message translates to:
  /// **'Highest Rated'**
  String get highestRated;

  /// No description provided for @newestFirst.
  ///
  /// In en, this message translates to:
  /// **'Newest First'**
  String get newestFirst;

  /// No description provided for @preWorkout.
  ///
  /// In en, this message translates to:
  /// **'Pre-Workout'**
  String get preWorkout;

  /// No description provided for @postWorkout.
  ///
  /// In en, this message translates to:
  /// **'Post-Workout'**
  String get postWorkout;

  /// No description provided for @vitamins.
  ///
  /// In en, this message translates to:
  /// **'Vitamins'**
  String get vitamins;

  /// No description provided for @weightLoss.
  ///
  /// In en, this message translates to:
  /// **'Weight Loss'**
  String get weightLoss;

  /// No description provided for @muscleGain.
  ///
  /// In en, this message translates to:
  /// **'Muscle Gain'**
  String get muscleGain;

  /// No description provided for @energy.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get energy;

  /// No description provided for @productDetails.
  ///
  /// In en, this message translates to:
  /// **'Product Details'**
  String get productDetails;

  /// No description provided for @keyBenefits.
  ///
  /// In en, this message translates to:
  /// **'Key Benefits'**
  String get keyBenefits;

  /// No description provided for @fastFacts.
  ///
  /// In en, this message translates to:
  /// **'Fast Facts'**
  String get fastFacts;

  /// No description provided for @usage.
  ///
  /// In en, this message translates to:
  /// **'Usage'**
  String get usage;

  /// No description provided for @storage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storage;

  /// No description provided for @disclaimer.
  ///
  /// In en, this message translates to:
  /// **'Disclaimer'**
  String get disclaimer;

  /// No description provided for @sku.
  ///
  /// In en, this message translates to:
  /// **'SKU'**
  String get sku;

  /// No description provided for @shelfLife.
  ///
  /// In en, this message translates to:
  /// **'Shelf Life'**
  String get shelfLife;

  /// No description provided for @manufacturedBy.
  ///
  /// In en, this message translates to:
  /// **'Manufactured By'**
  String get manufacturedBy;

  /// No description provided for @marketedBy.
  ///
  /// In en, this message translates to:
  /// **'Marketed By'**
  String get marketedBy;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection.'**
  String get noInternetConnection;

  /// No description provided for @openingBrowser.
  ///
  /// In en, this message translates to:
  /// **'Opening browser...'**
  String get openingBrowser;

  /// No description provided for @unableToOpenBrowser.
  ///
  /// In en, this message translates to:
  /// **'Unable to open browser automatically'**
  String get unableToOpenBrowser;

  /// No description provided for @urlCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'URL copied to clipboard: {url}'**
  String urlCopiedToClipboard(String url);

  /// No description provided for @pleasePasteInBrowser.
  ///
  /// In en, this message translates to:
  /// **'Please paste in your browser or tap RETRY'**
  String get pleasePasteInBrowser;

  /// No description provided for @pleaseOpenUrlManually.
  ///
  /// In en, this message translates to:
  /// **'Please open the URL manually from clipboard'**
  String get pleaseOpenUrlManually;

  /// No description provided for @myOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get myOrders;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @errorLoadingOrders.
  ///
  /// In en, this message translates to:
  /// **'Error loading orders'**
  String get errorLoadingOrders;

  /// No description provided for @noOrdersFound.
  ///
  /// In en, this message translates to:
  /// **'No orders found'**
  String get noOrdersFound;

  /// No description provided for @noOrdersYet.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t made any orders yet'**
  String get noOrdersYet;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load More'**
  String get loadMore;

  /// No description provided for @orderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order #{orderId}'**
  String orderNumber(String orderId);

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @cartOrder.
  ///
  /// In en, this message translates to:
  /// **'🛒 Cart Order'**
  String get cartOrder;

  /// No description provided for @orderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetails;

  /// No description provided for @orderId.
  ///
  /// In en, this message translates to:
  /// **'Order ID'**
  String get orderId;

  /// No description provided for @gym.
  ///
  /// In en, this message translates to:
  /// **'Gym'**
  String get gym;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @reels.
  ///
  /// In en, this message translates to:
  /// **'Reels'**
  String get reels;

  /// No description provided for @shuffleReels.
  ///
  /// In en, this message translates to:
  /// **'Shuffle Reels'**
  String get shuffleReels;

  /// No description provided for @loadingReels.
  ///
  /// In en, this message translates to:
  /// **'Loading reels...'**
  String get loadingReels;

  /// No description provided for @failedToLoadReels.
  ///
  /// In en, this message translates to:
  /// **'Failed to load reels'**
  String get failedToLoadReels;

  /// No description provided for @noInternetConnectionCheckNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your network and try again.'**
  String get noInternetConnectionCheckNetwork;

  /// No description provided for @noReelsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No reels available'**
  String get noReelsAvailable;

  /// No description provided for @checkBackLater.
  ///
  /// In en, this message translates to:
  /// **'Check back later for new content!'**
  String get checkBackLater;

  /// No description provided for @reportInappropriate.
  ///
  /// In en, this message translates to:
  /// **'Report Inappropriate'**
  String get reportInappropriate;

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String hoursAgo(int hours);

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String minutesAgo(int minutes);

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @reelBy.
  ///
  /// In en, this message translates to:
  /// **'Reel by {name}'**
  String reelBy(String name);

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotifications;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get pleaseWait;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// No description provided for @videoContent.
  ///
  /// In en, this message translates to:
  /// **'Video Content'**
  String get videoContent;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @goals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goals;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @trackProgressWithPhotos.
  ///
  /// In en, this message translates to:
  /// **'Track progress with photos'**
  String get trackProgressWithPhotos;

  /// No description provided for @viewYourProgress.
  ///
  /// In en, this message translates to:
  /// **'View your progress'**
  String get viewYourProgress;

  /// No description provided for @like.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get like;

  /// No description provided for @comment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get comment;

  /// No description provided for @follow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsAndConditions;

  /// No description provided for @termsDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsDialogTitle;

  /// No description provided for @scrollToReadTerms.
  ///
  /// In en, this message translates to:
  /// **'Please scroll down to read the complete terms'**
  String get scrollToReadTerms;

  /// No description provided for @readCompleteTerms.
  ///
  /// In en, this message translates to:
  /// **'You have read the complete terms'**
  String get readCompleteTerms;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @termsServiceTitle.
  ///
  /// In en, this message translates to:
  /// **'TERMS OF SERVICE & COMMUNITY GUIDELINES'**
  String get termsServiceTitle;

  /// No description provided for @termsIntro.
  ///
  /// In en, this message translates to:
  /// **'By using Mr Muscle, you agree to the following terms:'**
  String get termsIntro;

  /// No description provided for @zeroTolerancePolicy.
  ///
  /// In en, this message translates to:
  /// **'1. ZERO TOLERANCE POLICY'**
  String get zeroTolerancePolicy;

  /// No description provided for @zeroToleranceDesc.
  ///
  /// In en, this message translates to:
  /// **'We have ZERO TOLERANCE for objectionable, harmful, or abusive content. Any content that violates our community guidelines will be immediately removed and users will be permanently banned.'**
  String get zeroToleranceDesc;

  /// No description provided for @prohibitedContent.
  ///
  /// In en, this message translates to:
  /// **'2. PROHIBITED CONTENT'**
  String get prohibitedContent;

  /// No description provided for @prohibitedContentDesc.
  ///
  /// In en, this message translates to:
  /// **'You may NOT post content that includes:'**
  String get prohibitedContentDesc;

  /// No description provided for @prohibitedNudity.
  ///
  /// In en, this message translates to:
  /// **'• Nudity, sexual content, or explicit material'**
  String get prohibitedNudity;

  /// No description provided for @prohibitedViolence.
  ///
  /// In en, this message translates to:
  /// **'• Violence, threats, or harassment'**
  String get prohibitedViolence;

  /// No description provided for @prohibitedHateSpeech.
  ///
  /// In en, this message translates to:
  /// **'• Hate speech, discrimination, or bullying'**
  String get prohibitedHateSpeech;

  /// No description provided for @prohibitedSpam.
  ///
  /// In en, this message translates to:
  /// **'• Spam, scams, or misleading information'**
  String get prohibitedSpam;

  /// No description provided for @prohibitedCopyright.
  ///
  /// In en, this message translates to:
  /// **'• Copyrighted material without permission'**
  String get prohibitedCopyright;

  /// No description provided for @prohibitedPersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'• Personal information of others'**
  String get prohibitedPersonalInfo;

  /// No description provided for @prohibitedIllegal.
  ///
  /// In en, this message translates to:
  /// **'• Content promoting illegal activities'**
  String get prohibitedIllegal;

  /// No description provided for @prohibitedMinors.
  ///
  /// In en, this message translates to:
  /// **'• Any content that could harm minors'**
  String get prohibitedMinors;

  /// No description provided for @contentModeration.
  ///
  /// In en, this message translates to:
  /// **'3. CONTENT MODERATION'**
  String get contentModeration;

  /// No description provided for @contentModerationDesc.
  ///
  /// In en, this message translates to:
  /// **'• All content is subject to review and filtering\n• We use automated systems and human moderators\n• Content may be removed without prior notice\n• We reserve the right to moderate all user-generated content\n• All content is filtered for inappropriate material before display\n• Users can report inappropriate content using the report button\n• All reports are reviewed and acted upon within 24 hours\n• Users can block other users who engage in inappropriate behavior\n• Repeated violations may result in account suspension'**
  String get contentModerationDesc;

  /// No description provided for @reportingSystem.
  ///
  /// In en, this message translates to:
  /// **'4. REPORTING SYSTEM'**
  String get reportingSystem;

  /// No description provided for @reportingSystemDesc.
  ///
  /// In en, this message translates to:
  /// **'• Users can report objectionable content using the report button\n• All reports are reviewed within 24 hours\n• We take immediate action on verified violations\n• Reporters\' identities are kept confidential'**
  String get reportingSystemDesc;

  /// No description provided for @userSafety.
  ///
  /// In en, this message translates to:
  /// **'5. USER SAFETY'**
  String get userSafety;

  /// No description provided for @userSafetyDesc.
  ///
  /// In en, this message translates to:
  /// **'• You can block users who engage in abusive behavior\n• Blocked users cannot interact with you\n• We provide tools to protect your safety and privacy'**
  String get userSafetyDesc;

  /// No description provided for @consequencesViolations.
  ///
  /// In en, this message translates to:
  /// **'6. CONSEQUENCES OF VIOLATIONS'**
  String get consequencesViolations;

  /// No description provided for @consequencesViolationsDesc.
  ///
  /// In en, this message translates to:
  /// **'• First offense: Content removed + warning\n• Second offense: 7-day account suspension\n• Third offense: Permanent ban\n• Severe violations: Immediate permanent ban'**
  String get consequencesViolationsDesc;

  /// No description provided for @yourResponsibilities.
  ///
  /// In en, this message translates to:
  /// **'7. YOUR RESPONSIBILITIES'**
  String get yourResponsibilities;

  /// No description provided for @yourResponsibilitiesDesc.
  ///
  /// In en, this message translates to:
  /// **'• You are responsible for all content you post\n• You must respect other users and community guidelines\n• You must report any violations you encounter\n• You must not attempt to circumvent our safety measures'**
  String get yourResponsibilitiesDesc;

  /// No description provided for @ourCommitment.
  ///
  /// In en, this message translates to:
  /// **'8. OUR COMMITMENT'**
  String get ourCommitment;

  /// No description provided for @ourCommitmentDesc.
  ///
  /// In en, this message translates to:
  /// **'• We review all reports within 24 hours\n• We remove objectionable content immediately\n• We ban users who violate our policies\n• We continuously improve our safety systems'**
  String get ourCommitmentDesc;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'9. PRIVACY'**
  String get privacy;

  /// No description provided for @privacyDesc.
  ///
  /// In en, this message translates to:
  /// **'• We collect and use your data as described in our Privacy Policy\n• We may share data with law enforcement when required\n• We protect your personal information'**
  String get privacyDesc;

  /// No description provided for @termination.
  ///
  /// In en, this message translates to:
  /// **'10. TERMINATION'**
  String get termination;

  /// No description provided for @terminationDesc.
  ///
  /// In en, this message translates to:
  /// **'We may terminate your account at any time for violations of these terms.'**
  String get terminationDesc;

  /// No description provided for @termsAcknowledgment.
  ///
  /// In en, this message translates to:
  /// **'By continuing to use this app, you acknowledge that you have read, understood, and agree to these terms. Failure to comply will result in immediate account termination.'**
  String get termsAcknowledgment;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: [Current Date]'**
  String get lastUpdated;

  /// No description provided for @termsContact.
  ///
  /// In en, this message translates to:
  /// **'Contact: support@musclecrm.com for questions or concerns.'**
  String get termsContact;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @scanQR.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scanQR;

  /// No description provided for @gymAttendance.
  ///
  /// In en, this message translates to:
  /// **'Gym Attendance'**
  String get gymAttendance;

  /// No description provided for @checkIn.
  ///
  /// In en, this message translates to:
  /// **'Check In'**
  String get checkIn;

  /// No description provided for @checkOut.
  ///
  /// In en, this message translates to:
  /// **'Check Out'**
  String get checkOut;

  /// No description provided for @diet.
  ///
  /// In en, this message translates to:
  /// **'Diet'**
  String get diet;

  /// No description provided for @dietPlan.
  ///
  /// In en, this message translates to:
  /// **'Diet Plan'**
  String get dietPlan;

  /// No description provided for @mealPlan.
  ///
  /// In en, this message translates to:
  /// **'Meal Plan'**
  String get mealPlan;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @member.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get member;

  /// No description provided for @fees.
  ///
  /// In en, this message translates to:
  /// **'Fees'**
  String get fees;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @keyIngredients.
  ///
  /// In en, this message translates to:
  /// **'Key Ingredients'**
  String get keyIngredients;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @cook.
  ///
  /// In en, this message translates to:
  /// **'Cook'**
  String get cook;

  /// No description provided for @noProfileData.
  ///
  /// In en, this message translates to:
  /// **'No Profile Data'**
  String get noProfileData;

  /// No description provided for @unableToLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Unable to load your profile information.'**
  String get unableToLoadProfile;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @areYouSureSignOut.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get areYouSureSignOut;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account?'**
  String get deleteAccountConfirm;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @importantInformation.
  ///
  /// In en, this message translates to:
  /// **'Important Information:'**
  String get importantInformation;

  /// No description provided for @deleteAccountInfo.
  ///
  /// In en, this message translates to:
  /// **'• You will be redirected to our external website\n• Account deletion can take up to 24 hours\n• This action cannot be undone\n• All your data will be permanently removed'**
  String get deleteAccountInfo;

  /// No description provided for @continueToDelete.
  ///
  /// In en, this message translates to:
  /// **'Continue to Delete'**
  String get continueToDelete;

  /// No description provided for @profileEditingSoon.
  ///
  /// In en, this message translates to:
  /// **'Profile editing feature will be available soon.'**
  String get profileEditingSoon;

  /// No description provided for @membershipDetails.
  ///
  /// In en, this message translates to:
  /// **'Membership Details'**
  String get membershipDetails;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @biometricLogin.
  ///
  /// In en, this message translates to:
  /// **'Biometric Login'**
  String get biometricLogin;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate App'**
  String get rateApp;

  /// No description provided for @loggedOutSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Logged out successfully'**
  String get loggedOutSuccessfully;

  /// No description provided for @signOutFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign out failed'**
  String get signOutFailed;

  /// No description provided for @aboutFitTracker.
  ///
  /// In en, this message translates to:
  /// **'About FitTracker'**
  String get aboutFitTracker;

  /// No description provided for @fitnessCompanion.
  ///
  /// In en, this message translates to:
  /// **'Your personal fitness companion for a healthier lifestyle.'**
  String get fitnessCompanion;

  /// No description provided for @themeChangedTo.
  ///
  /// In en, this message translates to:
  /// **'Theme changed to'**
  String get themeChangedTo;

  /// No description provided for @languageChangedTo.
  ///
  /// In en, this message translates to:
  /// **'Language changed to'**
  String get languageChangedTo;

  /// No description provided for @bmiLabel.
  ///
  /// In en, this message translates to:
  /// **'BMI'**
  String get bmiLabel;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @followSystemSettings.
  ///
  /// In en, this message translates to:
  /// **'Follow system settings'**
  String get followSystemSettings;

  /// No description provided for @lightModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Light theme'**
  String get lightModeDesc;

  /// No description provided for @darkModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkModeLabel;

  /// No description provided for @darkModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Dark theme'**
  String get darkModeDesc;

  /// No description provided for @healthAwareness.
  ///
  /// In en, this message translates to:
  /// **'Health Awareness'**
  String get healthAwareness;

  /// No description provided for @learnAboutBadHabits.
  ///
  /// In en, this message translates to:
  /// **'Learn about the hidden costs of bad habits'**
  String get learnAboutBadHabits;

  /// No description provided for @searchHealthTopics.
  ///
  /// In en, this message translates to:
  /// **'Search health topics...'**
  String get searchHealthTopics;

  /// No description provided for @allArticles.
  ///
  /// In en, this message translates to:
  /// **'All Articles'**
  String get allArticles;

  /// No description provided for @criticalAlerts.
  ///
  /// In en, this message translates to:
  /// **'Critical Alerts'**
  String get criticalAlerts;

  /// No description provided for @costAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Cost Analysis'**
  String get costAnalysis;

  /// No description provided for @noArticlesFound.
  ///
  /// In en, this message translates to:
  /// **'No articles found for your search.'**
  String get noArticlesFound;

  /// No description provided for @noCriticalAlerts.
  ///
  /// In en, this message translates to:
  /// **'No critical health alerts at this time.'**
  String get noCriticalAlerts;

  /// No description provided for @potentialLifetimeSavings.
  ///
  /// In en, this message translates to:
  /// **'Potential Lifetime Savings'**
  String get potentialLifetimeSavings;

  /// No description provided for @byAvoidingBadHabits.
  ///
  /// In en, this message translates to:
  /// **'By avoiding all bad habits mentioned in our articles'**
  String get byAvoidingBadHabits;

  /// No description provided for @costBreakdownByCategory.
  ///
  /// In en, this message translates to:
  /// **'Cost Breakdown by Category'**
  String get costBreakdownByCategory;

  /// No description provided for @costDataNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Cost data not available'**
  String get costDataNotAvailable;

  /// No description provided for @errorLoadingContent.
  ///
  /// In en, this message translates to:
  /// **'Error loading content'**
  String get errorLoadingContent;

  /// No description provided for @writtenBy.
  ///
  /// In en, this message translates to:
  /// **'Written by'**
  String get writtenBy;

  /// No description provided for @keyTakeaways.
  ///
  /// In en, this message translates to:
  /// **'Key Takeaways'**
  String get keyTakeaways;

  /// No description provided for @minRead.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min read'**
  String minRead(int minutes);

  /// No description provided for @min.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String min(int minutes);

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get allCategories;

  /// No description provided for @loadingArticles.
  ///
  /// In en, this message translates to:
  /// **'Loading articles...'**
  String get loadingArticles;

  /// No description provided for @tapToRetry.
  ///
  /// In en, this message translates to:
  /// **'Tap to retry'**
  String get tapToRetry;

  /// No description provided for @categoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryAll;

  /// No description provided for @categorySmoking.
  ///
  /// In en, this message translates to:
  /// **'Smoking'**
  String get categorySmoking;

  /// No description provided for @categoryAlcohol.
  ///
  /// In en, this message translates to:
  /// **'Alcohol'**
  String get categoryAlcohol;

  /// No description provided for @categoryPoorDiet.
  ///
  /// In en, this message translates to:
  /// **'Poor Diet'**
  String get categoryPoorDiet;

  /// No description provided for @categorySedentaryLifestyle.
  ///
  /// In en, this message translates to:
  /// **'Sedentary Lifestyle'**
  String get categorySedentaryLifestyle;

  /// No description provided for @categorySleepDisorders.
  ///
  /// In en, this message translates to:
  /// **'Sleep Disorders'**
  String get categorySleepDisorders;

  /// No description provided for @categoryStress.
  ///
  /// In en, this message translates to:
  /// **'Stress'**
  String get categoryStress;

  /// No description provided for @categoryMentalHealth.
  ///
  /// In en, this message translates to:
  /// **'Mental Health'**
  String get categoryMentalHealth;

  /// No description provided for @started.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get started;

  /// No description provided for @weeksCount.
  ///
  /// In en, this message translates to:
  /// **'{count} weeks'**
  String weeksCount(int count);

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @selectWeek.
  ///
  /// In en, this message translates to:
  /// **'Select Week'**
  String get selectWeek;

  /// No description provided for @weekNumber.
  ///
  /// In en, this message translates to:
  /// **'Week {number}'**
  String weekNumber(int number);

  /// No description provided for @weekDays.
  ///
  /// In en, this message translates to:
  /// **'Week {week} - Days'**
  String weekDays(int week);

  /// No description provided for @dayNumber.
  ///
  /// In en, this message translates to:
  /// **'Day {number}'**
  String dayNumber(int number);

  /// No description provided for @exercise.
  ///
  /// In en, this message translates to:
  /// **'exercise'**
  String get exercise;

  /// No description provided for @exerciseCount.
  ///
  /// In en, this message translates to:
  /// **'{count} exercise'**
  String exerciseCount(int count);

  /// No description provided for @exercisesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} exercises'**
  String exercisesCount(int count);

  /// No description provided for @noWeeksAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Weeks Available'**
  String get noWeeksAvailable;

  /// No description provided for @noWeeksConfigured.
  ///
  /// In en, this message translates to:
  /// **'This workout plan doesn\'t have any weeks configured yet.'**
  String get noWeeksConfigured;

  /// No description provided for @noWorkoutDays.
  ///
  /// In en, this message translates to:
  /// **'No workout days available for this week.'**
  String get noWorkoutDays;

  /// No description provided for @myCart.
  ///
  /// In en, this message translates to:
  /// **'My Cart'**
  String get myCart;

  /// No description provided for @removedFromCart.
  ///
  /// In en, this message translates to:
  /// **'Removed {itemName} from cart'**
  String removedFromCart(String itemName);

  /// No description provided for @yourCartIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get yourCartIsEmpty;

  /// No description provided for @addProductsToGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Add products to get started'**
  String get addProductsToGetStarted;

  /// No description provided for @startShopping.
  ///
  /// In en, this message translates to:
  /// **'Start Shopping'**
  String get startShopping;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @proceedToCheckout.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Checkout'**
  String get proceedToCheckout;

  /// No description provided for @errorLoadingCart.
  ///
  /// In en, this message translates to:
  /// **'Error loading cart'**
  String get errorLoadingCart;

  /// No description provided for @redirectedToWallet.
  ///
  /// In en, this message translates to:
  /// **'Redirected to {walletName} wallet'**
  String redirectedToWallet(String walletName);

  /// No description provided for @paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment failed. Please try again.'**
  String get paymentFailed;

  /// No description provided for @failedToInitiateCheckout.
  ///
  /// In en, this message translates to:
  /// **'Failed to initiate cart checkout. Please try again.'**
  String get failedToInitiateCheckout;

  /// No description provided for @cartCheckoutError.
  ///
  /// In en, this message translates to:
  /// **'Cart checkout error: {error}'**
  String cartCheckoutError(String error);

  /// No description provided for @scanQr.
  ///
  /// In en, this message translates to:
  /// **'Scan QR'**
  String get scanQr;

  /// No description provided for @attendanceAlreadyMarked.
  ///
  /// In en, this message translates to:
  /// **'Attendance already marked for today'**
  String get attendanceAlreadyMarked;

  /// No description provided for @attendanceMarkedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Attendance marked successfully'**
  String get attendanceMarkedSuccessfully;

  /// No description provided for @failedToMarkAttendance.
  ///
  /// In en, this message translates to:
  /// **'Failed to mark attendance'**
  String get failedToMarkAttendance;

  /// No description provided for @pointCameraAtQr.
  ///
  /// In en, this message translates to:
  /// **'Point your camera at the QR code to mark attendance'**
  String get pointCameraAtQr;

  /// No description provided for @foodAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Food added successfully!'**
  String get foodAddedSuccessfully;

  /// No description provided for @failedToAddFood.
  ///
  /// In en, this message translates to:
  /// **'Failed to add food: {error}'**
  String failedToAddFood(String error);

  /// No description provided for @mealDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Meal deleted successfully!'**
  String get mealDeletedSuccessfully;

  /// No description provided for @failedToDeleteMeal.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete meal: {error}'**
  String failedToDeleteMeal(String error);

  /// No description provided for @noMealsAddedYet.
  ///
  /// In en, this message translates to:
  /// **'No meals added yet'**
  String get noMealsAddedYet;

  /// No description provided for @tapToAddFirstMeal.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to add your first meal!'**
  String get tapToAddFirstMeal;

  /// No description provided for @todaysMeals.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Meals'**
  String get todaysMeals;

  /// No description provided for @mealUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Meal updated successfully!'**
  String get mealUpdatedSuccessfully;

  /// No description provided for @failedToUpdateMeal.
  ///
  /// In en, this message translates to:
  /// **'Failed to update meal: {error}'**
  String failedToUpdateMeal(String error);

  /// No description provided for @goalsUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Goals updated successfully!'**
  String get goalsUpdatedSuccessfully;

  /// No description provided for @jan.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get jan;

  /// No description provided for @feb.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get feb;

  /// No description provided for @mar.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get mar;

  /// No description provided for @apr.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get apr;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @jun.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get jun;

  /// No description provided for @jul.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get jul;

  /// No description provided for @aug.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get aug;

  /// No description provided for @sep.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get sep;

  /// No description provided for @oct.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get oct;

  /// No description provided for @nov.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get nov;

  /// No description provided for @dec.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get dec;

  /// No description provided for @calorieGoal.
  ///
  /// In en, this message translates to:
  /// **'Calorie Goal'**
  String get calorieGoal;

  /// No description provided for @remainingOnly.
  ///
  /// In en, this message translates to:
  /// **'Remaining only'**
  String get remainingOnly;

  /// No description provided for @goalExceededBy.
  ///
  /// In en, this message translates to:
  /// **'Goal exceeded by'**
  String get goalExceededBy;

  /// No description provided for @cal.
  ///
  /// In en, this message translates to:
  /// **'Cal'**
  String get cal;

  /// No description provided for @consumed.
  ///
  /// In en, this message translates to:
  /// **'Consumed'**
  String get consumed;

  /// No description provided for @grams.
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get grams;

  /// No description provided for @sevenDayHistory.
  ///
  /// In en, this message translates to:
  /// **'7-Day History'**
  String get sevenDayHistory;
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
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
