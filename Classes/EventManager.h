//
//  EventManager.h
//  KeynoteBingo
//
//  Created by Nicklas Ansman on 02-7-2009.
//  Copyright 2009 Nicklas Ansman. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	EventManagerStatusIdle,
	EventManagerStatusUpdating,
	EventManagerStatusChecking
} EventManagerStatus;

@protocol EventManagerDelegate <NSObject>

- (void)setLoadingText:(NSString *)loadingText;

@optional
- (void) updateStarted;
- (void) updateFinished;

@end


@protocol EventManagerSettingsDelegate <NSObject>

- (int) updateInterval;
- (BOOL) shouldUpdate;
- (void) setAutomaticUpdates:(BOOL)shouldUpdate;

@end

@protocol EventManagerReciver <NSObject>

- (void)eventsLoaded:(NSArray *)eventsLoaded;

@end

@interface EventManager : NSObject <UIAlertViewDelegate> {
	NSArray *events;
	id<EventManagerSettingsDelegate> settingsDelegate;
	id<EventManagerDelegate> delegate;
	id<EventManagerReciver> reciever;
	
	
	@private
	EventManagerStatus status;
	NSURLConnection *connection;
	int lastFetch;
	int eventsID;
	int newEventsID;
}

@property (nonatomic, retain) NSArray *events;
@property (nonatomic, assign) id<EventManagerDelegate> delegate;
@property (nonatomic, assign) id<EventManagerSettingsDelegate> settingsDelegate;
@property (nonatomic, assign) id<EventManagerReciver> reciever;
@property (nonatomic, readonly) EventManagerStatus status;

- (void) outputEvents;
- (BOOL) hasNewEvents;
- (void) loadEvents;
- (int) getRealEventsID;
- (int) getLastUpdate;
- (void) cancelUpdate;

+ (NSString *) dateInFormat:(NSString*) stringFormat;


@end
