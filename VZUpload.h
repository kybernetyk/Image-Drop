//
//  UploadClient.h
//  ImgDrop
//
//  Created by jrk on 20.07.09.
//  Copyright 2009 flux forge. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface VZUpload : NSObject 
{
	id delegate;
	
	NSString *urlOfUploadHost;
	
	NSString *filename; //filename of the file to upload (will be POSTed to the hoster!)
	NSData *data; //the data to upload
	
	NSDictionary *uploadMetaInformation;
}

@property (readwrite, assign) id delegate;
@property (readwrite, copy) NSDictionary *uploadMetaInformation;

@property (readwrite, copy) NSData *data;
@property (readwrite, copy) NSString *filename;


- (void) performUpload;
@end

#pragma mark -
#pragma mark Private methods and properties
@interface VZUpload (private)
@property (readwrite, copy) NSString *urlOfUploadHost;

- (NSURLRequest *) buildUploadRequest;
- (void) messageDelegateSuccess: (NSString *) urlOfUploadedPicture;
@end