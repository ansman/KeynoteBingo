//
//  SettinsViewController.m
//  KeynoteBingo
//
//  Created by Nicklas Ansman on 30-6-2009.
//  Copyright 2009 Nicklas Ansman. All rights reserved.
//

#import "SettingsViewController.h"
#import "KeynoteBingoAppDelegate.h"

@interface SettingsViewController (PrivateMethods)

- (void) toggleSound;
- (void) toggleVibration;
- (void) toggleUpdate;
- (void) goBackInMenu;
- (void) loadSettings;
- (void) loadCustomView;

@end


@implementation SettingsViewController

@synthesize delegate, automaticUpdate, vibrate, sound, view1, view2;

- (id) initWithDelegate:(id<SettingsViewControllerDelegate>)withDelegate{
	if(self = [self init]) {
		isIphone = [[UIDevice currentDevice].model rangeOfString:@"iPhone"].location != NSNotFound;
		self.delegate = withDelegate;
		[self loadCustomView];
		[self loadSettings];
		[tableView reloadData];
	}
	
	return self;
}

- (void) setAutomaticUpdates:(BOOL)newValue {
	BOOL oldValue = automaticUpdate;
	automaticUpdate = newValue;
	updateSwitch.on = newValue;
	[[NSUserDefaults standardUserDefaults] setBool:!automaticUpdate forKey:@"automaticUpdate"];
	if(oldValue != newValue)
		[tableView reloadData];
}

- (int) updateInterval {
	switch (updateInterval) {
		case 1:
			return 86400;
		case 2:
			return 604800;
		case 3:
			return 2592000;
		default:
			return 0;
	}
}

- (void) loadSettings {
	sound = ![[NSUserDefaults standardUserDefaults] boolForKey:@"sound"];
	if(isIphone)
		vibrate = ![[NSUserDefaults standardUserDefaults] boolForKey:@"vibrate"];
	else
		vibrate = NO;
	automaticUpdate = ![[NSUserDefaults standardUserDefaults] boolForKey:@"automaticUpdate"];
	updateInterval = [[NSUserDefaults standardUserDefaults] integerForKey:@"updateInterval"];
	soundSwitch.on = sound;
	vibrateSwitch.on = vibrate;
	updateSwitch.on = automaticUpdate;
	[updatePicker selectRow:updateInterval inComponent:0 animated:NO];
	whichView = [[NSUserDefaults standardUserDefaults] integerForKey:@"whichView"]+1;
	[self updateView];
}

- (UIView *) getView {
	[self updateView];
	if(whichView == 1)
		return view1;
	else
		return view2;
}

- (void) updateView {
	if(whichView == 1) 
		[tableView reloadData];
	else
		currentValueLabel.text = [SettingsViewController getIntervalString:updateInterval];
}

