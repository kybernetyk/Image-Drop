//
//  UploadClient.h
//  ImgDrop
//
//  Created by jrk on 20.07.09.
//  Copyright 2009 flux forge. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface UploadClient : NSObject 
{
	id delegate;
	
	NSString *fileToUpload;
	NSString *urlOfUploadHost;
}

@property (readwrite, assign) id delegate;
@property (readwrite, copy) NSString *fileToUpload;
@property (readwrite, copy) NSString *urlOfUploadHost;

- (void) performUploadWithData: (NSData *) data andFilename: (NSString *) filename;

- (void) messageDelegateSuccess: (NSString *) urlOfUploadedPicture;

- (NSMutableURLRequest *) buildUploadRequestWithURL: (NSString *) url Data: (NSData *) data andFilename: (NSString *) filename;

@end
