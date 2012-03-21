/*
 * SCURLConnection.j
 * SCKit
 *
 * Created by Aparajita Fishman.
 * Copyright (c) 2010, Victory-Heart Productions.
 *
 * Released under the MIT license:
 * http://www.opensource.org/licenses/MIT
*/

@import <Foundation/CPURLConnection.j>

@import "_SCConnection.j"
@import "SCConnectionUtils.j"


/*!
    SCURLConnection is a drop-in replacement for CPURLConnection which provides
    more streamlined usage, automates common tasks like accumulating received data,
    and deals with some of the more tricky aspects of error handling.

    With CPURLConnection, you have to keep multiple connections in separate variables
    and then test the connection against those variables in the connection handler.
    SCURLConnection allows you to eliminate the variables and delegate to separate handler
    methods directly.

    For example, here is the CPURLConnection way:

    @code
    @implementation MyClass
    {
        CPURLConnection fooConnection;
        CPString        fooConnectionData;
        CPURLConnection barConnection;
        CPString        barConnectionData;
    }

    - (void)sendFoo
    {
        var request = [CPURLRequest requestWithURL:@"foo.php"];

        fooConnectionData = @"";
        fooConnection = [CPURLConnection connectionWithRequest:request delegate:self];
    }

    - (void)sendBar
    {
        var request = [CPURLRequest requestWithURL:@"bar.php"];

        barConnectionData = @"";
        barConnection = [CPURLConnection connectionWithRequest:request delegate:self];
    }

    - (void)connection:(CPURLConnection)connection didReceiveData:(CPString)data
    {
        if (connection === fooConnection)
            fooConnectionData += data;
        else if (connection === barConnection)
            barConnectionData += data;
    }

    - (void)connectionDidFinishLoading:(CPURLConnection)connection
    {
        if (connection === fooConnection)
        {
            [self doSomethingWithData:fooConnectionData];
            [self doFooStuff];
        }
        else if (connection === barConnection)
        {
            [self doSomethingWithData:barConnectionData];
            [self doBarStuff];
        }
    }

    @end
    @endcode

    If you multiply the number of connections in the above example and increase
    the amount of processing that needs to be done for each connection,
    it gets ugly very quickly, especially if you want to deal separately
    with errors.

    Here is the same thing done with SCURLConnection:

    @code
    @implementation MyClass
    {
        // No need to store connections
    }

    - (void)sendFoo
    {
        [self sendConnection:@"foo"];
    }

    - (void)sendBar
    {
        [self sendConnection:@"bar"];
    }

    // A lot of common code eliminated
    - (void)sendConnection:(CPString)identifier
    {
        var request = [CPURLRequest requestWithURL:identifier + @".php"];

        // No need to save connection to a variable
        [SCURLConnection connectionWithRequest:request delegate:self identifier:identifier];
    }

    - (void)fooConnectionDidSucceed:(CPURLConnection)connection
    {
        // Received data is saved for us
        [self doSomethingWithData:[connection receivedData]];
        [self doFooStuff];
    }

    - (void)barConnectionDidSucceed:(CPURLConnection)connection
    {
        // Received data is saved for us
        [self doSomethingWithData:[connection receivedData]];
        [self doBarStuff];
    }

    @end
    @endcode

    Notice that SCURLConnection lets you use an identifier to dispatch directly to
    separate handler methods when the connection is completely, successfully finished.
    In addition, the received data is automatically accumulated and is accessible
    via the connection.

    @section delegate_methods Delegate Methods

    Your connection delegate can define several handler methods:

    @code
    // Implement this ONLY if you need to do custom data processing
    - (void)connection:(SCURLConnection)connection didReceiveData:(CPString)data

    // You SHOULD always implement this method
    - (void)connectionDidSucceed:(SCURLConnection)connection

    // Implement this only if you want to catch and handle errors.
    // By default an alert is displayed with an intelligent error message
    // if an error occurs.
    - (void)connection:(SCURLConnection)connection didFailWithError:(id)error
    @endcode

    Within any of these methods, the data received so far is available as a
    string via the receivedData method.

    The names of these methods change according to the identifier passed in
    the connection initializer. If no identifier is passed (or is empty),
    the names above will be used. If a non-empty identifier is passed,
    the names are as follows:

        <identifier>Connection:didReceiveData:
        <identifier>ConnectionDidSucceed:
        <identifier>Connection:didFailWithError:

    For example, if you use the identifier "saveContact", the methods names
    should be:

        saveContactConnection:didReceiveData:
        saveContactConnectionDidSucceed:
        saveContactConnection:didFailWithError:
*/

@implementation SCURLConnection : CPURLConnection
{
    _SCConnection base;
}

/*!
    Create a connection with the given URL and delegate.
    The connection starts immediately.

    @param aURL A URL to send
    @param aDelegate A connection delegate
*/
+ (SCURLConnection)connectionWithURL:(CPString)aURL delegate:(id)aDelegate
{
    return [self connectionWithRequest:[CPURLRequest requestWithURL:aURL] delegate:aDelegate];
}

