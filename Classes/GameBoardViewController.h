//
//  GameBoardViewController.h
//  KeynoteBingo
//
//  Created by Nicklas Ansman on 14-6-2009.
//  Copyright 2009 Nicklas Ansman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeynoteButton.h"
#import "EventManager.h"

@protocol GameBoardViewControllerDelegate <NSObject>

- (void) loadingComplete;

@end

@protocol GameBoardViewControllerContainer <NSObject>

- (void) bingo;
- (void) bingoSilent;
- (void) removeBingo;
- (NSNumber *)getBoardNumber;

@end


@interface GameBoardViewController : UIViewController <EventManagerReciver> {
	NSArray *events;
	BOOL bingo;
	id<GameBoardViewControllerDelegate> delegate;
	id<GameBoardViewControllerContainer> container;
	EventManager *eventManager;
	
	@private
	NSArray *buttons;
}

@property (nonatomic, assign) id<GameBoardViewControllerDelegate> delegate;
@property (nonatomic, assign) id<GameBoardViewControllerContainer> container;
@property (nonatomic, retain) EventManager *eventManager;
@property (nonatomic, readonly) BOOL bingo;
@property (nonatomic, retain) NSArray *events;

- (void) newGame;
- (BOOL) checkBingo;
- (void) resetBoard;

@end
