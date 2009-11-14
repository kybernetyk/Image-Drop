//
//  UploadClient.h
//  ImgDrop
//
//  Created by jrk on 20.07.09.
//  Copyright 2009 flux forge. All rights reserved.
//

#import <Cocoa/Cocoa.h>


/**
 @brief our abstract class for the different hosters.
 */
@interface VZUpload : NSObject 
{
	id delegate;
	
	NSString *urlOfUploadHost;
	
	NSString *filename; //filename of the file to upload (will be POSTed to the hoster!)
	NSData *data; //the data to upload
	
	NSDictionary *uploadMetaInformation;
}

@property (readwrite, assign) id delegate;

/**
 @brief here you can store all meta information you want to pass later to the delegate.
 @discussion currently supported keys:
 BOOL shouldOpenSummaryWindow: tells the delegate if it should open a summary window when the upload is finished.
 BOOL shouldOpenUploadedFileInBrowser: tells the delegate if it should open a safari instance and point it to the uploaded file
 */
@property (readwrite, copy) NSDictionary *uploadMetaInformation;

/**
 @brief the image data. (or any other file ... not all hosters will support anything other than images.)
 */
@property (readwrite, copy) NSData *data;

/**
 @brief the file name of the file. many hosters will name the uploaded file after this property
 */
@property (readwrite, copy) NSString *filename;

/**
 @brief after setting up all options you should call this to begin the upload.
 */
- (void) performUpload;
@end

#pragma mark -
#pragma mark Private methods and properties
@interface VZUpload (private)
@property (readwrite, copy) NSString *urlOfUploadHost;

- (NSURLRequest *) buildUploadRequest;
- (void) messageDelegateSuccess: (NSString *) urlOfUploadedPicture;
@end