/*!
    Create a connection with the given request and delegate.
    The connection starts immediately.

    @param aRequest A request
    @param aDelegate A connection delegate
*/
+ (SCURLConnection)connectionWithRequest:(CPURLRequest)aRequest delegate:(id)aDelegate
{
    return [[self alloc] initWithRequest:aRequest delegate:aDelegate identifier:@"" startImmediately:YES];
}

/*!
    Create a connection with the given URL, delegate and identifier.
    The connection starts immediately.

    @param aURL A URL to send
    @param aDelegate A connection delegate
    @param anIdentifier An identifier to prefix to delegate handler method names
*/
+ (SCURLConnection)connectionWithURL:(CPString)aURL delegate:(id)aDelegate identifier:(CPString)anIdentifier
{
    return [self connectionWithRequest:[CPURLRequest requestWithURL:aURL] delegate:aDelegate identifier:anIdentifier];
}

/*!
    Create a connection with the given request, delegate and identifier.
    The connection starts immediately.

    @param aRequest A request
    @param aDelegate A connection delegate
    @param anIdentifier An identifier to prefix to delegate handler method names
*/
+ (SCURLConnection)connectionWithRequest:(CPURLRequest)aRequest delegate:(id)aDelegate identifier:(CPString)anIdentifier
{
    return [[self alloc] initWithRequest:aRequest delegate:aDelegate identifier:anIdentifier startImmediately:YES];
}

/*!
    Init a connection with the given URL and delegate.
    The connection starts immediately if \c shouldStartImmediately is YES.

    @param aURL A URL to send
    @param aDelegate A connection delegate
    @param shouldStartImmediately If YES, start the connection immediately
*/
- (id)initWithURL:(CPString)aURL delegate:(id)aDelegate startImmediately:(BOOL)shouldStartImmediately
{
    return [self initWithRequest:[CPURLRequest requestWithURL:aURL] delegate:aDelegate startImmediately:shouldStartImmediately];
}

/*!
    Init a connection with the given request and delegate.
    The connection starts immediately if \c shouldStartImmediately is YES.

    @param aRequest A request
    @param aDelegate A connection delegate
    @param shouldStartImmediately If YES, start the connection immediately
*/
- (id)initWithRequest:(CPURLRequest)aRequest delegate:(id)aDelegate startImmediately:(BOOL)shouldStartImmediately
{
    base = [_SCConnection new];
    self = [super initWithRequest:aRequest delegate:base startImmediately:NO];

    if (self)
        [self _initWithIdentifier:@"" delegate:aDelegate startImmediately:shouldStartImmediately];

    return self;
}

/*!
    Init a connection with the given URL, delegate and identifier.
    The connection starts immediately if \c shouldStartImmediately is YES.

    @param aURL A URL to send
    @param aDelegate A connection delegate
    @param anIdentifier An identifier to prefix to delegate handler method names
    @param shouldStartImmediately If YES, start the connection immediately
*/
- (id)initWithURL:(CPString)aURL delegate:(id)aDelegate identifier:(CPString)anIdentifier startImmediately:(BOOL)shouldStartImmediately
{
    return [self initWithRequest:[CPURLRequest requestWithURL:aURL] delegate:aDelegate identifier:anIdentifier startImmediately:shouldStartImmediately];
}

/*!
    Init a connection with the given request, delegate and identifier.
    The connection starts immediately if \c shouldStartImmediately is YES.

    @param aRequest A request
    @param aDelegate A connection delegate
    @param anIdentifier An identifier to prefix to delegate handler method names
    @param shouldStartImmediately If YES, start the connection immediately
*/
- (id)initWithRequest:(CPURLRequest)aRequest delegate:(id)aDelegate identifier:(CPString)anIdentifier startImmediately:(BOOL)shouldStartImmediately
{
    base = [_SCConnection new];
    self = [super initWithRequest:aRequest delegate:base startImmediately:NO];

    if (self)
        [self _initWithIdentifier:anIdentifier delegate:aDelegate startImmediately:shouldStartImmediately];

    return self;
}

- (void)_initWithIdentifier:(CPString)anIdentifier delegate:(id)aDelegate startImmediately:(BOOL)shouldStartImmediately
{
    [base initWithConnection:self identifier:anIdentifier delegate:aDelegate startImmediately:shouldStartImmediately];
}

/*!
    @ignore
*/
- (void)connection:(SCURLConnection)connection didReceiveResponse:(CPHTTPURLResponse)response
{
    [base connection:connection didReceiveResponse:response];
}

/*!
    @ignore
*/
- (void)connection:(SCURLConnection)connection didReceiveData:(CPString)data
{
    [base connection:connection didReceiveData:data];
}

/*!
    @ignore
*/
- (void)connectionDidFinishLoading:(SCURLConnection)connection
{
    [base connectionDidFinishLoading:connection];
}

/*!
    Returns 200 if the connection succeeded without error, otherwise the response code.
*/
- (int)responseStatus
{
    return [base responseStatus];
}

/*!
    Returns the accumulated data received from the connection response.
*/
- (CPString)receivedData
{
    return [base receivedData];
}

/*!
    Returns the accumulated data received from the connection response as a JSON object.
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
