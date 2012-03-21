/*
 * SCKitClass.j
 * SCKit
 *
 * Created by Aparajita Fishman.
 * Copyright (c) 2010, Victory-Heart Productions.
 *
 * Released under the MIT license:
 * http://www.opensource.org/licenses/MIT
 */

@import <Foundation/CPObject.j>


/*!
    @ingroup sckit

    This class is defined to make it easier to find the bundle,
    for example to get an image from the framework like this:

    @code
    var path = [[CPBundle bundleForClass:SCKit] pathForResource:@"email-action.png"];
    @endcode

    You can also use [SCKit version] to get the current version.
*/
@implementation SCKit : CPObject

+ (CPString)version
{
    var bundle = [CPBundle bundleForClass:[self class]];

    return [bundle objectForInfoDictionaryKey:@"CPBundleVersion"];
}

@end
