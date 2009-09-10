//
//  KttnsClient.h
//  ImgDrop
//
//  Created by jrk on 20.07.09.
//  Copyright 2009 flux forge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "UploadClient.h"

@interface KttnsClient : UploadClient 
{
	NSString *username;
	NSString *password;
	NSString *salt;
}
@property (readwrite, copy) NSString *username;
@property (readwrite, copy) NSString *password;
@property (readwrite, copy) NSString *salt;

- (id) initWithUsername: (NSString *) _username Password: (NSString *) _password Salt: (NSString *)_salt;

@end
