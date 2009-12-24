//
//  VZTwittPicUpload.h
//  ImgDrop
//
//  Created by jrk on 24/12/09.
//  Copyright 2009 flux forge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VZUpload.h"

@interface VZTwittPicUpload : VZUpload 
{
	NSString *username;
	NSString *password;
	NSString *message;
}

/**
 @brief the user's username with kttns
 */
@property (readwrite, copy) NSString *username;

/**
 @brief user's password with kttns
 */
@property (readwrite, copy) NSString *password;

/**
 @brief the message sent to twitter
 */
@property (readwrite, copy) NSString *message;


- (id) initWithUsername: (NSString *) _username Password: (NSString *) _password;


@end


@interface VZTwittPicUpload (private)

/**
 @brief creates multipart POST fields from a NSDictionary. just append this as the http body to your NSURLRequest
 @discussion cocoa really needs a modern NSURLConnection. Something with accurate progress reports
 and a fucking easy to use header/body-managment in NSURLRequest.
 */
- (NSData *)dataForPOSTWithDictionary:(NSDictionary *)aDictionary boundary:(NSString *)aBoundary;


@end
