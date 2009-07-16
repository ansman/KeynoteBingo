//
//  EventManager.m
//  KeynoteBingo
//
//  Created by Nicklas Ansman on 02-7-2009.
//  Copyright 2009 Nicklas Ansman. All rights reserved.
//

#import "EventManager.h"

@interface EventManager (PrivateMethods)

- (void) checkForNewerEvents;
- (void) updateToNewerEvents;
- (void) makeConnection:(NSString *)urlString;
- (NSDictionary *) processEventsData: (NSData *)data;
- (void) updateComplete;
- (void) outputEvents;

@end

@implementation EventManager

@synthesize events, delegate, settingsDelegate, receiver, status, lastUpdate, newEvents, eventsID;

NSString *EVENTS_URL = @"http://keynote.se/iphone/events.plist";
NSString *LAST_UPDATE_URL = @"http://keynote.se/iphone/events-update-time.txt";

- (id) init {
	if(self = [super init]) {
		[[NSURLCache sharedURLCache] setMemoryCapacity:0];
		[[NSURLCache sharedURLCache] setDiskCapacity:0];
	}
	return self;
}

/**
 * Creates a connection to the specified URL
 * and starts the connection.
 */
- (void) makeConnection:(NSString *)urlString {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	NSURL *url = [[[NSURL alloc] initWithString:urlString] autorelease];
	NSURLRequest *urlRequest = [[[NSURLRequest alloc] initWithURL:url] autorelease];
	
	connection = [[NSURLConnection connectionWithRequest:urlRequest delegate:self] retain];
	data = [[NSMutableData alloc] init];
	[connection start];
}

/**
 * Cancels an ongoing update.
 * This method does nothing if called when
 * status == EventManagerStatusIdle
 */
- (void) cancelUpdate {
	if(status != EventManagerStatusIdle) {
		status = EventManagerStatusIdle;
		[connection cancel];
		[connection release];
		connection = nil;
		[data release];
		data = nil;
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		[delegate setLoadingText:@""];
		[self updateComplete];
	}
}

/**
 * Checks the server for newer events.
 */
- (void) checkForNewerEvents {
	[delegate setLoadingText:@"Checking for newer events..."];
	status = EventManagerStatusChecking;
	[self makeConnection:LAST_UPDATE_URL];
}

/**
 * Fetches events from the server.
 */
- (void) updateToNewerEvents {
	[delegate setLoadingText:@"Fetching newer events..."];
	status = EventManagerStatusUpdating;
	[self makeConnection:EVENTS_URL];
}

/**
 * Appends data to an existing data object for
 * processing later on.
 */
- (void)connection:(NSURLConnection *)whichConnection didReceiveData:(NSData *)newData {
	[data appendData:newData];
}

/**
 * Called on when the connection finished loading.
 * The status is then checked and the appropriate action
 * is taken. 
 */
- (void)connectionDidFinishLoading:(NSURLConnection *)notUsed {
	[connection release];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	if(status == EventManagerStatusChecking) { // Checking for newer events.
		status = EventManagerStatusIdle;
		NSString *string = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
		
		int newEventsID = string.intValue;
		
		[data release];
		data = nil;
		
		// The events on the server are obviously not newer.
		if(newEventsID <= eventsID) {
			lastUpdate = [EventManager dateInFormat:@"%s"].intValue;
			[self updateComplete];
			return;
		}
		
		serverEventsID = newEventsID;
		[self updateToNewerEvents];
	}
	else if(status == EventManagerStatusUpdating) { // Fetching events.
		status = EventManagerStatusIdle;
		[delegate setLoadingText:@"Processing fetched data..."];
		NSDictionary *processedData = [self processEventsData:data];
		[data release];
		data = nil;
		
		// If the dictionary is nil than something was wrong.
		if(processedData != nil) {
			[events autorelease];
			events = [[processedData objectForKey:@"events"] retain];
			eventsID = serverEventsID;
			serverEventsID = 0;
			lastUpdate = [EventManager dateInFormat:@"%s"].intValue;
			newEvents = YES;
			[self updateComplete];
		}
		else {
			UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"The events could not be processed"
															 message:@"The events fetched from the server could not be processed.\nOld events will be used instead." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] autorelease];
			[alert show];
		}
	}	
}

/**
 * When for some reason the connection failed this method is called.
 * An alert box is shown to the user when this happens.
 */
- (void)connection:(NSURLConnection *)notUsed didFailWithError:(NSError *)error {
	status = EventManagerStatusIdle;
	[connection release];
	connection = nil;
	serverEventsID = 0;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"The events could not be loaded"
													 message:@"The events could not be loaded from the server.\nPlease check your internet connection.\nOld events will be used instead." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] autorelease];
	[alert show];
}

/**
 * Returns the unix timestamp of the last update.
 * Returns -1 if an update is ongoing.
 */
- (int) lastUpdate {
	if(status == EventManagerStatusIdle)
		return lastUpdate;
	else
		return -1;
}

/**
 * Loads events from a server.
 * If the argument is YES then the last
 * update checks will be skipped.
 */
- (void) loadEventsFromInternet:(BOOL) forced {
	if(!forced) {
		if(![settingsDelegate shouldUpdate])
			return;
		
		if(lastUpdate+[settingsDelegate updateInterval] > [EventManager dateInFormat:@"%s"].intValue)
			return;
	}
	
	[self checkForNewerEvents];
}

/**
 * Should be called when the event manager has been created
 * to load the events, both from a file and from a server.
 */
