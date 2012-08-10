/*
 * SCStyledTextField.j
 * SCKit
 *
 * Created by Aparajita Fishman.
 * Copyright (c) 2010, Victory-Heart Productions.
 *
 * Released under the MIT license:
 * http://www.opensource.org/licenses/MIT
*/

@import <AppKit/CPPlatformString.j>
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
        if (typeof(args[i]) === "string")
            args[i] = encodeHTMLComponent(args[i]);

    [self setStringValue:ObjectiveJ.sprintf.apply(this, args)];
}

- (void)setEncodedStringValueWithTemplate:(CPString)template, ...
{
    var args = Array.prototype.slice.call(arguments, 3);

    for (var i = 0; i < args.length; ++i)
        if (typeof(args[i]) === "string")
            args[i] = encodeHTMLComponent(args[i]);

    [self setStringValue:[SCString stringWithTemplate:template args:args]];
}

- (void)setEncodedStringValueWithTemplate:(CPString)template delimiters:(CPString)delimiters, ...
{
    var args = Array.prototype.slice.call(arguments, 4);

    for (var i = 0; i < args.length; ++i)
        if (typeof(args[i]) === "string")
            args[i] = encodeHTMLComponent(args[i]);

    [self setStringValue:[SCString stringWithTemplate:template delimiters:delimiters args:args]];
}

@end


var DOMFixedWidthSpanElement    = nil,
    DOMFlexibleWidthSpanElement = nil;


@implementation SCStyledTextField (Utils)

+ (CGSize)sizeOfString:(CPString)aString withFont:(CPFont)aFont forWidth:(float)aWidth
{
    if (!DOMFixedWidthSpanElement)
        [self createDOMElements];

    var span;

    if (!aWidth)
        span = DOMFlexibleWidthSpanElement;
    else
    {
        span = DOMFixedWidthSpanElement;
        span.style.width = ROUND(aWidth) + "px";
    }

    span.style.font = [(aFont || [CPFont systemFontOfSize:CPFontCurrentSystemSize]) cssString];
    span.innerHTML = aString;

    return CGSizeMake(span.clientWidth, span.clientHeight);
}

+ (void)createDOMElements
{
    var style,
        bodyElement = [CPPlatform mainBodyElement];

    DOMFlexibleWidthSpanElement = document.createElement("span");
    DOMFlexibleWidthSpanElement.className = "cpdontremove";
    style = DOMFlexibleWidthSpanElement.style;
    style.position = "absolute";
    style.left = "-100000px";
    style.zIndex = -100000;
    style.visibility = "visible";
    style.padding = "0px";
    style.margin = "0px";
    style.whiteSpace = "pre";

    DOMFixedWidthSpanElement = document.createElement("span");
    DOMFixedWidthSpanElement.className = "cpdontremove";
    style = DOMFixedWidthSpanElement.style;
    style.display = "block";
    style.position = "absolute";
    style.left = "-100000px";
    style.zIndex = -10000;
    style.visibility = "visible";
    style.padding = "0px";
    style.margin = "0px";
    style.width = "1px";
    style.wordWrap = "break-word";

    try
    {
        style.whiteSpace = "pre";
        style.whiteSpace = "-o-pre-wrap";
        style.whiteSpace = "-pre-wrap";
        style.whiteSpace = "-moz-pre-wrap";
        style.whiteSpace = "pre-wrap";
    }
    catch(e)
    {
        //some versions of IE throw exceptions for unsupported properties.
        style.whiteSpace = "pre";
    }

    bodyElement.appendChild(DOMFlexibleWidthSpanElement);
    bodyElement.appendChild(DOMFixedWidthSpanElement);
}

@end


var encodeHTMLComponent = function(/*String*/ aString)
{
    return aString ? aString.replace(/&/g,'&amp;').replace(/"/g, '&quot;').replace(/'/g, '&apos;').replace(/</g,'&lt;').replace(/>/g,'&gt;') : "";
}
