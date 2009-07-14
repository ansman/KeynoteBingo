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

- (void)eventsLoaded;

@end

@interface EventManager : NSObject <UIAlertViewDelegate> {
	NSArray *events;
	id<EventManagerSettingsDelegate> settingsDelegate;
	id<EventManagerDelegate> delegate;
	id<EventManagerReciver> receiver;
	
	
	@private
	EventManagerStatus status;
	NSMutableData *data;
	NSURLConnection *connection;
	int lastUpdate;
	int eventsID;
	int serverEventsID;
	BOOL newEvents;
}

@property (nonatomic, readonly) NSArray *events;
@property (nonatomic, assign) id<EventManagerDelegate> delegate;
@property (nonatomic, assign) id<EventManagerSettingsDelegate> settingsDelegate;
@property (nonatomic, assign) id<EventManagerReciver> receiver;
@property (nonatomic, readonly) EventManagerStatus status;
@property (nonatomic, readonly) int eventsID;
@property (nonatomic, readonly, getter=hasNewEvents) BOOL newEvents;
@property (nonatomic, readonly) int lastUpdate;

- (void) cancelUpdate;
- (void) loadEvents;
- (void) loadEventsFromInternet:(BOOL) forced;
- (void) loadEventsFromFile;
+ (NSString *) dateInFormat:(NSString*) stringFormat;


@end
