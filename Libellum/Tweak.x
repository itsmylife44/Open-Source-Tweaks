/*
 * Tweak.x
 * Libellum
 *
 * Created by Zachary Thomas Paul <LacertosusThemes@gmail.com> on 7/16/2019.
 * Copyright © 2021 LacertosusDeus <LacertosusThemes@gmail.com>. All rights reserved.
 */
#import "LibellumManager.h"
#import "LibellumClasses.h"
#define LD_DEBUG NO

  /*
   * Variables
   */
  static NSUserDefaults *preferences;
  static id scrollView;
#pragma mark - iOS 13/14/15/16 Hooks

    /*
     * Add Libellum to the Lockscreen
     * Axon - Nepeta & BawApple https://github.com/Baw-Appie/Axon/blob/master/Tweak/Tweak.xm
     */
%group iOS13Plus
%hook CSNotificationAdjunctListViewController
  -(void)viewDidLoad {
    %orig;

    UIStackView *customStackView;

    if ([self respondsToSelector:@selector(stackView)]) {
        // iOS 14, where stackView is a property
        customStackView = [self stackView];
    } else {
        // iOS 16, where stackView doesn't exist, so we create and configure a new one
        customStackView = [[UIStackView alloc] init];
        customStackView.axis = UILayoutConstraintAxisVertical;
        customStackView.distribution = UIStackViewDistributionFill;
        customStackView.alignment = UIStackViewAlignmentFill;
        customStackView.translatesAutoresizingMaskIntoConstraints = NO;

        [self.view addSubview:customStackView];

        // Define constraints for customStackView
        CGFloat padding = 10; // padding
        [NSLayoutConstraint activateConstraints:@[
            [customStackView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:padding],
            [customStackView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-padding],
            [customStackView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:padding],
            [customStackView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-padding],
        ]];
    }

    [[LibellumManager sharedManager] createPages];
    [customStackView insertArrangedSubview:[LibellumManager sharedManager].pageController.view atIndex:0];

    [((UIScrollView *)scrollView).panGestureRecognizer requireGestureRecognizerToFail:[LibellumManager sharedManager].swipeGesture];

    if([preferences boolForKey:@"isHidden"] && [preferences boolForKey:@"hideGesture"]) {
      [[LibellumManager sharedManager] toggleLibellum:nil];
    }
  }

  -(void)adjunctListModel:(id)arg1 didAddItem:(id)arg2 {
    %orig;

    UIStackView *customStackView;

    if ([self respondsToSelector:@selector(stackView)]) {
        // iOS 14, where stackView is a property
        customStackView = [self stackView];
    } else {
        // iOS 16, where stackView doesn't exist, so we create and configure a new one
        customStackView = [[UIStackView alloc] init];
        customStackView.axis = UILayoutConstraintAxisVertical;
        customStackView.distribution = UIStackViewDistributionFill;
        customStackView.alignment = UIStackViewAlignmentFill;
        customStackView.translatesAutoresizingMaskIntoConstraints = NO;

        [self.view addSubview:customStackView];

        // Define constraints for customStackView
        [NSLayoutConstraint activateConstraints:@[
            [customStackView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
            [customStackView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
            [customStackView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
            [customStackView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        ]];
    }

    if([preferences integerForKey:@"notePosition"] == 2) {
      [customStackView insertArrangedSubview:[LibellumManager sharedManager].pageController.view atIndex:[customStackView.arrangedSubviews count]];
    }
  }

  -(BOOL)isPresentingContent {
    return (![LibellumManager sharedManager].pageController.view.hidden) ?: %orig;
  }
%end

  /*
   * Add tap gesture to lockscreen
   */
%hook CSScrollView
  -(instancetype)initWithFrame:(CGRect)arg1 {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:[LibellumManager sharedManager] action:@selector(toggleLibellum:)];
    tapGesture.enabled = [preferences boolForKey:@"useTapGesture"];
    tapGesture.numberOfTapsRequired = 3;
    [LibellumManager sharedManager].tapGesture = tapGesture;
    [self addGestureRecognizer:tapGesture];

    return scrollView = %orig;
  }
%end

  /*
   * Hide buttons when in portrait
   */
%hook CSQuickActionsViewController
  -(BOOL)isPortrait {
    if([preferences boolForKey:@"hideQuickActions"]) {
      if(%orig) {
        self.view.hidden = YES;
      } else {
        self.view.hidden = NO;
      }
    }

    return %orig;
  }
%end

  /*
   * Send interface updates to Libellum
   */
%hook UIUserInterfaceStyleArbiter
  -(void)userInterfaceStyleModeDidChange:(UISUserInterfaceStyleMode *)arg1 {
    %orig;

    if([[preferences objectForKey:@"blurStyle"] isEqualToString:@"adaptive"]) {
      [[LibellumManager sharedManager] notifyViewControllersOfInterfaceChange:arg1.modeValue];
    }
  }
%end
%end

#pragma mark - iOS 12 Hooks

  /*
   * Add Libellum to the Lockscreen
   * Axon - Nepeta & BawApple https://github.com/Baw-Appie/Axon/blob/master/Tweak/Tweak.xm
   */
%group iOS12
%hook SBDashBoardNotificationAdjunctListViewController
  -(void)viewDidLoad {
    %orig;

    [[LibellumManager sharedManager] createPages];
    [self.stackView insertArrangedSubview:[LibellumManager sharedManager].pageController.view atIndex:0];

    [((UIScrollView *)scrollView).panGestureRecognizer requireGestureRecognizerToFail:[LibellumManager sharedManager].swipeGesture];

    if([preferences boolForKey:@"isHidden"] && [preferences boolForKey:@"hideGesture"]) {
      [[LibellumManager sharedManager] toggleLibellum:nil];
    }
  }

  -(void)adjunctListModel:(id)arg1 didAddItem:(id)arg2 {
    %orig;

    if([preferences integerForKey:@"notePosition"] == 2) {
      [self.stackView insertArrangedSubview:[LibellumManager sharedManager].pageController.view atIndex:[self.stackView.arrangedSubviews count]];
    }
  }

  -(BOOL)isPresentingContent {
    return (![LibellumManager sharedManager].pageController.view.hidden) ?: %orig;
  }
%end

  /*
   * Add tap gesture to lockscreen
   */
%hook SBPagedScrollView
  -(instancetype)initWithFrame:(CGRect)arg1 {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:[LibellumManager sharedManager] action:@selector(toggleLibellum:)];
    tapGesture.enabled = [preferences boolForKey:@"useTapGesture"];
    tapGesture.numberOfTapsRequired = 3;
    [LibellumManager sharedManager].tapGesture = tapGesture;
    [self addGestureRecognizer:tapGesture];

    return scrollView = %orig;
  }
%end

  /*
   * Hide buttons when in portrait
   */
%hook SBDashBoardQuickActionsViewController
  -(BOOL)isPortrait {
    if([preferences boolForKey:@"hideQuickActions"]) {
      if(%orig) {
        self.view.hidden = YES;
      } else {
        self.view.hidden = NO;
      }
    }

    return %orig;
  }
%end
%end

#pragma mark - Universal Hooks

  /*
   * Fix sizeToMimic crash by adding property to UIPageViewController subview
   */
%hook _UIPageViewControllerContentView
%property (nonatomic, assign) CGSize sizeToMimic;
%end

  /*
   * Get lock state and pass instance to libellum
   */
%hook SBLockStateAggregator
  -(void)_updateLockState {
    %orig;

    if([preferences boolForKey:@"requireAuthentication"]) {
      [[LibellumManager sharedManager] authenticationStatusFromAggregator:self];
    }
  }
%end

  /*
   * AutoUnlockX compatibility
   */
%hook SparkAutoUnlockX
  -(BOOL)externalBlocksUnlock {
    if([LibellumManager sharedManager] && [preferences boolForKey:@"requireAuthentication"]) {
      return ![LibellumManager sharedManager].pageController.view.hidden;
    }

    return %orig;
  }
%end

  /*
   * Hide "No Older Notifications" label
   */
%hook NCNotificationListSectionRevealHintView
  -(void)_layoutRevealHintTitle {
    %orig;
    self.hidden = [preferences boolForKey:@"hideNoOlderNotifications"];
  }
%end

%ctor {
  preferences = [[NSUserDefaults alloc] initWithSuiteName:@"com.lacertosusrepo.libellumprefs"];
  [preferences registerDefaults:@{
      //Main Preferences
    @"noteSize" : @121,
    @"blurStyle" : @"adaptive",
    @"cornerRadius" : @15,

    @"requireAuthentication" : @NO,
    @"noteBackup" : @NO,

    @"hideGesture" : @NO,

      //Color Options
    @"useKalmTintColor" : @NO,
    @"ignoreAdaptiveColors" : @NO,
    @"customBackgroundColor" : @"#000000",
    @"customTextColor" : @"#FFFFFF",
    @"lockColor" : @"FFFFFF",
    @"customTintColor" : @"#007AFF",

    @"borderColor" : @"#FFFFFF",
    @"borderWidth" : @0,

      //General Options
    @"notePosition" : @1,
    @"textAlignment" : @0,
    @"invertToolBarButtons" : @NO,
    @"enablePageManagement" : @YES,
    @"enableUndoRedo" : @NO,
    @"enableEndlessLines" : @NO,
    @"hideNoOlderNotifications" : @YES,
    @"hideQuickActions" : @NO,
    @"enableAutoUnlockXBlock" : @NO,

      //Gesture Options
    @"feedback" : @YES,
    @"feedbackStyle" : @1520,
    @"useSwipeGesture" : @YES,
    @"useTapGesture" : @YES,
    @"useEdgeGesture" : @YES,

      //Saved Variables
    @"isHidden" : @NO,
  }];

    if([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){13, 0, 0}]) {
      %init(iOS13Plus);
    } else {
      %init(iOS12);
    }
    %init;
}
