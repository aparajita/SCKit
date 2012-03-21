/*
 * AppController.j
 * SCKit
 *
 * Created by Aparajita Fishman.
 * Copyright (c) 2010, Victory-Heart Productions.
 *
 * Released under the MIT license:
 * http://www.opensource.org/licenses/MIT
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

@import <LPKit/LPMultiLineTextField.j>
@import <SCKit/SCString.j>
@import <SCKit/SCURLConnection.j>


CPLogRegister(CPLogConsole);


@implementation AppController : CPObject
{
    CPWindow                theWindow; //this "outlet" is connected automatically by the Cib
    CPWindow                stringWindow;
    LPMultiLineTextField    theCode;
    LPMultiLineTextField    theTemplate;
    LPMultiLineTextField    theResult;

    CPWindow                connectionWindow;
    CPTextField             textToSend;
    CPTextField             connectionResult;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
}

- (void)awakeFromCib
{
    [theWindow setFullPlatformWindow:YES];
    [[theWindow contentView] setBackgroundColor:[CPColor colorWithPatternImage:CPImageInBundle(@"linen.jpg", CGSizeMake(75.0, 75.0))]];

    [theCode setValue:[CPColor blackColor] forThemeAttribute:@"text-color"];
    [theTemplate setValue:[CPColor blackColor] forThemeAttribute:@"text-color"];
    [theResult setValue:[CPColor blackColor] forThemeAttribute:@"text-color"];

    [theCode setStringValue:@"{name:\"pizza\", qty:0}"];
    [theTemplate setStringValue:@"There |qty|is|are| #qty#no#${qty}# ${name}|qty||s|#qty#!##"];

    [connectionResult setStringValue:@""];
}

- (void)applyTemplate:(id)sender
{
    var args = nil,
        template = [theTemplate stringValue];

    eval("args = " + [theCode stringValue]);

    [theResult setStringValue:[SCString stringWithTemplate:template, args]];
}

- (void)echoText:(id)sender
{
    [self sendText:@"echo"];
}

- (void)modifyText:(id)sender
{
    [self sendText:@"modify"];
}

- (void)reverseText:(id)sender
{
    [self sendText:@"reverse"];
}

- (void)forceError:(id)sender
{
    [SCURLConnection connectionWithURL:@"foo.php" delegate:self identifier:@"error"];
}

- (void)forceCustomError:(id)sender
{
    [SCURLConnection connectionWithURL:@"foo.php" delegate:self identifier:@"customError"];
}

- (void)sendText:(CPString)action
{
    var url = [SCString stringWithTemplate:@"test.php?text=${0}&action=${1}", encodeURIComponent([textToSend stringValue]), action];

    // Note that we don't even need to save the connection in a variable,
    // the correct delegate methods will be called automatically.
    [SCURLConnection connectionWithURL:url delegate:self identifier:action];
}

- (void)echoConnectionDidSucceed:(SCURLConnection)connection
{
    [connectionResult setStringValue:@"Echo: " + [connection receivedData]];
}

- (void)modifyConnectionDidSucceed:(SCURLConnection)connection
{
    [connectionResult setStringValue:@"Modify: " + [connection receivedData]];
}

- (void)reverseConnectionDidSucceed:(SCURLConnection)connection
{
    [connectionResult setStringValue:@"Reverse: " + [connection receivedData]];
}

- (void)customErrorConnection:(SCURLConnection)connection didFailWithError:(id)error
{
    alert("Bummer! " + [SCConnectionUtils errorMessageForError:error]);
}

@end
