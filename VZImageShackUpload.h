//
//  VZImageShackUpload.h
//  ImgDrop
//
//  Created by jrk on 14/11/09.
//  Copyright 2009 flux forge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "VZUpload.h"

#define kImageShackDeveloperKey @"0BDGRTVX2c679f15f6a1c13b8484442935663c85"

/**
 @brief Upload client for imageShack.us
 @discussion This is just a really simple and stupid upload client. 
 It won't use any username/password information. Imageshack sucks and is just a fallback hoster.
 Use Kttns!
 */
@interface VZImageShackUpload : VZUpload
{

}
@end


@interface VZImageShackUpload (private)

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
