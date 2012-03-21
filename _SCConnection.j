/*
 * _SCConnection.j
 * SCKit
 *
 * Created by Aparajita Fishman.
 * Copyright (c) 2010, Victory-Heart Productions.
 *
 * Released under the MIT license:
 * http://www.opensource.org/licenses/MIT
*/

@import <Foundation/CPObject.j>

@import "SCConnectionUtils.j"


/*
    This is a base implementation class for SCURLConnection and SCJSONPConnection.
    Those classes forward method calls to an instance of this class.
*/
@implementation _SCConnection : CPObject
{
    int         responseStatus;
    id          connection;
    id          delegate;
    CPString    selectorPrefix;
    CPString    receivedData;
}

- (void)initWithConnection:(id)aConnection identifier:(CPString)anIdentifier delegate:(id)aDelegate startImmediately:(BOOL)shouldStartImmediately
{
    connection = aConnection;
    responseStatus = 200;
    delegate = aDelegate;
    receivedData = "";

    if ([anIdentifier length] === 0)
        selectorPrefix = @"connection";
    else
        selectorPrefix = anIdentifier + @"Connection";

    if (shouldStartImmediately)
        [aConnection start];
}

- (void)connection:(id)connection didReceiveResponse:(CPHTTPURLResponse)response
{
    responseStatus = [response statusCode];
    receivedData = @"";
}

- (void)connection:(id)connection didReceiveData:(CPString)data
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

- (void)connectionDidFinishLoading:(id)connection
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

- (int)responseStatus
{
    return responseStatus
}

- (id)delegate
{
    return delegate;
}

- (void)start
{
    [connection start];
}

- (void)cancel
{
    [connection cancel];
}

- (void)removeScriptTag
{
    [connection removeScriptTag];
}

- (CPString)receivedData
{
    return receivedData;
}

- (JSObject)receivedJSONData
{
    return [receivedData objectFromJSON];
}

- (void)connection:(id)connection didFailWithError:(id)error
{
    [self _connection:connection didFailWithError:503];  // Service Unavailable
}

- (void)_connection:(id)connection didFailWithError:(id)error
{
    var selector = CPSelectorFromString(selectorPrefix + @":didFailWithError:");

    if ([delegate respondsToSelector:selector])
    {
        [delegate performSelector:selector withObject:connection withObject:error];
        return;
    }

    [SCConnectionUtils alertFailureWithError:error delegate:nil];
}

- (void)_handleException:(CPException)aException connection:(id)connection
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

@end
