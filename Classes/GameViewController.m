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
		boardNumberLabel.text = @"No number selected";
		
		gameBoardView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 95, 320, 320)];
		
		gameBoard = [[GameBoardViewController alloc] init];
		gameBoard.container = self;
		
		[gameBoardView addSubview:gameBoard.view];
				
		CFBundleRef mainBundle = CFBundleGetMainBundle();
		CFURLRef soundFileURLRef = CFBundleCopyResourceURL(mainBundle, CFSTR("bingo"), CFSTR("wav"), NULL);
		AudioServicesCreateSystemSoundID(soundFileURLRef, &audioPlayerID);
		
		bingoImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
		bingoImage.image = [UIImage imageNamed:@"bingo.png"];
		
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
		
		if([boardNumber intValue] <= 0 || [boardNumber intValue] >= 2147483646){
			[boardNumber release];
			boardNumber = nil;
		}
		else
			boardNumberLabel.text = [NSString stringWithFormat:@"Board #%@", boardNumber];
		
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

- (void) newGame: (NSNumber *)newBoardNumber {
	[boardNumber autorelease];
	boardNumber = [newBoardNumber retain];
	[[NSUserDefaults standardUserDefaults] setInteger:self.boardNumber.intValue forKey:@"boardNumber"];
	boardNumberLabel.text = [NSString stringWithFormat:@"Board #%@", boardNumber];
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
	[self animateBingo];
}

- (void) animateBingo {
	bingoImage.frame = CGRectMake(160, 274, 0, 0);
	bingoImage.alpha = 2.5;
	self.view.userInteractionEnabled = NO;
	
	CGRect rect = bingoImage.frame;
	rect.size.width = 317;
	rect.size.height = 229;
	rect.origin.x = 3;
	rect.origin.y = 156;
	
	[self.view addSubview:bingoImage];
	[self.view bringSubviewToFront:bingoImage];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	[UIView setAnimationDuration:1];
	[UIView setAnimationDelegate:self];
	bingoImage.frame = rect;
	bingoImage.alpha = 0;
	[UIView commitAnimations];
	
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	[bingoImage removeFromSuperview];
	self.view.userInteractionEnabled = YES;
}

- (void) removeBingo {
	bingoLabel.text = @"";
}

- (UIView *) viewForZoomingInScrollView:(UIScrollView *) scrollView {
	return gameBoard.view;
}

- (void) loadView {
	self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 19, 320, 461)];
	
	UIImageView *background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 461)];
	background.image = [UIImage imageNamed:@"background.png"];
	[self.view addSubview:background];
	[background release];
	
	gameBoardView.maximumZoomScale = 1;
	gameBoardView.minimumZoomScale = 0.588;
	gameBoardView.delaysContentTouches = YES;
	gameBoardView.bouncesZoom = YES;
	gameBoardView.delegate = self;
	[gameBoardView addSubview:gameBoard.view];
	[gameBoardView setContentSize:CGSizeMake(gameBoard.view.frame.size.width, gameBoard.view.frame.size.height)];
	
	if([[NSUserDefaults standardUserDefaults] floatForKey:@"zoomScale"] != 0) {
		CGPoint point = CGPointMake([[NSUserDefaults standardUserDefaults] floatForKey:@"contentOffsetX"], [[NSUserDefaults standardUserDefaults] floatForKey:@"contentOffsetY"]);
		
		[gameBoardView setContentOffset:point animated:NO];
		
		gameBoardView.zoomScale = [[NSUserDefaults standardUserDefaults] floatForKey:@"zoomScale"];
	} else 
		gameBoardView.zoomScale = 0.588;
			
	[self.view addSubview:gameBoardView];
	
	bingoLabel.textAlignment = UITextAlignmentCenter;
	bingoLabel.textColor = [UIColor whiteColor];
	bingoLabel.backgroundColor = [UIColor clearColor];
	bingoLabel.font = [UIFont boldSystemFontOfSize:24];
	[self.view addSubview:bingoLabel];
	
	boardNumberLabel.textAlignment = UITextAlignmentCenter;
	boardNumberLabel.font = [UIFont boldSystemFontOfSize:24];
	boardNumberLabel.textColor = [UIColor whiteColor];
	boardNumberLabel.backgroundColor = [UIColor clearColor];
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
	[bingoImage release];
	[gameBoardView release];
	[bingoLabel release];
	[boardNumberLabel release];
	[boardNumber release];
    [super dealloc];
}

@end
