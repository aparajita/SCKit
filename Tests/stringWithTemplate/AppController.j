/*
 * AppController.j
 * stringWithTemplate Test
 *
 * Created by Aparajita Fishman on August 14, 2010.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

@import <LPKit/LPMultiLineTextField.j>
@import <SCKit/SCString.j>


CPLogRegister(CPLogConsole);


@implementation AppController : CPObject
{
    CPWindow                theWindow; //this "outlet" is connected automatically by the Cib
    LPMultiLineTextField    theCode;
    LPMultiLineTextField    theTemplate;
    LPMultiLineTextField    theResult;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    // This is called when the application is done loading.
    [theWindow setBackgroundColor:[CPColor colorWithHexString:@"eeeeee"]];
}

- (void)awakeFromCib
{
    [theCode setValue:[CPColor blackColor] forThemeAttribute:@"text-color"];
    [theTemplate setValue:[CPColor blackColor] forThemeAttribute:@"text-color"];
    [theResult setValue:[CPColor blackColor] forThemeAttribute:@"text-color"];
    
    [theCode setStringValue:@"{name:\"pizza\", qty:0}"];
    [theTemplate setStringValue:@"There |qty|is|are| #qty#no#${qty}# ${name}|qty||s|#qty#!##"];

    [theWindow setFullPlatformWindow:YES];
}

- (void)applyTemplate:(id)sender
{
    var args = nil,
        template = [theTemplate stringValue];

    eval("args = " + [theCode stringValue]);

    [theResult setStringValue:[SCString stringWithTemplate:template, args]];
}

@end
