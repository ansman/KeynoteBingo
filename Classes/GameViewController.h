//
//  GameViewController.h
//  KeynoteBingo
//
//  Created by Nicklas Ansman on 14-6-2009.
//  Copyright 2009 Nicklas Ansman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "GameBoardViewController.h"

@protocol GameViewControllerDelegate <NSObject>

- (void) pickNewGame;
- (void) showSettings;

@end

@protocol GameViewControllerSettingsDelegate <NSObject>

- (BOOL) shouldVibrate;
- (BOOL) shouldPlaySound;

@end


@interface GameViewController : UIViewController <UIScrollViewDelegate, GameBoardViewControllerContainer> {
	
	id<GameViewControllerDelegate> delegate;
	id<GameViewControllerSettingsDelegate> settingsDelegate;
	GameBoardViewController *gameBoard;
	
	@private
	UIScrollView *gameBoardView;
	UILabel *bingoLabel;
	UILabel *boardNumberLabel;
	NSNumber *boardNumber;
	SystemSoundID audioPlayerID;
}

@property (nonatomic, assign) id<GameViewControllerDelegate> delegate;
@property (nonatomic, assign) id<GameViewControllerSettingsDelegate> settingsDelegate;

@property (nonatomic, readonly) GameBoardViewController *gameBoard;
@property (nonatomic, readonly) NSNumber *boardNumber;

- (void) newGame: (NSNumber *) newBoardNumber;

- (void) saveSettings;

@end
