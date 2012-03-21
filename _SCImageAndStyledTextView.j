/*
 * _SCImageAndStyledTextView.j
 * SCKit
 *
 * Created by Aparajita Fishman.
 * Copyright (c) 2010, Victory-Heart Productions.
 *
 * Released under the MIT license:
 * http://www.opensource.org/licenses/MIT
 */

@import <AppKit/_CPImageAndTextView.j>


/*!
    The standard _CPImageAndTextView used by Cappuccino strips all html tags
    from the text. This subclass, used by \ref SCStyledTextField, allows
    you to use full styled html in a text field.

    Ordinarily you will never need to interact with this class directly.
*/
@implementation _SCImageAndStyledTextView : _CPImageAndTextView

- (void)layoutSubviews
{
    [super layoutSubviews];

    if (_DOMTextElement)
        _DOMTextElement.innerHTML = _text;

    if (_DOMTextShadowElement)
        _DOMTextShadowElement.innerHTML = "";
}

@end
