//
//  KeynoteBingoAppDelegate.m
//  KeynoteBingo
//
//  Created by Nicklas Ansman on 14-6-2009.
//  Copyright Nicklas Ansman 2009. All rights reserved.
//

#import "KeynoteBingoAppDelegate.h"

@interface KeynoteBingoAppDelegate (PrivateMethods)

- (void) loadSettings;
- (void) saveWhichView;
- (void) performTransition:(UIView *)oldView newView:(UIView *)newView transitionType:(TransitionType)transitionType;

@end


@implementation KeynoteBingoAppDelegate

int MENU_VIEW = 0;
int GAME_VIEW = 1;
int SETTINGS_VIEW = 2;

- (void)applicationDidFinishLaunching:(UIApplication *) application {
	window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
	window.backgroundColor = [UIColor clearColor];
	
	loadingViewController = [[LoadingViewController alloc] init];
	loadingViewController.delegate = self;
	[window addSubview:loadingViewController.view];
	
    [window makeKeyAndVisible];
	
	settingsViewController = [[SettingsViewController alloc] initWithDelegate:self];

	eventManager = [[[EventManager alloc] init] autorelease];
	eventManager.settingsDelegate = settingsViewController;
	eventManager.delegate = self;
	
	transitionManager = [[TransitionManager alloc] init];
	transitionManager.containerView = window;
	transitionManager.delegate = self;
	
	menuViewController = [[MenuViewController alloc] init];
	menuViewController.delegate = self;
	
	gameViewController = [[GameViewController alloc] init];
	gameViewController.delegate = self;
	gameViewController.settingsDelegate = settingsViewController;
	
	gameBoardViewController = [[gameViewController gameBoard] retain];
	gameBoardViewController.delegate = self;
	gameBoardViewController.eventManager = eventManager;

	[self loadEvents];
}

- (void) performTransition:(UIView *)oldView newView:(UIView *)newView transitionType:(TransitionType)transitionType {
	transitionManager.oldView = oldView;
	transitionManager.newView = newView;
	transitionManager.transitionType = transitionType;
	
	switch(transitionType) {
		case TransitionTypeReveal:
			transitionManager.duration = 0.60;
			break;
			
		case TransitionTypeMoveOver:
			transitionManager.duration = 0.60;
			break;
			
		case TransitionTypeFlipRight:
			transitionManager.duration = 1.00;
			break;
			
		case TransitionTypeFlipLeft:
			transitionManager.duration = 1.00;
			break;
			
		case TransitionTypePushLeft:
			transitionManager.duration = 0.60;
			break;
			
		case TransitionTypePushRight:
			transitionManager.duration = 0.60;
			break;
			
	}
	
	[transitionManager startTransition];
}

- (void) transitionDidStop:(TransitionManager *)whichTransitionManager {
	if(whichTransitionManager.newView.tag == menuViewController.view.tag)
		[menuViewController transitionDidStop];
}

- (void) cancelUpdate {
	[eventManager cancelUpdate];
}

- (void) loadEvents {
	[eventManager loadEvents];
}

- (void)loadingComplete {
	if([settingsViewController.view1 superview])
		[settingsViewController updateView];
	[self loadSettings];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	if(![loadingViewController.view superview]) {
		[gameViewController saveSettings];
		[self saveWhichView];
	}
}

- (void) loadSettings {
	if(loadingViewController.view.superview) {
		int activeView = [[NSUserDefaults standardUserDefaults] integerForKey:@"activeView"];
		UIView *newView;
		if(activeView == GAME_VIEW)
			newView = gameViewController.view;
		else if(activeView == SETTINGS_VIEW)
			newView = [settingsViewController getView];
		else
			newView = menuViewController.view;
		
		[self performTransition:loadingViewController.view newView:newView transitionType:TransitionTypeReveal];
	}
}

- (void) saveWhichView {
	int activeView;
	
	if([[settingsViewController getView] superview])
		activeView = SETTINGS_VIEW;
	else if([gameViewController.view superview])
		activeView = GAME_VIEW;
	else
		activeView = MENU_VIEW;
	
	[[NSUserDefaults standardUserDefaults] setInteger:activeView forKey:@"activeView"];
}

- (void) returnToGame {
	if ([menuViewController.view superview])
		[self performTransition:menuViewController.view newView:gameViewController.view transitionType:TransitionTypeReveal];
	else if([[settingsViewController getView] superview])
		[self performTransition:[settingsViewController getView] newView:gameViewController.view transitionType:TransitionTypeFlipRight];
}

- (void) showSettings {
	if([gameViewController.view superview])
		[self performTransition:gameViewController.view newView:[settingsViewController getView] transitionType:TransitionTypeFlipLeft];
}

- (void) pickNewGame {
	if ([gameViewController.view superview])
		[self performTransition:gameViewController.view newView:menuViewController.view transitionType:TransitionTypeMoveOver];
}

- (void) newGame:(NSNumber *)boardNumber {			
	[gameViewController newGame:boardNumber];
	[self performTransition:menuViewController.view newView:gameViewController.view transitionType:TransitionTypeReveal];
}

- (int) eventsID {
	return [eventManager eventsID];
}

- (int) lastUpdate {
	return [eventManager lastUpdate];
}

- (void) setLoadingText:(NSString *)loadingText {
	[loadingViewController setLoadingText:loadingText];
}

- (void) updateStarted {
	[loadingViewController updateStarted];
}

- (void) dealloc {
	[gameViewController release];
	[menuViewController release];
	[settingsViewController release];
	[loadingViewController release];
    [window release];
    [super dealloc];
}

@end
