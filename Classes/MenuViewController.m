//
//  MenuViewController.m
//  KeynoteBingo
//
//  Created by Nicklas Ansman on 14-6-2009.
//  Copyright 2009 Nicklas Ansman. All rights reserved.
//

#import "MenuViewController.h"

@interface MenuViewController (PrivateMethods)

- (void) closeKeyboard;
- (void) randomNumber;
- (void) numberChoosen;
- (void) returnToGame;

@end

@implementation MenuViewController

@synthesize delegate;

- (void) viewWillAppear: (BOOL) animated {
	cancelButton.enabled = [delegate gameHasStarted];
	errorLabel.text = @"";
}

- (void) loadView {
	self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 19, 320, 461)];
	self.view.tag = 42;
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
	
	UIToolbar *navBar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
	
	[cancelButton release];
	cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
														style:UIBarButtonItemStyleBordered
														target:self
														action:@selector(returnToGame)];
	
	navBar.items = [NSArray arrayWithObjects:cancelButton, nil];
	
	[self.view addSubview:navBar];
	
	UILabel *newGameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(109, 0, 101, 44)] autorelease];
	newGameLabel.text = @"New Game";
	newGameLabel.font = [UIFont boldSystemFontOfSize:18];
	newGameLabel.textAlignment = UITextAlignmentCenter;
	newGameLabel.textColor = [UIColor whiteColor];
	newGameLabel.backgroundColor = [UIColor clearColor];
	
	[self.view addSubview:newGameLabel];
	
	UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(20, 58, 280, 20)] autorelease];
	label.text = @"Enter a number:";
	label.textAlignment = UITextAlignmentCenter;
	label.textColor = [UIColor darkGrayColor];
	label.font = [UIFont boldSystemFontOfSize:17];
	label.backgroundColor = [UIColor clearColor];
	[self.view addSubview:label];
	
	[numberInput release];
	numberInput = [[UITextField alloc] initWithFrame:CGRectMake(60, 90, 200, 31)];
	numberInput.placeholder = @"Enter a number";
	numberInput.textAlignment = UITextAlignmentCenter;
	numberInput.borderStyle = UITextBorderStyleRoundedRect;
	numberInput.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	numberInput.font = [UIFont systemFontOfSize:12];
	numberInput.keyboardType = UIKeyboardTypeNumberPad;

	[self.view addSubview:numberInput];
	
	UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	button.frame = CGRectMake(15, 140, 140, 37);
	[button setTitle:@"Use this number" forState:UIControlStateNormal];
	[button addTarget:self action:@selector(numberChoosen) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:button];
	
	button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	button.frame = CGRectMake(165, 140, 140, 37);
	[button setTitle:@"Random number" forState:UIControlStateNormal];
	[button addTarget:self action:@selector(randomNumber) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:button];
	
	[errorLabel release];
	errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 180, 280, 54)];
	errorLabel.numberOfLines = 0;
	errorLabel.textColor = [UIColor redColor];
	errorLabel.backgroundColor = [UIColor clearColor];
	errorLabel.textAlignment = UITextAlignmentCenter;
	[self.view addSubview:errorLabel];
}

- (void) transitionDidStop {
	if(self.view.superview)
		[numberInput becomeFirstResponder];
}

- (void) closeKeyboard {
	[numberInput resignFirstResponder];
}

- (void) randomNumber {
	[self closeKeyboard];
	int intNumber = 1+arc4random() % 2147483646;
	
	[self.delegate newGame:[NSNumber numberWithInt:intNumber]];
}

- (void) numberChoosen {
	int number = numberInput.text.intValue;
	
	if(number <= 0 || number >= 2147483646){
		errorLabel.text = @"Please enter a number between 0 and 2147483646";
		return;
	}
	[numberInput resignFirstResponder];
	[self.delegate newGame:[NSNumber numberWithInt:number]];
}

- (void) returnToGame {
	[self closeKeyboard];
	[delegate returnToGame];
}

- (void)dealloc {
	[errorLabel release];
	[numberInput release];
	[cancelButton release];
    [super dealloc];
}

@end
