/*
 * SCJSONPConnection.j
 * SCKit
 *
 * Created by Aparajita Fishman.
 * Copyright (c) 2010, Victory-Heart Productions.
 *
 * Released under the MIT license:
 * http://www.opensource.org/licenses/MIT
*/

@import <Foundation/CPJSONPConnection.j>

@import "_SCConnection.j"
@import "SCConnectionUtils.j"


/*!
    SCJSONPConnection is a drop-in replacement for CPJSONPConnection which provides
    more streamlined usage, automates common tasks like caching received data,
    and deals with some of the more tricky aspects of error handling.

    For more details, see the documentation for SCURLConnection.
*/
@implementation SCJSONPConnection : CPJSONPConnection
{
    _SCConnection base;
}

+ (SCJSONPConnection)connectionWithRequest:(CPURLRequest)aRequest delegate:(id)aDelegate
{
    return [[[self class] alloc] initWithRequest:aRequest callback:@"callback" delegate:aDelegate identifier:@"" startImmediately:YES];
}

+ (SCJSONPConnection)connectionWithRequest:(CPURLRequest)aRequest callback:(CPString)callbackParameter delegate:(id)aDelegate
{
    return [[[self class] alloc] initWithRequest:aRequest callback:callbackParameter delegate:aDelegate identifier:@"" startImmediately:YES];
}

+ (SCJSONPConnection)connectionWithRequest:(CPURLRequest)aRequest delegate:(id)aDelegate identifier:(CPString)anIdentifier
{
    return [[[self class] alloc] initWithRequest:aRequest callback:@"callback" delegate:aDelegate identifier:anIdentifier startImmediately:YES];
}

+ (SCJSONPConnection)connectionWithRequest:(CPURLRequest)aRequest callback:(CPString)callbackParameter delegate:(id)aDelegate identifier:(CPString)anIdentifier
{
    return [[[self class] alloc] initWithRequest:aRequest callback:callbackParameter delegate:aDelegate identifier:anIdentifier startImmediately:YES];
}

- (id)initWithRequest:(CPURLRequest)aRequest callback:(CPString)callbackParameter delegate:(id)aDelegate identifier:(CPString)anIdentifier startImmediately:(BOOL)shouldStartImmediately
{
    base = [_SCConnection new];
    self = [super initWithRequest:aRequest callback:callbackParameter delegate:base startImmediately:NO];

    if (self)
        [self _initWithIdentifier:anIdentifier delegate:aDelegate startImmediately:shouldStartImmediately];

    return self;
}

- (void)_initWithIdentifier:(CPString)anIdentifier delegate:(id)aDelegate startImmediately:(BOOL)shouldStartImmediately
{
    [base initWithConnection:self identifier:anIdentifier delegate:aDelegate startImmediately:shouldStartImmediately];
}

/*!
    Returns 200 if the connection succeeded without error, otherwise the response code.
*/
- (int)responseStatus
{
    return [base responseStatus];
}

/*!
    Returns the JSON data received from the connection response. Note that unlike SCURLConnection,
    this always returns JSON data, since by definition a JSONP connection returns JSON.
*/
- (CPString)receivedData
{
    return [base receivedData];
}

/*!
    Returns the JSON data received from the connection response.
*/
- (JSObject)receivedJSONData
{
    return [base receivedJSONData];
}

/*!
    @ignore
*/
- (void)connection:(SCURLConnection)connection didFailWithError:(id)error
{
    [base connection:connection didFailWithError:error];
}

@end
