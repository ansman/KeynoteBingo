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
	
	UIImageView *background = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"backgroundImage.png"]] autorelease];
	background.frame = CGRectMake(0, 0, 320, 480);
	background.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:background];
	
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
	label.text = @"Please enter a positive integer:";
	label.textAlignment = UITextAlignmentCenter;	
	label.textColor = [UIColor whiteColor];
	label.font = [UIFont boldSystemFontOfSize:17];
	label.backgroundColor = [UIColor clearColor];
	[self.view addSubview:label];
	
	[numberInput release];
	numberInput = [[UITextField alloc] initWithFrame:CGRectMake(60, 105, 200, 31)];
	numberInput.placeholder = @"Enter a number";
	numberInput.textAlignment = UITextAlignmentCenter;
	numberInput.borderStyle = UITextBorderStyleRoundedRect;
	numberInput.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	numberInput.font = [UIFont systemFontOfSize:12];
	numberInput.keyboardType = UIKeyboardTypeNumberPad;

	[self.view addSubview:numberInput];
	
	UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	button.frame = CGRectMake(89, 154, 142, 37);
	[button setTitle:@"Use this number" forState:UIControlStateNormal];
	[button addTarget:self action:@selector(numberChoosen) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:button];
	
	button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	button.frame = CGRectMake(87, 206, 147, 37);
	[button setTitle:@"Random number" forState:UIControlStateNormal];
	[button addTarget:self action:@selector(randomNumber) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:button];
	
	[errorLabel release];
	errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 241, 280, 54)];
	errorLabel.numberOfLines = 0;
	errorLabel.textColor = [UIColor redColor];
	errorLabel.backgroundColor = [UIColor clearColor];
	errorLabel.textAlignment = UITextAlignmentCenter;
	[self.view addSubview:errorLabel];
}

- (BOOL) textFieldShouldReturn: (UITextField *) theTextField {
	[self closeKeyboard];
	return YES;
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
	[self closeKeyboard];
	int number = numberInput.text.intValue;
	
	if(number <= 0 || number >= 2147483646){
		errorLabel.text = @"Please enter a number between 0 and 2147483646";
		return;
	}
	
	[self.delegate newGame:[NSNumber numberWithInt:number]];
}

- (void) returnToGame {
	[delegate returnToGame];
}

- (void)dealloc {
	[errorLabel release];
	[numberInput release];
	[cancelButton release];
    [super dealloc];
}

@end
