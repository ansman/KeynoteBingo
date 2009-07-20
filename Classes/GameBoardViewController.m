//
//  GameBoardViewController.m
//  KeynoteBingo
//
//  Created by Nicklas Ansman on 14-6-2009.
//  Copyright 2009 Nicklas Ansman. All rights reserved.
//

#import "GameBoardViewController.h"

@interface GameBoardViewController (PrivateMethods)

- (void) loadSettings;
- (void) placeEvents;
- (BOOL) checkBingo;

@end


@implementation GameBoardViewController

@synthesize delegate, bingo, container, eventManager;

- (id) init {
	if(self = [super init]) {
		NSMutableArray *array = [NSMutableArray array];
		KeynoteButton *button;
		UIImage *buttonImageNormal = [UIImage imageNamed:@"button.png"];
		UIImage *buttonImageSelected = [UIImage imageNamed:@"buttonSelected.png"];
		for(int i = 0; i < 25; i++) {
			int row = i / 5;
			int col = i % 5;
			
			int x = row * 95 + 8 * row + 22;
			int y = col * 95 + 8 * col + 22;
			button = [[[KeynoteButton alloc] initWithFrame:CGRectMake(x, y, 95, 95)] autorelease];
			button.tag = i+1;
			
			[button setButtonImage:buttonImageNormal forState:UIControlStateNormal];
			[button setButtonImage:buttonImageSelected forState:UIControlStateSelected];
			[button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
			button.titleLabel.font = [UIFont boldSystemFontOfSize:15];
			[button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
			[array addObject:button];
		}
		buttons = [[NSArray alloc] initWithArray:array];		
		[self loadSettings];
	}
	return self;
}

- (void) loadSettings {
	for(KeynoteButton *button in buttons)
		button.selected = [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"button%iSelected", button.tag]];
	
	if([self checkBingo])
		bingo = YES;
	else
		bingo = NO;
}

- (void) buttonClicked: (KeynoteButton *) button {
	BOOL hasBingo = [self checkBingo];
	if(hasBingo && !bingo) {
		bingo = YES;
		[container bingo];
	}
	else if(!hasBingo && bingo) {
		bingo = NO;
		[container removeBingo];
	}
	
	[[NSUserDefaults standardUserDefaults] setBool:button.selected forKey:[NSString stringWithFormat:@"button%iSelected", button.tag]];
}

- (void) eventsLoaded {
	if([eventManager hasNewEvents])
		[self resetBoard];
	
	if([eventManager hasNewEvents] || !events) {
		[events autorelease];
		events = [[eventManager events] retain];
		[self placeEvents];
	}
	
	[delegate loadingComplete];
}

- (BOOL) checkBingo {
	BOOL bingoFoundVert;
	BOOL bingoFoundHoriz;
	BOOL bingoFoundDiag1 = YES;
	BOOL bingoFoundDiag2 = YES;
	
	for (NSUInteger i = 0; i < 5; i++) {
		bingoFoundVert = YES;
		bingoFoundHoriz = YES;
		for (NSUInteger j = 0; j < 5 && (bingoFoundVert || bingoFoundHoriz); j++) {
			if (!((KeynoteButton *)[buttons objectAtIndex:i*5+j]).selected)
				bingoFoundVert = NO;
			if (!((KeynoteButton *)[buttons objectAtIndex:j*5+i]).selected)
				bingoFoundHoriz = NO;
		}
		
		if (bingoFoundVert)
			return YES;
		
		if (bingoFoundHoriz)
			return YES;
		
		if (!((KeynoteButton *)[buttons objectAtIndex:i*6]).selected) 
			bingoFoundDiag1 = NO;
		
		if (!((KeynoteButton *)[buttons objectAtIndex:4+i*4]).selected) 
			bingoFoundDiag2 = NO;
	}
	
	if (bingoFoundDiag1 || bingoFoundDiag2)
		return YES;
	else
		return NO;
}

- (void) newGame {
	[self resetBoard];
	[self placeEvents];
}

- (void)loadView {
	self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 550, 550)];
	self.view.backgroundColor = [UIColor clearColor];
	
	for(int i = 0; i < 5; i = i++)
		for(int j = 0; j < 5; j++)
			[self.view addSubview:[buttons objectAtIndex:i*5+j]];
}

- (void) placeEvents {	
	if([container getBoardNumber]) {
		int numberOfEvents = [events count];
		
		BOOL pickedNumbers[numberOfEvents];
		
		for (int i = 0; i < numberOfEvents; i++)
			pickedNumbers[i] = NO;
		
		int number;
		
		srand([container getBoardNumber].unsignedIntValue);
		
		for (KeynoteButton *button in buttons) {
			do {
				number = rand() % numberOfEvents;
			} while (pickedNumbers[number]);
			pickedNumbers[number] = YES;
			[button setTitle:[events objectAtIndex:number] forState:UIControlStateNormal];
		}
	}
	else {
		for (KeynoteButton *button in buttons) {
			button.enabled = NO;
			[button setTitle:@"No number selected" forState:UIControlStateNormal];
		}
	}
}

- (void) resetBoard {
	for(KeynoteButton *button in buttons){
		button.selected = NO;
		button.enabled = YES;
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:[NSString stringWithFormat:@"button%iSelected", button.tag]];
	}
	[container removeBingo];
}

- (void) setEventManager:(EventManager *)manager {
	[eventManager autorelease];
	eventManager = [manager retain];
	eventManager.receiver = self;
}

- (void)dealloc {
	[events autorelease];
	[buttons release];
	[eventManager release];
    [super dealloc];
}


@end