- (void) loadEvents {
	NSString *path = [NSString stringWithFormat:@"%@/Library/Caches/events.plist", NSHomeDirectory()];
	NSFileManager *manager = [NSFileManager defaultManager];
	
	if(![manager fileExistsAtPath:path]) { // First time starting the app.
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Automatic Updates"
														message:@"This application uses an automatic update feature which requires an internet connect to function.\nDo you wish to enable this feature (this can be changed later in the settings menu later)?" 
														delegate:self 
														cancelButtonTitle:@"No"
														otherButtonTitles:nil] autorelease];
		alert.cancelButtonIndex = 0;
		alert.tag = 1337;
		[alert addButtonWithTitle:@"Yes"];
		[alert show];
		
	}
	else { // Not the first time.
		if([delegate respondsToSelector:@selector(updateStarted)])
			[delegate performSelector:@selector(updateStarted)];
		[self loadEventsFromFile];
		[self loadEventsFromInternet:NO];
		
		if(status == EventManagerStatusIdle)
			[self updateComplete];
	}
}

/**
 * Called on when all the updates has been completed.
 */
- (void) updateComplete {
	[self outputEvents];
	[delegate setLoadingText:@""];
	if([delegate respondsToSelector:@selector(updateFinished)])
		[delegate performSelector:@selector(updateFinished)];
	[receiver eventsLoaded];
}

/**
 * Called on when the user closes a alert.
 */
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if(alertView.tag == 1337){ // The first load alert
		NSString *path = [NSString stringWithFormat:@"%@/Library/Caches/events.plist", NSHomeDirectory()];
		NSFileManager *manager = [NSFileManager defaultManager];
		[manager createFileAtPath:path contents:nil attributes:nil];
		if(buttonIndex == 0)
			[settingsDelegate setAutomaticUpdates:NO];
		[self loadEvents];
	}
	else // Events could not be loaded/not processed alert
		[self updateComplete];
}

/**
 * Returns a date in the specified format.
 * The formats are the same as for strftime()
 */
+(NSString *) dateInFormat:(NSString*) stringFormat {
	char buffer[80];
	const char *format = [stringFormat UTF8String];
	time_t rawtime;
	struct tm * timeinfo;
	time(&rawtime);
	timeinfo = localtime(&rawtime);
	strftime(buffer, 80, format, timeinfo);
	return [NSString  stringWithCString:buffer encoding:NSUTF8StringEncoding];
}

/**
 * Loads the events from a file.
 * There are 2 files:
 * 1. App bundle/Resources/events.plist
 * 2. User Home Dir/Library/Caches/events.plist
 *
 * The first is included in the app and the second
 * stores the events fetched from the server.
 */
- (void) loadEventsFromFile {
	if(events)
		return;
	
	[delegate setLoadingText:@"Loading events from file..."];
	
	NSString *pathCached = [NSString stringWithFormat:@"%@/Library/Caches/events.plist", NSHomeDirectory()];
	NSDictionary *rootDictCached = [NSDictionary dictionaryWithContentsOfFile:pathCached];
	
	NSString *pathDefault = [[NSBundle mainBundle] pathForResource:@"events" ofType:@"plist"];
	NSDictionary *rootDictDefault = [NSDictionary dictionaryWithContentsOfFile:pathDefault];
	
	newEvents = NO;
	
	if(!rootDictCached) { // No cached file, use default.
		eventsID = ((NSNumber *)[rootDictDefault objectForKey:@"eventsID"]).intValue;
		lastUpdate = 0;
		[events autorelease];
		events = [[rootDictDefault objectForKey:@"events"] retain];
	}
	else {
		eventsID = ((NSNumber *)[rootDictDefault objectForKey:@"eventsID"]).intValue;
		int eventsIDCached = ((NSNumber *)[rootDictCached objectForKey:@"eventsID"]).intValue;
		
		if(eventsID > eventsIDCached) { // Default events are newer than cached, use default.
			[events autorelease];
			events = [[rootDictDefault objectForKey:@"events"] retain];
			newEvents = YES;
		}
		else { // Cached are newer (most common), use cached.
			[events autorelease];
			events = [[rootDictCached objectForKey:@"events"] retain];
			eventsID = eventsIDCached;
		}
		lastUpdate = ((NSNumber *)[rootDictCached objectForKey:@"lastUpdate"]).intValue;
	}
}

/**
 * Transforms a NSData object into an NSDictionary
 * If the data could not be transformed nil is returned.
 */
- (NSDictionary *) processEventsData: (NSData *)whichData {
	NSString *errorDesc = nil;
	NSPropertyListFormat format;
	NSDictionary *dict = (NSDictionary *)[NSPropertyListSerialization propertyListFromData:whichData
																		  mutabilityOption:NSPropertyListMutableContainersAndLeaves
																					format:&format
																		  errorDescription:&errorDesc];
	if(!dict){
        NSLog(errorDesc);
        [errorDesc release];
		return nil;
	}
	
	return dict;
}

/**
 * Writes the events to:
 * User home dir/Caches/Library/events.plist
 *
 * The file is written atomically so that no
 * corruption can occur.
 */
- (void) outputEvents {

	NSString *filePath = [NSString stringWithFormat:@"%@/Library/Caches/events.plist", NSHomeDirectory()];
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
		
	[delegate setLoadingText:@"Writing events to file..."];
	
	[dict setObject:events forKey:@"events"];
	[dict setObject:[NSNumber numberWithInt:eventsID] forKey:@"eventsID"];
	[dict setObject:[NSNumber numberWithInt:lastUpdate] forKey:@"lastUpdate"];
	
	[dict writeToFile:filePath atomically:YES];
	
	[dict release];
}

/**
 * Returns the events.
 * Returns nil if they are being updated.
 */
- (NSArray *)events {
	if(status == EventManagerStatusIdle)
		return events;
	else
		return nil;
}

- (void) dealloc {
	[events release];
	[data release];
	[connection release];
	[super dealloc];
}

@end
