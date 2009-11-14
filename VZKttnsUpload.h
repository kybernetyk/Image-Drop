//
//  KttnsClient.h
//  ImgDrop
//
//  Created by jrk on 20.07.09.
//  Copyright 2009 flux forge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "VZUpload.h"

/**
 @brief KTTNS.ORG upload client. you need an account for kttns.
 */
@interface VZKttnsUpload : VZUpload 
{
	NSString *username;
	NSString *password;
	NSString *salt;
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
 @brief a salt. this is an API key issued from kttns.
 */
@property (readwrite, copy) NSString *salt;

/**
 @brief the designated initializer for this uploader. DO NOT USE ANY OTHER INITIALIZER OR YOU WILL END IN HELL!
 */
- (id) initWithUsername: (NSString *) _username Password: (NSString *) _password Salt: (NSString *)_salt;

@end
