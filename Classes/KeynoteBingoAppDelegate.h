//
//  KeynoteBingoAppDelegate.h
//  KeynoteBingo
//
//  Created by Nicklas Ansman on 14-6-2009.
//  Copyright Nicklas Ansman 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "GameViewController.h"
#import "GameBoardViewController.h"
#import "MenuViewController.h"
#import "SettingsViewController.h"
#import "LoadingViewController.h"
#import "EventManager.h"
#import "TransitionManager.h"

@interface KeynoteBingoAppDelegate : NSObject <UIApplicationDelegate, EventManagerDelegate, GameViewControllerDelegate, GameBoardViewControllerDelegate, MenuViewControllerDelegate, SettingsViewControllerDelegate, LoadingViewControllerDelegate, TransitionManagerDelegate> {
    
	@private
	UIWindow *window;
	GameViewController *gameViewController;
	MenuViewController *menuViewController;
	SettingsViewController *settingsViewController;
	LoadingViewController *loadingViewController;
	GameBoardViewController *gameBoardViewController;
	EventManager *eventManager;
	TransitionManager *transitionManager;
}

@property (nonatomic, readonly) EventManager *eventManager;

@end

