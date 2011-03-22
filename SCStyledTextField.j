/*
 *  SCStyledTextField.j
 *
 *  Created by Aparajita on 8/6/10.
 *  Copyright Victory-Heart Productions 2010. All rights reserved.
*/

@import <AppKit/CPTextField.j>

@import "_SCImageAndStyledTextView.j"
@import "SCString.j"


@implementation SCStyledTextField : CPTextField

- (CPView)createEphemeralSubviewNamed:(CPString)aName
{
    if (aName === "bezel-view")
    {
        return [super createEphemeralSubviewNamed:aName];
    }
    else
    {
        var view = [[_SCImageAndStyledTextView alloc] initWithFrame:CGRectMakeZero()];
        
        [view setHitTests:NO];
        
        return view;
    }
    
    return [super createEphemeralSubviewNamed:aName];
}

- (void)setEncodedStringValueWithFormat:(CPString)format, ...
{
    var args = Array.prototype.slice.call(arguments, 2);
    
    for (var i = 1; i < args.length; ++i)
        args[i] = encodeHTMLComponent(args[i]);
        
    [self setStringValue:ObjectiveJ.sprintf.apply(this, args)];
}

- (void)setEncodedStringValueWithTemplate:(CPString)template, ...
{
    var args = Array.prototype.slice.call(arguments, 3);
    
    for (var i = 0; i < args.length; ++i)
        args[i] = encodeHTMLComponent(args[i]);
        
    [self setStringValue:SCKit.stringWithTemplate(template, SCString.DefaultDelimiters, args)];
}

- (void)setEncodedStringValueWithTemplate:(CPString)template delimiters:(CPString)delimiters, ...
{
    var args = Array.prototype.slice.call(arguments, 4);
    
    for (var i = 0; i < args.length; ++i)
        args[i] = encodeHTMLComponent(args[i]);
        
    [self setStringValue:SCKit.stringWithTemplate(template, delimiters, args)];
}

@end

var encodeHTMLComponent = function(/*String*/ aString)
{
    return aString.replace(/&/g,'&amp;').replace(/"/g, '&quot;').replace(/'/g, '&apos;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
}