- (void) loadCustomView {
	{ // View 1
		view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 19, 320, 461)];
		view1.backgroundColor = [UIColor groupTableViewBackgroundColor];
		
		UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
		toolbar.barStyle = UIBarStyleDefault;
		
		UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
																	   style:UIBarButtonItemStyleBordered
																	  target:delegate
																	  action:@selector(returnToGame)];
		
		[toolbar setItems:[NSArray arrayWithObjects:backButton, nil]];
		
		[view1 addSubview:toolbar];
		
		[toolbar release];
		[backButton release];
		
		soundSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(208, 9, 0, 0)];
		[soundSwitch addTarget:self action:@selector(toggleSound) forControlEvents:UIControlEventValueChanged];
		
		vibrateSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(208, 9, 0, 0)];
		[vibrateSwitch addTarget:self action:@selector(toggleVibration) forControlEvents:UIControlEventValueChanged];
		
		updateSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(208, 9, 0, 0)];
		[updateSwitch addTarget:self action:@selector(toggleUpdate) forControlEvents:UIControlEventValueChanged];
		
		UILabel *settingsLabel = [[UILabel alloc] initWithFrame:CGRectMake(109, 0, 101, 44)];
		settingsLabel.text = @"Settings";
		settingsLabel.font = [UIFont boldSystemFontOfSize:18];
		settingsLabel.textAlignment = UITextAlignmentCenter;
		settingsLabel.textColor = [UIColor whiteColor];
		settingsLabel.backgroundColor = [UIColor clearColor];
		
		[view1 addSubview:settingsLabel];
		[settingsLabel release];
		
		tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, 320, 400) style:UITableViewStyleGrouped];
		tableView.dataSource = self;
		tableView.delegate = self;
		
		[view1 addSubview:tableView];
		
		[tableView release];
	}
	
	{ // View 2
		view2 = [[UIView alloc] initWithFrame:CGRectMake(0, 19, 320, 461)];
		view2.backgroundColor = [UIColor groupTableViewBackgroundColor];
		
		UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
		toolbar.barStyle = UIBarStyleDefault;
		
		UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
																	   style:UIBarButtonItemStyleBordered
																	  target:self
																	  action:@selector(goBackInMenu)];
		
		[toolbar setItems:[NSArray arrayWithObjects:backButton, nil]];
		
		[view2 addSubview:toolbar];
		
		[toolbar release];
		[backButton release];
		
		updatePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 245, 320, 80)];
		updatePicker.showsSelectionIndicator = YES;
		updatePicker.delegate = self;
		updatePicker.dataSource = self;
		[updatePicker reloadAllComponents];
		
		[view2 addSubview:updatePicker];
		
		UILabel *updateSettingsLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, 0, 150, 44)];
		updateSettingsLabel.text = @"Update Settings";
		updateSettingsLabel.font = [UIFont boldSystemFontOfSize:18];
		updateSettingsLabel.textAlignment = UITextAlignmentCenter;
		updateSettingsLabel.textColor = [UIColor whiteColor];
		updateSettingsLabel.backgroundColor = [UIColor clearColor];
		
		[view2 addSubview:updateSettingsLabel];
		[updateSettingsLabel release];
				
		UILabel *currentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 105, 300, 30)];
		currentLabel.text = @"Current value:";
		currentLabel.font = [UIFont boldSystemFontOfSize:25];
		currentLabel.textColor = [UIColor darkGrayColor];
		currentLabel.backgroundColor = [UIColor clearColor];
		
		[view2 addSubview:currentLabel];
		[currentLabel release];
		
		currentValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 132, 300, 30)];
		currentValueLabel.text = [SettingsViewController getIntervalString:updateInterval];
		currentValueLabel.font = [UIFont systemFontOfSize:20];
		currentValueLabel.textColor = [UIColor darkGrayColor];
		currentValueLabel.backgroundColor = [UIColor clearColor];
		[view2 addSubview:currentValueLabel];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.row == 2 && indexPath.section == 1) {
		if([delegate lastUpdate] != -1) {
			int oldValue1 = updateInterval;
			BOOL oldValue2 = automaticUpdate;
			updateInterval = 0;
			automaticUpdate = YES;
			[delegate loadEvents];
			updateInterval = oldValue1;
			automaticUpdate = oldValue2;
		}
		else 
			[delegate cancelUpdate];
		[self updateView];
	}
	else if(indexPath.row == 4 && indexPath.section == 1) {
		[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"whichView"];
		whichView = 2;
		[self updateView];
		[TransitionManager performTransition:view1.superview
									 oldView:view1
									 newView:view2
							  transitionType:TransitionTypePushLeft
									duration:0.40
									delegate:nil];
	}
	else
		[self updateView];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
	return proposedDestinationIndexPath;
}
				
+ (NSString *)getIntervalString:(int) row {
	switch (row) {
		case 0:
			return @"Each startup";
		case 1:
			return @"Every day";
		case 2:
			return @"Every week";
		case 3:
			return @"Every month";
	}
	
	return nil;
}

- (void) goBackInMenu {
	updateInterval = [updatePicker selectedRowInComponent:0];
	[[NSUserDefaults standardUserDefaults] setInteger:updateInterval forKey:@"updateInterval"];
	[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"whichView"];
	whichView = 1;
	[self updateView];
	[TransitionManager performTransition:view2.superview
								 oldView:view2
								 newView:view1
						  transitionType:TransitionTypePushRight
								duration:0.40
								delegate:nil];
}

- (void) toggleUpdate {
	BOOL oldValue = automaticUpdate;
	automaticUpdate = updateSwitch.on;
	[[NSUserDefaults standardUserDefaults] setBool:!automaticUpdate forKey:@"automaticUpdate"];
	
	if(oldValue != automaticUpdate) {
		if(automaticUpdate)
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:4 inSection:1]] withRowAnimation:UITableViewRowAnimationTop];
		else
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:4 inSection:1]] withRowAnimation:UITableViewRowAnimationTop];
	}
}

