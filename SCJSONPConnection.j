/*
 *  SCJSONPConnection.j
 *
 *  Created by Aparajita on 8/19/10.
 *  Copyright Victory-Heart Productions 2010. All rights reserved.
*/

@import <Foundation/CPJSONPConnection.j>

@import "SCConnectionUtils.j"


@implementation SCJSONPConnection : CPJSONPConnection
{
    id          delegate;
    CPString    selectorPrefix;
    id          receivedData  @accessors(readonly);
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
    var self = [super initWithRequest:aRequest callback:callbackParameter delegate:self startImmediately:NO];

    if (self)
        [self _initWithIdentifier:anIdentifier delegate:aDelegate startImmediately:shouldStartImmediately];

    return self;
}

- (void)_initWithIdentifier:(CPString)anIdentifier delegate:(id)aDelegate startImmediately:(BOOL)shouldStartImmediately
{
    delegate = aDelegate;
    receivedData = nil;

    if ([anIdentifier length] === 0)
        selectorPrefix = @"connection";
    else
        selectorPrefix = anIdentifier + @"Connection";

    if (shouldStartImmediately)
        [self start];
}

- (void)connection:(SCJSONPConnection)connection didReceiveData:(id)data
{
    receivedData = data;

    var selector = CPSelectorFromString(selectorPrefix + @":didReceiveData:");

    if ([delegate respondsToSelector:selector])
    {
        try
        {
            [delegate performSelector:selector withObject:connection withObject:data];
        }
        catch (anException)
        {
            [self _handleException:anException connection:connection];
        }
    }
}

- (void)connectionDidFinishLoading:(SCJSONPConnection)connection
{
    var selector = CPSelectorFromString(selectorPrefix + @"DidSucceed:");

    if ([delegate respondsToSelector:selector])
    {
        try
        {
            [delegate performSelector:selector withObject:connection];
        }
        catch (anException)
        {
            [self _handleException:anException connection:connection];
        }
    }
}

- (void)connection:(SCJSONPConnection)connection didFailWithError:(id)error
{
    [self _connection:connection didFailWithError:error];
}

- (void)_connection:(SCJSONPConnection)connection didFailWithError:(id)error
{
    var selector = CPSelectorFromString(selectorPrefix + @":didFailWithError:");

    if ([delegate respondsToSelector:selector])
    {
        [delegate performSelector:selector withObject:connection withObject:error];
        return;
    }

    [self alertFailureWithError:error delegate:nil];
}

- (void)alertFailureWithError:(id)error
{
    [self alertFailureWithError:error delegate:nil];
}

- (void)alertFailureWithError:(id)error delegate:(id)aDelegate
{
    var alert = [[CPAlert alloc] init];

    [alert setDelegate:aDelegate];
    [alert setTitle:@"Connection Failed"];
    [alert setMessageText:[self errorMessageForError:error]];
    [alert addButtonWithTitle:@"OK"];
    [alert runModal];
}

- (void)_handleException:(CPException)aException connection:(SCJSONPConnection)connection
{
    var error,
        type = typeof(anException);

    if (type === "string" || type === "number")
        error = anException;
    else if (type === "object" && anException.hasOwnProperty("message"))
        error = @"An error occurred when receiving data: " + anException.message;
    else
        error = -1;

    [self _connection:connection didFailWithError:error];
}

- (CPString)errorMessageForError:(id)error
{
    return [SCConnectionUtils errorMessageForError:error];
}

@end
