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

@end


@implementation GameBoardViewController

@synthesize delegate, bingo, events, container, eventManager;

- (id) init {
	if(self = [super init]) {
		NSMutableArray *array = [NSMutableArray array];
		KeynoteButton *button;
		UIImage *buttonImageNormal = [UIImage imageNamed:@"button.png"];
		UIImage *buttonImageSelected = [UIImage imageNamed:@"buttonSelected.png"];
		for(int i = 0; i < 25; i++) {
			int row = i / 5;
			int col = i % 5;
			
			int x = row * 95 + 8 * row + 17;
			int y = col * 95 + 8 * col + 17;
			button = [[[KeynoteButton alloc] initWithFrame:CGRectMake(x, y, 95, 95)] autorelease];
			button.tag = i+1;
			
			[button setButtonImage:buttonImageNormal forState:UIControlStateNormal];
			[button setButtonImage:buttonImageSelected forState:UIControlStateSelected];
			[button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
			
			[button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
			[array addObject:button];
		}
		buttons = [[NSArray alloc] initWithArray:array];
		self.events = nil;
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

- (UIButton *) getButton: (NSUInteger) index {
	if (index >= [self.view.subviews count])
		return nil;
	
	return [self.view.subviews objectAtIndex:index];
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

- (void) eventsLoaded:(NSArray *)newEvents {
	self.events = newEvents;
	
	if([eventManager hasNewEvents])
		[self resetBoard];

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
			if (((KeynoteButton *)[buttons objectAtIndex:i*5+j]).selected == NO) 
				bingoFoundVert = NO;
			if (((KeynoteButton *)[buttons objectAtIndex:j*5+i]).selected == NO) 
				bingoFoundHoriz = NO;
		}
		
		if (bingoFoundVert == YES)
			return YES;
		
		if (bingoFoundHoriz == YES)
			return YES;
		
		if (((KeynoteButton *)[buttons objectAtIndex:i*6]).selected == NO) 
			bingoFoundDiag1 = NO;
		
		if (((KeynoteButton *)[buttons objectAtIndex:4+i*4]).selected == NO) 
			bingoFoundDiag2 = NO;
	}
	
	if (bingoFoundDiag1 == YES || bingoFoundDiag2 == YES)
		return YES;
	else
		return NO;
}

- (void) newGame {
	[self resetBoard];
}

- (void)loadView {
	self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 550, 550)];
	
	for(int i = 0; i < 5; i = i++)
		for(int j = 0; j < 5; j++)			
			[self.view addSubview:[buttons objectAtIndex:i*5+j]];
}

- (void) viewWillAppear: (BOOL) animated {
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

- (void) resetBoard {
	for(KeynoteButton *button in buttons){
		button.selected = NO;
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:[NSString stringWithFormat:@"button%iSelected", button.tag]];
	}
	[container removeBingo];
}

- (void) setEventManager:(EventManager *)manager {
	[eventManager autorelease];
	eventManager = [manager retain];
	eventManager.reciever = self;
}

- (void) loadEvents {
	[eventManager loadEvents];
}

- (void)dealloc {
	[events release];
	[buttons release];
	[eventManager release];
    [super dealloc];
}


@end