+ (NSString *) getAgeString:(int)timestamp {
	if(timestamp == 0)
		return @"Never updated";
	else if(timestamp == -1)
		return @"Updating...";
	
	int currentTimestamp = [EventManager dateInFormat:@"%s"].intValue;
	int difference = currentTimestamp - timestamp;
	NSString *value;
	NSString *size;
		
	if(difference < 60)
		return @"< 1 minute ago";
	
	if(difference < 3600) {
		value = [NSString stringWithFormat:@"%.0f", difference/60.0f];
		size = @"minute";
	}
	else if(difference < 86400) {
		value = [NSString stringWithFormat:@"%.0f", difference/3600.0f];
		size = @"hour";
	}
	else if(difference < 604800) {
		value = [NSString stringWithFormat:@"%.0f", difference/86400.0f];
		size = @"day";
	}
	else if(difference < 2419200) {
		value = [NSString stringWithFormat:@"%.0f", difference/604800.0f];
		size = @"week";
	}	
	else if(difference < 31536000) {
		value = [NSString stringWithFormat:@"%.0f", difference/2419200.0f];
		size = @"month";
	}
	else {
		value = [NSString stringWithFormat:@"%.0f", difference/31536000.0f];
		size = @"year";
	}
		
	return [NSString stringWithFormat:@"%@ %@%@ ago", value, size, value.intValue == 1 ? @"":@"s"];
}

- (void) toggleVibration {
	vibrate = vibrateSwitch.on;
	[[NSUserDefaults standardUserDefaults] setBool:!vibrate forKey:@"vibrate"];
}

- (void) toggleSound {
	sound = soundSwitch.on;
	[[NSUserDefaults standardUserDefaults] setBool:!sound forKey:@"sound"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0)
		return isIphone ? 2 : 1;
	else
		return automaticUpdate ? 5 : 4;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if(section == 0)
		return @"General Settings";
	else
		return @"Update Settings";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if(section != 1)
		return nil;
	
	return [NSString stringWithFormat:@"\nVersion %@\nCopyright © 2009 Nicklas Ansman\nAll rights reserved.", 
			[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
}

- (UITableViewCell *)tableView:(UITableView *)whichTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = nil;
	
	if(indexPath.section == 0) {
		if(indexPath.row == 0) {
			cell = [whichTableView dequeueReusableCellWithIdentifier:@"soundCell"];
			if(!cell) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"soundCell"] autorelease];
				cell.textLabel.text = @"Sound";
				[cell addSubview:soundSwitch];
			}
		}
		else if(indexPath.row == 1) {
			cell = [whichTableView dequeueReusableCellWithIdentifier:@"vibrationCell"];
			if(!cell) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"vibrationCell"] autorelease];
				cell.textLabel.text = @"Vibration";
				[cell addSubview:vibrateSwitch];
			}
		}
		cell.selectionStyle = UITableViewCellSelectionStyleNone;	
	}
	else {
		if(indexPath.row == 0) {
			cell = [whichTableView dequeueReusableCellWithIdentifier:@"lastUpdateCell"];
			if(!cell) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"lastUpdateCell"] autorelease];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				cell.textLabel.text = @"Last update";
			}
			cell.detailTextLabel.text = [SettingsViewController getAgeString:[delegate lastUpdate]];
		}
		else if(indexPath.row == 1) {
			cell = [whichTableView dequeueReusableCellWithIdentifier:@"eventsIDCell"];
			if(!cell) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"eventsIDCell"] autorelease];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				cell.textLabel.text = @"Event bundle ID";
			}
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%i", [delegate eventsID]];
		}
		else if(indexPath.row == 2) {
			cell = [whichTableView dequeueReusableCellWithIdentifier:@"updateNowCell"];
			if(!cell) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"updateNowCell"] autorelease];
				cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			}
			
			if([delegate lastUpdate] != -1)
				cell.textLabel.text = @"Update events now";
			else
				cell.textLabel.text = @"Cancel update";
		}
		else if(indexPath.row == 3) {
			cell = [whichTableView dequeueReusableCellWithIdentifier:@"updateSwitchCell"];
			if(!cell) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"updateSwitchCell"] autorelease];
				cell.textLabel.text = @"Auto update events";
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				[cell addSubview:updateSwitch];
			}
		}
		else if(indexPath.row == 4) {
			cell = [whichTableView dequeueReusableCellWithIdentifier:@"updateIntervalCell"];
			if(!cell) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"updateIntervalCell"] autorelease];
				cell.textLabel.text = @"Update Interval";
				cell.selectionStyle = UITableViewCellSelectionStyleBlue;
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
			cell.detailTextLabel.text = [SettingsViewController getIntervalString:updateInterval];
		}
	}
	
	return cell;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	if(component != 0)
		return nil;
	
	return [SettingsViewController getIntervalString:row];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return 4;
}

- (void)dealloc {
	[currentValueLabel release];
	[view1 release];
	[view2 release];
	[tableView release];
	[soundSwitch release];
	[vibrateSwitch release];
	[updateSwitch release];
	[updatePicker release];
    [super dealloc];
}

@end
