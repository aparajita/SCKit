/*
 * SCConnectionUtils.j
 * SCKit
 *
 * Created by Aparajita Fishman.
 * Copyright (c) 2010, Victory-Heart Productions.
 *
 * Released under the MIT license:
 * http://www.opensource.org/licenses/MIT
*/

@implementation SCConnectionUtils : CPObject

/*!
    Given a numeric error code or error message, returns a message
    describing the type of error that occurred.
*/
+ (CPString)errorMessageForError:(id)error
{
    var type = typeof(error),
        message;

    if (type === "string")
        message = error;
    else if (type === "number")
    {
        switch (error)
        {
            case 400: // Bad Request
                message = @"The request was malformed. If this problem continues please contact the site administrator.";
                break;

            case 401: // Unauthorized
            case 403: // Forbidden
                message = @"You are not authorized to access that resource. If this problem continues please contact the site administrator.";
                break;

            case 404: // File not found
                message = @"The requested resource could not be found. Please notify the site administrator.";
                break;

            case -1:  // Bad json data, probably an error message
            case 500:
                message = @"An internal error occurred on the server. Please notify the site administrator.";
                break;

            case 408: // Request Timeout
            case 502: // Bad Gateway
            case 503: // Service Unavailable
            case 504: // Gateway Timeout
                message = @"The server is not responding. If this problem continues please contact the site administrator.";
                break;

            default:
                message = [CPString stringWithFormat:@"An error occurred (%d) while trying to connect with the server. Please try again.", error];
        }
    }
    else
        message = @"An error occurred while trying to connect with the server. Please try again.";

    return message;
}

/*!
    A convenience method to display an error alert. It is designed to be called
    from the \c connection:DidFailWithError: delegate method, passing the error.

    @param error A numeric error code or error message
*/
+ (void)alertFailureWithError:(id)error
{
    [self alertFailureWithError:error delegate:nil];
}

/*!
    A convenience method to display an error alert. It is designed to be called
    from the \c connection:DidFailWithError: delegate method, passing the error.

    @param error A numeric error code or error message
    @param aDelegate An alert delegate
*/
+ (void)alertFailureWithError:(id)error delegate:(id)aDelegate
{
    var alert = [[CPAlert alloc] init];

    [alert setDelegate:aDelegate];
    [alert setTitle:@"Connection Failed"];
    [alert setMessageText:[self errorMessageForError:error]];
    [alert addButtonWithTitle:@"OK"];
    [alert runModal];
}

@end
