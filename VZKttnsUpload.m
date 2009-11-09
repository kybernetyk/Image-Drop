//
//  KttnsClient.m
//  ImgDrop
//
//  Created by jrk on 20.07.09.
//  Copyright 2009 flux forge. All rights reserved.
//

#import "VZKttnsUpload.h"


@implementation VZKttnsUpload
@synthesize username, password, salt;
#import <CommonCrypto/CommonDigest.h>


NSString * md5( NSString *str )
{
	const char *cStr = [str UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	
	CC_MD5( cStr, strlen(cStr), result );

	return [NSString 
			stringWithFormat: @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1],
			result[2], result[3],
			result[4], result[5],
			result[6], result[7],
			result[8], result[9],
			result[10], result[11],
			result[12], result[13],
			result[14], result[15]
		];
	
}


- (id) initWithUsername: (NSString *) _username Password: (NSString *) _password Salt: (NSString *)_salt
{
	self = [super init];
	if (self)
	{
		[self setUsername: _username];
		[self setPassword: _password];
		[self setSalt: _salt];
	}
	
	return self;
}

- (void) dealloc
{
	NSLog(@"KTTNS UPLOAD DEALLOC!");
	
	[username release];
	[password release];
	[salt release];
	
	[super dealloc];
}

- (void) auth
{
//	command = '/usr/bin/curl -d username="' + username + '" -d password="' + password_hashed + '" ' + auth_url;
//    document.getElementById("status").object.setValue(10);
    
//    login = widget.system(command, null).outputString;
	NSString *rawpass = [NSString stringWithFormat:@"%@%@",salt,password];
	NSString *hashedpass = md5(rawpass);

	NSLog(@"authing with hashed pass: %@",hashedpass);
	
	
	
	
	
	NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString: @"http://kttns.org/login.php"]
														 cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
													 timeoutInterval:10.0];
	
	[request setHTTPMethod: @"POST"];
	[request setCachePolicy: NSURLRequestReloadIgnoringLocalCacheData];
	[request setHTTPShouldHandleCookies: NO];

	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	
	

	NSMutableData *postBody = [NSMutableData data];
	[postBody appendData:[[NSString stringWithFormat:@"username=%@&password=%@", username,hashedpass] dataUsingEncoding:NSUTF8StringEncoding]];
	[request setHTTPBody: postBody];
	

	
	NSURLResponse *response = [[[NSURLResponse alloc] init] autorelease];
	NSError *error = [[[NSError alloc] init] autorelease];
	
	NSData *ret = [NSURLConnection sendSynchronousRequest: request returningResponse: &response error: &error];
	NSString *str = [[NSString alloc] initWithData: ret encoding:NSUTF8StringEncoding];
	
	NSLog(@"auth returned: %@",str);
	
	[str release];
	
}

- (void) performUpload
{
	if (!data || !filename)
	{
		NSLog(@"error: data or filename not set! data: %@ filename: %@",data,filename);
		return;
	}
	
	NSLog(@"perofming upload with data length %i",[data length]);
	[self auth];
	
	[self setUrlOfUploadHost: @"http://kttns.org"];

	NSURLRequest *req = [self buildUploadRequest];
	
	[[[NSURLConnection alloc] initWithRequest:req delegate:self] autorelease];
}


- (void) processReturnValue: (NSString *) returnValue
{
	NSLog(@"processing return val: %@",returnValue);
	
	[self messageDelegateSuccess: [NSString stringWithFormat:@"http://kttns.org/%@",returnValue]];
}



- (NSURLRequest *) buildUploadRequest
{
	NSString *rawpass = [NSString stringWithFormat:@"%@%@",salt,password];
	NSString *hashedpass = md5(rawpass);
	NSString *boundary = @"----------------------------592d224d1f3a";
	
	NSURL *_url = [NSURL URLWithString: [self urlOfUploadHost]];
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:_url];
	[req setHTTPMethod:@"POST"];
	[req setCachePolicy: NSURLRequestReloadIgnoringLocalCacheData];
	[req setHTTPShouldHandleCookies: NO];
	
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
	[req setValue:contentType forHTTPHeaderField:@"Content-type"];
	

	
	//adding the body:
	NSMutableData *postBody = [[NSMutableData alloc] init];
	[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"upload\"; filename=\"%@\"\r\n", filename] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData: data];
	
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[@"Content-Disposition: form-data; name=\"username\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[username dataUsingEncoding:NSUTF8StringEncoding]];
	
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[@"Content-Disposition: form-data; name=\"password\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[hashedpass dataUsingEncoding:NSUTF8StringEncoding]];
	
	
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--",boundary] dataUsingEncoding:NSUTF8StringEncoding]];	
	[req setHTTPBody: postBody];
	
	[postBody release];
	
	return req;
}

@end
