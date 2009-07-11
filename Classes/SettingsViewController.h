//
//  SettingsViewController.h
//  KeynoteBingo
//
//  Created by Nicklas Ansman on 30-6-2009.
//  Copyright 2009 Nicklas Ansman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventManager.h"
#import "TransitionManager.h"
#import "GameViewController.h"

@protocol SettingsViewControllerDelegate <NSObject>

- (void) returnToGame;
- (void) loadEvents;
- (void) cancelUpdate;
- (int) eventsID;
- (int) lastUpdate;

@end

@interface SettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, EventManagerSettingsDelegate, GameViewControllerSettingsDelegate, UIPickerViewDelegate, UIPickerViewDataSource> {
	BOOL sound;
	BOOL vibrate;
	BOOL automaticUpdate;
	id<SettingsViewControllerDelegate> delegate;
	
	@private
	UIView *view1;
	UIView *view2;
	UITableView *tableView;
	int updateInterval;
	int whichView;
	UILabel *currentValueLabel;
	UISwitch *soundSwitch;
	UISwitch *vibrateSwitch;
	UISwitch *updateSwitch;
	UIPickerView *updatePicker;
	BOOL isIphone;
}

@property (nonatomic, readonly, getter=shouldUpdate) BOOL automaticUpdate;
@property (nonatomic, readonly, getter=shouldVibrate) BOOL vibrate;
@property (nonatomic, readonly, getter=shouldPlaySound) BOOL sound;

@property (nonatomic, readonly) UIView *view1;
@property (nonatomic, readonly) UIView *view2;

@property (nonatomic, assign) id<SettingsViewControllerDelegate> delegate;

- (UIView *) getView;
- (void) updateView;
- (id) initWithDelegate:(id<SettingsViewControllerDelegate>)delegate;

+ (NSString *) getIntervalString:(int)row;
+ (NSString *) getAgeString:(int)timestamp;

@end
