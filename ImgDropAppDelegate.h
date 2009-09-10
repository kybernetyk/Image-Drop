//
//  ImgDropAppDelegate.h
//  ImgDrop
//
//  Created by jrk on 19.07.09.
//  Copyright 2009 flux forge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PreferencesWindowController.h"

@interface ImgDropAppDelegate : NSObject 
{
	PreferencesWindowController *preferencesWindowController;
	
	NSMutableDictionary *uploadTrackingDictionary;
}

//- (BOOL) uploadData: (NSData *)data withFilename: (NSString *) filename;
- (BOOL) uploadData: (NSData *)data withFilename: (NSString *) filename;

- (IBAction) openPreferences: (id) sender;
@end
