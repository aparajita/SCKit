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
        args[i] = encodeHTMLComponent(args[i]);

    [self setStringValue:ObjectiveJ.sprintf.apply(this, args)];
}

- (void)setEncodedStringValueWithTemplate:(CPString)template, ...
{
    var args = Array.prototype.slice.call(arguments, 3);

    for (var i = 0; i < args.length; ++i)
        args[i] = encodeHTMLComponent(args[i]);

    [self setStringValue:[SCString stringWithTemplate:template args:args]];
}

- (void)setEncodedStringValueWithTemplate:(CPString)template delimiters:(CPString)delimiters, ...
{
    var args = Array.prototype.slice.call(arguments, 4);

    for (var i = 0; i < args.length; ++i)
        args[i] = encodeHTMLComponent(args[i]);

    [self setStringValue:[SCString stringWithTemplate:template delimiters:delimiters args:args]];
}

@end


var DOMFixedWidthSpanElement    = nil,
    DOMFlexibleWidthSpanElement = nil,
    DOMIFrameElement            = nil,
    DOMIFrameDocument           = nil;


@implementation SCStyledTextField (Utils)

+ (CGSize)sizeOfString:(CPString)aString withFont:(CPFont)aFont forWidth:(float)aWidth
{
    if (!DOMIFrameElement)
        [self createDOMElements];

    var span;

    if (!aWidth)
        span = DOMFlexibleWidthSpanElement;
    else
    {
        span = DOMFixedWidthSpanElement;
        span.style.width = ROUND(aWidth) + "px";
    }

    span.style.font = [(aFont || [CPFont systmeFontOfSize:CPFontCurrentSystemSize]) cssString];
    span.innerHTML = aString;

    return CGSizeMake(span.clientWidth, span.clientHeight);
}

+ (void)createDOMElements
{
    var style;

    DOMIFrameElement = document.createElement("iframe");
    // necessary for Safari caching bug:
    DOMIFrameElement.name = "iframe_" + FLOOR(RAND() * 10000);
    DOMIFrameElement.className = "cpdontremove";

    style = DOMIFrameElement.style;
    style.position = "absolute";
    style.left = "-100px";
    style.top = "-100px";
    style.width = "1px";
    style.height = "1px";
    style.borderWidth = "0px";
    style.overflow = "hidden";
    style.zIndex = 100000000000;

    var bodyElement = [CPPlatform mainBodyElement];

    bodyElement.appendChild(DOMIFrameElement);

    DOMIFrameDocument = (DOMIFrameElement.contentDocument || DOMIFrameElement.contentWindow.document);
    DOMIFrameDocument.write('<!DOCTYPE html><head></head><body></body></html>');
    DOMIFrameDocument.close();

    // IE needs this wide <div> to prevent unwanted text wrapping:
    var DOMDivElement = DOMIFrameDocument.createElement("div");
    DOMDivElement.style.position = "absolute";
    DOMDivElement.style.width = "100000px";

    DOMIFrameDocument.body.appendChild(DOMDivElement);

    DOMFlexibleWidthSpanElement = DOMIFrameDocument.createElement("span");
    style = DOMFlexibleWidthSpanElement.style;
    style.position = "absolute";
    style.visibility = "visible";
    style.padding = "0px";
    style.margin = "0px";
    style.whiteSpace = "pre";

    DOMFixedWidthSpanElement = DOMIFrameDocument.createElement("span");
    style = DOMFixedWidthSpanElement.style;
    style.display = "block";
    style.position = "absolute";
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

    DOMDivElement.appendChild(DOMFlexibleWidthSpanElement);
    DOMDivElement.appendChild(DOMFixedWidthSpanElement);
}


@end


var encodeHTMLComponent = function(/*String*/ aString)
{
    return aString.replace(/&/g,'&amp;').replace(/"/g, '&quot;').replace(/'/g, '&apos;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
}
