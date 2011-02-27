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

@property (readwrite, copy) NSString *urlOfUploadHost;


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

#pragma mark -
#pragma mark mandatory override

/**
 @brief our post fields for the particular hoster
 */
- (NSDictionary *) postFields;

/**
 @brief the url of the upload endpoint for our hoster
 */
- (NSString *) hostUploadURL;


#pragma mark -
#pragma mark optional override
/**
 @brief perform auth with our hoster
 */
- (void) auth;

/**
 @brief should the app hide after something was dropped on the dock item?
 */
- (BOOL) shouldApplicationHideOnDroppingImage;


@end

#pragma mark -
#pragma mark Private methods and properties
@interface VZUpload (private)

- (NSURLRequest *) buildUploadRequestWithPostFields: (NSDictionary *) postFields;

- (void) messageDelegateSuccess: (NSString *) urlOfUploadedPicture;
- (void) messageDelegateFailure;

/**
 @brief creates multipart POST fields from a NSDictionary. just append this as the http body to your NSURLRequest
 @discussion cocoa really needs a modern NSURLConnection. Something with accurate progress reports
 and a fucking easy to use header/body-managment in NSURLRequest.
 */
- (NSData *)dataForPOSTWithDictionary:(NSDictionary *)aDictionary boundary:(NSString *)aBoundary;


/**
 @brief Guesses the content type for multiform post from the filenames path extension
 @discussion I told you imageShack would suck. And this is one reason: is.us does not support
 application/octet-stream as content-type. so we have to "guess" the data.
 yeah, IS could parse the uploaded files themselve but they don't.
 */
- (NSString *) guessedContentType;



@end