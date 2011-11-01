/*
 *  SCConnectionUtils.j
 *
 *  Created by Aparajita on 10/31/2011.
 *  Copyright Victory-Heart Productions 2010. All rights reserved.
*/

@implementation SCConnectionUtils : CPObject

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
            case -1:  // Bad json data, probably an error message
            case 500:
                message = @"An internal error occurred on the server. Please notify the site administrator.";
                break;

            case 502:  // Bad Gateway
            case 503:  // Service Unavailable
            case 504:  // Gateway Timeout
                message = @"The server is not responding. If this problem continues please contact the site administrator.";
                break;

            default:
                message = [CPString stringWithFormat:@"An error occurred (%d) while trying to connect with the server. Please try again.", responseStatus];
        }
    }
    else
        message = @"An error occurred while trying to connect with the server. Please try again.";

    return message;
}

@end
