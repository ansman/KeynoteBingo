//
//  GameViewController.m
//  KeynoteBingo
//
//  Created by Nicklas Ansman on 14-6-2009.
//  Copyright 2009 Nicklas Ansman. All rights reserved.
//

#import "GameViewController.h"

@interface GameViewController (PrivateMethods)

- (void) loadSettings;

@end


@implementation GameViewController

@synthesize gameBoard, delegate, boardNumber, settingsDelegate;

- (id) init {
	if(self = [super init]) {
		bingoLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 416, 280, 40)];
		
		boardNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 52, 280, 30)];
		
		gameBoardView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 95, 320, 320)];
		
		gameBoard = [[GameBoardViewController alloc] init];
		gameBoard.container = self;
		
		[gameBoardView addSubview:gameBoard.view];
		
		CFBundleRef mainBundle = CFBundleGetMainBundle ();
		CFURLRef soundFileURLRef = CFBundleCopyResourceURL(mainBundle, CFSTR ("bingo"), CFSTR ("wav"), NULL);
		AudioServicesCreateSystemSoundID(soundFileURLRef, &audioPlayerID);
		
		[self loadSettings];
	}
	
	return self;
}

- (void) setGameBoard:(GameBoardViewController *)newGameBoard {
	[gameBoard release];
	gameBoard = [newGameBoard retain];
	gameBoard.container = self;
}

- (NSNumber *)getBoardNumber {
	return boardNumber;
}

- (void) loadSettings {
	if([[NSUserDefaults standardUserDefaults] floatForKey:@"zoomScale"] != 0) {
		boardNumber = [[NSNumber alloc] initWithInt:[[NSUserDefaults standardUserDefaults] integerForKey:@"boardNumber"]];
		
		CGPoint point = CGPointMake([[NSUserDefaults standardUserDefaults] floatForKey:@"contentOffsetX"], [[NSUserDefaults standardUserDefaults] floatForKey:@"contentOffsetY"]);
			
		[gameBoardView setContentOffset:point animated:NO];
			
		gameBoardView.zoomScale = [[NSUserDefaults standardUserDefaults] floatForKey:@"zoomScale"];
		
		if([gameBoard bingo])
			[self bingoSilent];
		else
			[self removeBingo];
	}
}

- (void) saveSettings {
	[[NSUserDefaults standardUserDefaults] setFloat:gameBoardView.zoomScale forKey:@"zoomScale"];
	[[NSUserDefaults standardUserDefaults] setFloat:gameBoardView.contentOffset.x forKey:@"contentOffsetX"];
	[[NSUserDefaults standardUserDefaults] setFloat:gameBoardView.contentOffset.y forKey:@"contentOffsetY"];
}

- (BOOL) gameHasStarted {
	return boardNumber != nil;
}

- (void) newGame: (NSNumber *)newBoardNumber {
	[boardNumber autorelease];
	boardNumber = [newBoardNumber retain];
	[[NSUserDefaults standardUserDefaults] setInteger:self.boardNumber.intValue forKey:@"boardNumber"];
	[self removeBingo];
	[gameBoard newGame];
}

- (void) bingoSilent {
	bingoLabel.text = @"BINGO!";
}

- (void) bingo {
	if([settingsDelegate shouldPlaySound])
		AudioServicesPlaySystemSound(audioPlayerID);
	if([settingsDelegate shouldVibrate])
		AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
	[self bingoSilent];
}

- (void) removeBingo {
	bingoLabel.text = @"";
}

- (UIView *) viewForZoomingInScrollView:(UIScrollView *) scrollView {
	return gameBoard.view;
}

- (void) viewWillAppear: (BOOL) animated {
	 boardNumberLabel.text = [NSString stringWithFormat:@"Board #%@", boardNumber];
	[self.gameBoard viewWillAppear:animated];
}

- (void) loadView {
	self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 19, 320, 461)];
	self.view.backgroundColor = [UIColor whiteColor];
	
	gameBoardView.maximumZoomScale = 1;
	gameBoardView.minimumZoomScale = 0.588;
	gameBoardView.delaysContentTouches = YES;
	gameBoardView.bouncesZoom = YES;
	gameBoardView.delegate = self;
	[gameBoardView addSubview:gameBoard.view];
	[gameBoardView setContentSize:CGSizeMake(gameBoard.view.frame.size.width, gameBoard.view.frame.size.height)];
	gameBoardView.zoomScale = 0.588;
	[self.view addSubview:gameBoardView];
	
	bingoLabel.textAlignment = UITextAlignmentCenter;
	bingoLabel.font = [UIFont boldSystemFontOfSize:24];
	[self.view addSubview:bingoLabel];
	
	boardNumberLabel.textAlignment = UITextAlignmentCenter;
	boardNumberLabel.font = [UIFont boldSystemFontOfSize:24];
	[self.view addSubview:boardNumberLabel];
	
	UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
	
	UIBarButtonItem *newGameButton = [[UIBarButtonItem alloc] initWithTitle:@"New Game"
																	  style:UIBarButtonItemStyleBordered
																	 target:delegate
																	 action:@selector(pickNewGame)];
	
	UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																				   target:nil
																				   action:nil];
	
	UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithTitle:@"Settings"
																   style:UIBarButtonItemStyleBordered
																  target:delegate
																  action:@selector(showSettings)];
	
	[toolbar setItems:[NSArray arrayWithObjects:newGameButton, flexibleSpace, infoButton, nil]];

	[self.view addSubview:toolbar];
	
	[newGameButton release];
	[flexibleSpace release];
	[infoButton release];
	[toolbar release];
}

- (void)dealloc {
	[gameBoard release];
	[gameBoardView release];
	[bingoLabel release];
	[boardNumberLabel release];
	[boardNumber release];
    [super dealloc];
}

@end
