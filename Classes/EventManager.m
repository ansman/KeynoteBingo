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
- (NSArray *) processEventsData: (NSData *)data;
- (void) updateComplete;
- (void) loadEventsFromInternet;
- (void) loadEventsFromFile;

@end

@implementation EventManager

@synthesize events;
@synthesize delegate;
@synthesize settingsDelegate;
@synthesize reciever;
@synthesize status;

NSString *EVENTS_URL = @"http://keynote.se/iphone/events.plist";
NSString *LAST_UPDATE_URL = @"http://keynote.se/iphone/events-update-time.txt";

- (void) makeConnection:(NSString *)urlString {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	NSURL *url = [[[NSURL alloc] initWithString:urlString] autorelease];
	NSURLRequest *urlRequest = [[[NSURLRequest alloc] initWithURL:url] autorelease];
	
	connection = [[NSURLConnection connectionWithRequest:urlRequest delegate:self] retain];
	[connection start];
}

- (void) cancelUpdate {
	if(status != EventManagerStatusIdle) {
		status = EventManagerStatusIdle;
		[connection cancel];
		[connection release];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		[delegate setLoadingText:@""];
		[reciever eventsLoaded:self.events];
	}
}

- (void) checkForNewerEvents {	
	[delegate setLoadingText:@"Checking for newer events..."];
	status = EventManagerStatusChecking;
	[self makeConnection:LAST_UPDATE_URL];
}

- (void) updateToNewerEvents {
	[delegate setLoadingText:@"Fetching newer events..."];
	status = EventManagerStatusChecking;
	[self makeConnection:EVENTS_URL];
}

- (void)connection:(NSURLConnection *)whichConnection didReceiveData:(NSData *)data {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	if(status == EventManagerStatusChecking) {
		status = EventManagerStatusIdle;
		[connection release];
		NSString *string = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
		
		newEventsID = [string intValue];
		
		if(newEventsID <= eventsID) {
			lastFetch = [EventManager dateInFormat:@"%s"].intValue;
			[self updateComplete];
			return;
		}
		
		[self updateToNewerEvents];
	}
	else if(status == EventManagerStatusUpdating) {
		status = EventManagerStatusIdle;
		[connection release];
		[delegate setLoadingText:@"Processing fetched data..."];
		NSArray *processedData = [self processEventsData:data];
		
		if(processedData != nil) {
			self.events = processedData;
			lastFetch = [EventManager dateInFormat:@"%s"].intValue;
			[self updateComplete];
			return;
		}
		else {
			UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"The events could not be processed" 
												message:@"The events fetched from the server could not be processed.\nOld events will be used instead." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] autorelease];
			[alert show];
		}
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	status = EventManagerStatusIdle;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"The events could not be loaded" 
													 message:@"The events could not be loaded from the server.\nPlease check your internet connection.\nOld events will be used instead." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] autorelease];
	[alert show];
}

- (int) getLastUpdate {
	if(status == EventManagerStatusIdle)
		return lastFetch;
	else
		return -1;
}

- (void) loadEventsFromInternet {
	if(![settingsDelegate shouldUpdate])
		return;
	
	if(lastFetch+[settingsDelegate updateInterval] > [EventManager dateInFormat:@"%s"].intValue)
		return;
	
	[self checkForNewerEvents];	
}

- (id) init {
	if(self = [super init]){
		self.events = nil;
	}
	
	return self;
}

- (void) loadEvents {	
	NSString *path = [NSString stringWithFormat:@"%@/Library/Caches/events.plist", NSHomeDirectory()];
	NSFileManager *manager = [NSFileManager defaultManager];
	
	if(![manager fileExistsAtPath:path]) {
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Automatic Updates"
														message:@"This application uses an automatic update feature which requires an internet connect to function.\nDo you wish to enable this feature (this can be changed later in the settings menu later)?" 
														delegate:self 
														cancelButtonTitle:@"Yes"
														otherButtonTitles:nil] autorelease];
		alert.cancelButtonIndex = 1;
		alert.tag = 1337;
		[alert addButtonWithTitle:@"No"];
		[alert show];
		
	}
	else {
		if([delegate respondsToSelector:@selector(updateStarted)])
			[delegate performSelector:@selector(updateStarted)];
		[self loadEventsFromFile];
		[self loadEventsFromInternet];
		
		if(status == EventManagerStatusIdle)
			[self updateComplete];
	}
}

- (void) updateComplete {
	[self outputEvents];
	[delegate setLoadingText:@""];
	if([delegate respondsToSelector:@selector(updateFinished)])
		[delegate performSelector:@selector(updateFinished)];
	[reciever eventsLoaded:self.events];
}	
	
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if(alertView.tag == 1337){
		NSString *path = [NSString stringWithFormat:@"%@/Library/Caches/events.plist", NSHomeDirectory()];
		NSFileManager *manager = [NSFileManager defaultManager];
		[manager createFileAtPath:path contents:nil attributes:nil];
		if(buttonIndex == 1)
			[settingsDelegate setAutomaticUpdates:NO];
		[self loadEvents];
	}
	else
		[self updateComplete];
}
		
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

- (void) loadEventsFromFile {
	if(events)
		return;
	
	[delegate setLoadingText:@"Loading events from file..."];
	
	NSString *path = [NSString stringWithFormat:@"%@/Library/Caches/events.plist", NSHomeDirectory()];
			
	NSDictionary *rootDict = [NSDictionary dictionaryWithContentsOfFile:path];	
	
	if(rootDict == nil) {
		path = [[NSBundle mainBundle] pathForResource:@"events" ofType:@"plist"];
		rootDict = [NSDictionary dictionaryWithContentsOfFile:path];
	}
	
	lastFetch = ((NSNumber *)[rootDict objectForKey:@"last_update"]).intValue;
	eventsID= ((NSNumber *)[rootDict objectForKey:@"eventsID"]).intValue;
	self.events = [rootDict objectForKey:@"events"];
}

- (NSArray *) processEventsData: (NSData *)data {
	NSString *errorDesc = nil;
	NSPropertyListFormat format;
	NSDictionary * dict = (NSDictionary*)[NSPropertyListSerialization
										  propertyListFromData:data
										  mutabilityOption:NSPropertyListMutableContainersAndLeaves
										  format:&format
										  errorDescription:&errorDesc];
	if(!dict){
        NSLog(errorDesc);
        [errorDesc release];
		return nil;
	}
		
	return [dict objectForKey:@"events"];
}

- (void) outputEvents {
	[delegate setLoadingText:@"Writing events to file..."];
	NSString *filePath = [NSString stringWithFormat:@"%@/Library/Caches/events.plist", NSHomeDirectory()];
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	
	[dict setObject:events forKey:@"events"];
	[dict setObject:[NSNumber numberWithInt:lastFetch] forKey:@"last_update"];
	[dict setObject:[NSNumber numberWithInt:(newEventsID != 0 ? newEventsID : eventsID)] forKey:@"eventsID"];
	
	[dict writeToFile:filePath atomically:YES];
	
	[dict release];
}

- (BOOL) hasNewEvents {
	return eventsID != newEventsID && newEventsID != 0;
}

- (NSArray *)getEvents {
	if(status == EventManagerStatusIdle)
		return [NSArray arrayWithArray:events];
	else
		return nil;
}

- (int) getRealEventsID {
	if(newEventsID != 0)
		return newEventsID;
	else
		return eventsID;
}

- (void) dealloc {
	[events release];
	[super dealloc];
}

@end
