//
//  ImgDropAppDelegate.m
//  ImgDrop
//
//  Created by jrk on 19.07.09.
//  Copyright 2009 flux forge. All rights reserved.
//

#import "ImgDropAppDelegate.h"
#import "VZKttnsUpload.h"
#import "VZUpload.h"
#import "NSData+zlib.h"
#import "UploadSummaryWindowController.h"
#import "VZImageShackUpload.h"
#import "VZTwittPicUpload.h"
#import "VZHtlrUpload.h"

@implementation ImgDropAppDelegate

/**
 takes an NSData and creates a zip file from it.
 filename is the file's name within the created zip.
 
 the zip itself will have a random filename
 
*/
-(NSData*)zip:(NSData *) data withFilename: (NSString *) filename //raw must be NSData or NSFileWrapper
{
	NSString* scratchFolder =  @"/tmp/";//[NSHomeDirectory() stringByAppendingPathComponent: @"Desktop/"];
	
	srand(time(0));	
	NSString* sourceFilename = filename;
	NSString* targetFilename = [NSString stringWithFormat:@"%x-%x-%x-%x-zipped",rand()%0xffff,rand()%0xffff,rand()%0xffff,rand()%0xffff];

	
	NSString* sourcePath =[scratchFolder stringByAppendingPathComponent: sourceFilename];
	NSString* targetPath =[scratchFolder stringByAppendingPathComponent: targetFilename];
	
	
	BOOL flag = NO;
	
	
//	if( [data isKindOfClass:[NSData class]] )
	flag = [data writeToFile:sourcePath atomically:YES];
	
	/*
	else 	if( [data isKindOfClass:[NSFileWrapper class]] )
		flag = [data writeToFile:sourcePath atomically:YES updateFilenames:YES];*/
	
	
	if( flag == NO )
	{
		NSLog(@"Fail to write.");
		return nil;
	}
	
	/* Assumes sourcePath and targetPath are both
	 valid, standardized paths. */
	
	
	
	//----------------
	// Create the zip task
	NSTask *backupTask = [[NSTask alloc] init];
	[backupTask setLaunchPath:@"/usr/bin/ditto"];
	[backupTask setArguments:
	 [NSArray arrayWithObjects:@"-c", @"-k", @"-X", @"--rsrc", 
	  sourcePath, targetPath, nil]];
	
	// Launch it and wait for execution
	[backupTask launch];
	[backupTask waitUntilExit];
	
	// Handle the task's termination status
	if ([backupTask terminationStatus] != 0)
	{
		NSLog(@"Sorry, didn't work.");
		[backupTask release];
		return nil;
	}
	
	[backupTask release];
	
	
	NSData* convertedData = [[[NSData alloc] initWithContentsOfFile:targetPath] autorelease];
	
	
	[[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceDestroyOperation
												 source:scratchFolder
											destination:@"" 
												  files:[NSArray arrayWithObjects:sourceFilename, targetFilename,NULL]
													tag:NULL];
	
	
	return convertedData;
}


-(void)doString:(NSPasteboard *)pboard userData:(NSString *)userData error:(NSString **)error 
{
	//[NSApp hide: self];
	
    NSArray *a = [pboard readObjectsForClasses: [NSArray arrayWithObject:[NSURL class]]
                          options:[NSDictionary dictionaryWithObject:[NSNumber
                                                                      numberWithBool:YES] forKey: NSPasteboardURLReadingFileURLsOnlyKey]];

//    NSLog(@"array: %@", a);
    
    NSURL *u = nil;
    
    if ([a count] > 0)
       u = [a objectAtIndex: 0];//[NSURL URLFromPasteboard: pboard];
    
//    NSLog(@"url: %@", u);
//    
    NSLog(@"furl: %@",[u filePathURL]);
    
 	
	NSPasteboardItem *item = [[pboard pasteboardItems] objectAtIndex: 0];
    NSLog(@"Item: %@", item);
    
	NSString *type = [[item types] objectAtIndex: 0];
	NSLog(@"types: %@", [item types]);
    
	//NSLog(@"items: %@",[pboard pasteboardItems]);
	//NSLog(@"types: %@", [item types]);
	
	NSData *data = [NSData dataWithData: [item dataForType: type]];
	NSString *fname = @"a_picture.png";
	BOOL openSummary = NO;
	
	[pboard releaseGlobally];
	
	if (!data)
		return;

	[pboard clearContents];

	if ([type isEqualToString:@"org.liscio.itun"])
	{
		
		NSString *errorDesc = nil;
		NSPropertyListFormat format;
		NSDictionary *dict = (NSDictionary*)[NSPropertyListSerialization
											 propertyListFromData:data
											 mutabilityOption:NSPropertyListMutableContainersAndLeaves
											 format:&format
											 errorDescription:&errorDesc];
		
		NSArray *playlists = [dict objectForKey:@"Playlists"];
		NSDictionary *playlistEntry0 = [playlists objectAtIndex: 0];
		NSArray *playlistItems = [playlistEntry0 objectForKey:@"Playlist Items"];
		NSDictionary *thefuckingTrack = [playlistItems objectAtIndex: 0];
		NSNumber *trackID = [thefuckingTrack objectForKey:@"Track ID"];
		
		NSLog(@"track id: %@",trackID);
		
		
		NSDictionary *track = [[dict objectForKey:@"Tracks"] objectForKey: [trackID stringValue]];
		
		NSString *filename = [track objectForKey:@"Location"];
		
		NSLog(@"itunes musik: %@",filename);
		
		/*NSDictionary *tracks = [dict objectForKey:@"Tracks"];
		 
		 for (NSDictionary *track in tracks)
		 {
		 NSLog(@"%@",track);
		 }
		 
		 [dict writeToFile:@"/blabla.plist" atomically: NO];*/
		
		
		//	NSLog(@"ITUNES! %@",dict);
		
		type = @"public.file-url";
		data = [filename dataUsingEncoding: NSUTF8StringEncoding];
		
//		NSLog(@"%@",data);
	}
	
	
	if ([type isEqualToString:@"public.file-url"])
	{
		NSString *filename = [[u filePathURL] absoluteString];
        
        /*[[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] autorelease];*/
		NSString *extension = [filename pathExtension];
		fname = [[filename pathComponents] lastObject];

		
		NSLog(@"dropped public.file-url: %@",filename);

		NSURL *url = [NSURL URLWithString: filename];  //[NSURL URLFromPasteboard: pboard];
		data = [NSData dataWithContentsOfURL: url];
		

		NSLog(@"data len %i",[data length]);
		
		NSArray *extensionsThatMustBeZipped = [NSArray arrayWithObjects:
											   @"mp3",
											   @"aac",
											   @"txt",
											   @"cc",
											   @"cpp",
											   @"c",
											   @"zip",
											   @"rar",
											   @"m4a",
											   @"gz",
											   @"tar",
											   @"m4p",
											   @"pdf",
											   @"dmg",
											   @"plist",
											   @"rtf",
											   @"html",
											   @"htm",
											   @"php",
											   @"js",
											   @"tiff",
											   nil];
		
		
		BOOL fileMustBeZipped = NO;
		for (NSString *ext in extensionsThatMustBeZipped)
		{
			if ([[extension lowercaseString] isEqualToString: ext])
				fileMustBeZipped = YES;
		}
		
		if (fileMustBeZipped)
		{
			data = [self zip: data withFilename: [fname stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
			
			fname = [fname stringByAppendingString:@".zip"];
			openSummary = YES;
		}
	}
	else if ([type isEqualToString:@"public.tiff"])
	{
		NSLog(@"dropped public.tiff type! converting data to png ...");
		
		NSImage *img = [[NSImage alloc] initWithData: data];
		NSBitmapImageRep *rep = [[img representations] objectAtIndex: 0];
		
		data = [rep representationUsingType: NSPNGFileType properties: nil];
		[img autorelease];
		
	
		srand(time(0));
		fname = [NSString stringWithFormat:@"%x-%x-%x-%x.png",rand()%0xffff,rand()%0xffff,rand()%0xffff,rand()%0xffff];
		openSummary = NO;
	}
	
	
	if (!data)
		return;
	
	fname = [fname stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
	
	VZUpload *upload = [self newUploadInstance];
	if (upload)
	{
		NSLog(@"uploading %@ with %@",fname, [upload className]);
		
		if ([upload shouldApplicationHideOnDroppingImage])
			[NSApp hide: self];
		
		[upload setDelegate: self];
		
		//NSLog(@"upload: %@",upload);
	
		NSMutableDictionary *uploadInfo = [NSMutableDictionary dictionary];
		[uploadInfo setValue:[NSNumber numberWithBool: openSummary] forKey:@"shouldOpenSummaryWindow"];
		[uploadInfo setValue:[NSNumber numberWithBool: !openSummary] forKey:@"shouldOpenUploadedFileInBrowser"];
		
		[upload setUploadMetaInformation: uploadInfo];
		[upload setFilename: fname];
		[upload setData: data];
		
		
	//	[upload performUploadWithData: data andFilename: fname];
		[upload performUpload];
	}
	else 
	{
		[NSApp hide: self];
	}

	
}




-(void)applicationDidFinishLaunching:(NSNotification *)aNotification 
{
	NSLog(@"applicationDidFinishLaunching");
	
	[NSApp setServicesProvider:self];

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys: 
								 @"imgShack",@"service",
								 @"",@"username",
								 @"", @"password", 
								 nil]; //esc + space

	[userDefaults registerDefaults:appDefaults];
	
	
}

/*- (BOOL) uploadData: (NSData *)data withFilename: (NSString *) filename
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	NSString *service = [userDefaults stringForKey:@"service"];
	NSString *username = [userDefaults stringForKey:@"username"];
	NSString *password = [userDefaults stringForKey:@"password"];

	VZUpload *upc = nil;
	
	if ([service isEqualToString:@"Localhostr"])
		upc = [[LocalhostrClient alloc] init];
	else if ([service isEqualToString:@"Kttns"])
		upc = [[VZKttnsUpload alloc] initWithUsername: username Password: password Salt: @"b8bb08c8b863465fcbbd74c15a08abcf"];
	
	[upc setDelegate: self];
	[upc performUploadWithData: data andFilename: filename];
	
	[NSApp hide: self];
	return YES;
}*/

/*
 returns an VZUpload subclass
*/
- (VZUpload *) newUploadInstance
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	NSString *service = [userDefaults stringForKey:@"service"];
	NSString *username = [userDefaults stringForKey:@"username"];
	NSString *password = [userDefaults stringForKey:@"password"];

	VZUpload *upc = nil;
	
	if ([service isEqualToString:@"Kttns"])
		upc = [[VZKttnsUpload alloc] initWithUsername: username Password: password Salt: @"b8bb08c8b863465fcbbd74c15a08abcf"];
	else if ([service isEqualToString:@"imgShack"])
		upc = [[VZImageShackUpload alloc] init];
	else if ([service isEqualToString:@"Htlr"])
		upc = [[VZHtlrUpload alloc] init];
	else if ([service isEqualToString:@"Twitt Pic"])
		upc = [[VZTwittPicUpload alloc] initWithUsername: username Password: password];
	
	return upc;
}

/*
 - (void)centerWindow
 {
 NSRect visibleFrame = [[NSScreen mainScreen] visibleFrame];
 NSRect windowFrame = [self frame];
 [self setFrame:NSMakeRect((visibleFrame.size.width - windowFrame.size.width) * 0.5,
 (visibleFrame.size.height - windowFrame.size.height) * (9.0/10.0),
 windowFrame.size.width, windowFrame.size.height) display:YES];
 }*/

- (IBAction) openPreferences: (id) sender
{
	if (!preferencesWindowController)
	 preferencesWindowController = [[PreferencesWindowController alloc] initWithWindowNibName:@"PreferencesWindow"];
	 
	// [[preferencesWindowController window] center];
	 [preferencesWindowController showWindow: self];

	
}

#pragma mark Imagehoster Client delegate
- (void) uploadClient: (id) aClient fileUploadSuccess: (BOOL) succeeded withReturnedURL: (NSString *) url
{
	NSDictionary *uploadInfo = [aClient uploadMetaInformation];
	
	//open summary window
	if ([[uploadInfo valueForKey: @"shouldOpenSummaryWindow"] boolValue])
	{
		NSLog(@"the file %@ was uploaded to the url %@",[aClient filename],url);
		[NSApp activateIgnoringOtherApps: YES];
		
	 	UploadSummaryWindowController *uswc = [[UploadSummaryWindowController alloc] initWithWindowNibName:@"UploadSummaryWindow"];
		//the UploadSummaryWindowController will autorelease itself when its window is closed
		//ignore the clang analyzer's bitching about this line.
		//don't believe? look into UploadSummaryWindowController.m in - (void)windowWillClose:(NSNotification *)notification
		
		
		[[uswc window] center];
		[[uswc window] makeKeyAndOrderFront: self];
		[uswc showWindow: self];
		
		[[uswc summaryLabel] setStringValue: [NSString stringWithFormat:@"File %@ was uploaded to:",[aClient filename]]];
		[[uswc window] setTitle: [aClient filename]];
		[[uswc summaryTextField] setStringValue: url];
		[[uswc summaryTextField] selectText: self];
	}

	//redirect to teh brauser
	if ([[uploadInfo valueForKey: @"shouldOpenUploadedFileInBrowser"] boolValue])	
	{
		url = [url stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
 		NSURL *_url = [NSURL URLWithString: url];
		[[NSWorkspace sharedWorkspace] openURL: _url];
	}


	[aClient autorelease];

}

- (void) uploadClientfileUploadDidFail: (id) aClient
{
	NSLog(@"upload for %@ failed!", [aClient filename]);
	[aClient autorelease];
}

@end
