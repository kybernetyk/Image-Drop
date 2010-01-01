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

