/*
 *  SCURLConnection.j
 *
 *  Created by Aparajita on 8/9/10.
 *  Copyright Victory-Heart Productions 2010. All rights reserved.
*/

@import <Foundation/CPURLConnection.j>

@import "SCConnectionUtils.j"


@implementation SCURLConnection : CPURLConnection
{
    int         responseStatus;
    id          delegate;
    CPString    selectorPrefix;
    CPString    receivedData  @accessors(readonly);
}

+ (SCURLConnection)connectionWithRequest:(CPURLRequest)aRequest delegate:(id)aDelegate
{
    return [[self alloc] initWithRequest:aRequest delegate:aDelegate identifier:@"" startImmediately:YES];
}

+ (SCURLConnection)connectionWithRequest:(CPURLRequest)aRequest delegate:(id)aDelegate identifier:(CPString)anIdentifier
{
    return [[self alloc] initWithRequest:aRequest delegate:aDelegate identifier:anIdentifier startImmediately:YES];
}

- (id)initWithRequest:(CPURLRequest)aRequest delegate:(id)aDelegate startImmediately:(BOOL)shouldStartImmediately
{
    var self = [super initWithRequest:aRequest delegate:self startImmediately:NO];

    if (self)
        [self _initWithIdentifier:@"" delegate:aDelegate startImmediately:shouldStartImmediately];

    return self;
}

- (id)initWithRequest:(CPURLRequest)aRequest delegate:(id)aDelegate identifier:(CPString)anIdentifier startImmediately:(BOOL)shouldStartImmediately
{
    var self = [super initWithRequest:aRequest delegate:self startImmediately:NO];

    if (self)
        [self _initWithIdentifier:anIdentifier delegate:aDelegate startImmediately:shouldStartImmediately];

    return self;
}

- (void)_initWithIdentifier:(CPString)anIdentifier delegate:(id)aDelegate startImmediately:(BOOL)shouldStartImmediately
{
    responseStatus = 200;
    delegate = aDelegate;
    receivedData = "";

    if ([anIdentifier length] === 0)
        selectorPrefix = @"connection";
    else
        selectorPrefix = anIdentifier + @"Connection";

    if (shouldStartImmediately)
        [self start];
}

- (void)connection:(SCURLConnection)connection didReceiveResponse:(CPHTTPURLResponse)response
{
    responseStatus = [response statusCode];
    receivedData = @"";
}

- (void)connection:(SCURLConnection)connection didReceiveData:(CPString)data
{
    receivedData += data;

    if (responseStatus != 200)
        return;

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

- (void)connectionDidFinishLoading:(SCURLConnection)connection
{
    if (responseStatus == 200)
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
    else
        [self _connection:connection didFailWithError:responseStatus];
}

- (void)connection:(SCURLConnection)connection didFailWithError:(id)error
{
    [self _connection:connection didFailWithError:503];  // Service Unavailable
}

- (void)_connection:(SCURLConnection)connection didFailWithError:(id)error
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

- (void)_handleException:(CPException)aException connection:(SCURLConnection)connection
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
