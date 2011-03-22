/*
 * SCBorderView.j
 * AppKit
 *
 * Created by Aparajita Fishman.
 * Copyright 2010, Aparajita Fishman
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

@import <Foundation/Foundation.j>

@import <AppKit/CPGraphicsContext.j>
@import <AppKit/CPImage.j>
@import <AppKit/CPImageView.j>
@import <AppKit/CPView.j>


/*!
    @ingroup appkit
*/

SCBorderViewImageTopLeft     = 0;
SCBorderViewImageTop         = 1;
SCBorderViewImageTopRight    = 2;
SCBorderViewImageLeft        = 3;
SCBorderViewImageCenter      = 4;
SCBorderViewImageRight       = 5;
SCBorderViewImageBottomLeft  = 6;
SCBorderViewImageBottom      = 7;
SCBorderViewImageBottomRight = 8;

SCBorderViewModeImages = 0;
SCBorderViewModeShadow = 1;

var SCBorderViewPathSuffixes = [
        @"TopLeft.png",
        @"Top.png",
        @"TopRight.png",
        @"Left.png",
        @"Center.png",
        @"Right.png",
        @"BottomLeft.png",
        @"Bottom.png",
        @"BottomRight.png"
    ];


@implementation SCBorderView : CPView
{
    SCBorderViewMode    _mode   @accessors(readonly, getter=mode)

    CPView              _contentView    @accessors(readonly, getter=contentView);

    float               _borderWidth    @accessors(readonly, getter=borderWidth);
    CPColor             _borderColor    @accessors(readonly, getter=borderColor);

    CGSize              _shadowOffset   @accessors(readonly, getter=shadowOffset);
    float               _shadowBlur     @accessors(readonly, getter=shadowBlur);
    CPColor             _shadowColor    @accessors(readonly, getter=shadowColor);

    float               _leftInset      @accessors(readonly, getter=leftInset);
    float               _rightInset     @accessors(readonly, getter=rightInset);
    float               _topInset       @accessors(readonly, getter=topInset);
    float               _bottomInset    @accessors(readonly, getter=bottomInset);
}

+ (id)borderViewEnclosingView:(CPView)aView
      width:(float)aWidth
      color:(CPColor)aColor
      imagePath:(CPString)anImagePath
      sizes:(CPArray)sizes
      insets:(CPArray)insets
{
    return [[SCBorderView alloc] initWithView:aView width:aWidth color:aColor imagePath:anImagePath sizes:sizes insets:insets];
}

+ (id)borderViewEnclosingView:(CPView)aView
      width:(float)aWidth
      color:(CPColor)aColor
      shadowOffset:(CGSize)anOffset
      shadowBlur:(float)aBlur
      shadowColor:(CPColor)aShadowColor
{
    return [[SCBorderView alloc] initWithView:aView width:aWidth color:aColor shadowOffset:anOffset shadowBlur:aBlur shadowColor:aShadowColor];
}

- (id)initWithView:(CPView)aView
      width:(float)aWidth
      color:(CPColor)aColor
      imagePath:(CPString)anImagePath
      sizes:(CPArray)sizes
      insets:(CPArray)insets
{
    self = [super initWithFrame:[aView frame]];

    if (self)
    {
        _mode         = SCBorderViewModeImages;

        _borderWidth  = aWidth;
        _borderColor  = aColor == nil ? [CPColor grayColor] : aColor;

        _shadowOffset = CGSizeMakeZero();
        _shadowBlur   = 0;
        _shadowColor  = nil;

        _topInset     = insets[0] + _borderWidth;
        _rightInset   = insets[1] + _borderWidth;
        _bottomInset  = insets[2] + _borderWidth;
        _leftInset    = insets[3] + _borderWidth;

        var path = [[CPBundle mainBundle] pathForResource:anImagePath],
            slices = [CPArray arrayWithCapacity:9];

        for (var i = 0; i < 9; ++i)
        {
            var size = [sizes objectAtIndex:i],
                image = nil;

            if (size != nil)
                image = [[CPImage alloc] initWithContentsOfFile:path + [SCBorderViewPathSuffixes objectAtIndex:i] size:size];

            [slices replaceObjectAtIndex:i withObject:image];
        }

        [self setBackgroundColor:[CPColor colorWithPatternImage:[[CPNinePartImage alloc] initWithImageSlices:slices]]];

        [self _initWithView:aView];
    }

    return self;
}

- (id)initWithView:(CPView)aView
      width:(float)aWidth
      color:(CPColor)aColor
      shadowOffset:(CGSize)anOffset
      shadowBlur:(float)aBlur
      shadowColor:(CPColor)aShadowColor
{
    self = [super initWithFrame:[aView frame]];

    if (self)
    {
        _mode         = SCBorderViewModeShadow;

        _borderWidth  = aWidth;
        _borderColor  = aColor == nil ? [CPColor colorWithWhite:190.0 / 255.0 alpha:1.0] : aColor;

        _shadowOffset = anOffset;
        _shadowBlur   = aBlur;
        _shadowColor  = aShadowColor == nil ? [CPColor colorWithWhite:190.0 / 255.0 alpha:1.0] : aShadowColor;

        _topInset     = _borderWidth + MAX(_shadowBlur - _shadowOffset.height, 0);
        _rightInset   = _borderWidth + _shadowOffset.width + _shadowBlur;
        _bottomInset  = _borderWidth + _shadowOffset.height + _shadowBlur;
        _leftInset    = _borderWidth + MAX(_shadowBlur - _shadowOffset.width, 0);

        [self _initWithView:aView];
    }

    return self;
}

- (void)_initWithView:(CPView)aView
{
    _contentView = aView;

    var size = [self frame].size,
        width = size.width - _leftInset - _rightInset,
        height = size.height - _topInset - _bottomInset,
        enclosingView = [_contentView superview];

    [self setHitTests:[_contentView hitTests]];
    [self setAutoresizingMask:[_contentView autoresizingMask]];

    [_contentView removeFromSuperview];
    [self addSubview:_contentView];
    [_contentView setFrame:CGRectMake(_leftInset, _topInset, width, height)]
    [enclosingView addSubview:self];
}

- (float)horizontalInset
{
    return _leftInset + _rightInset;
}

- (float)verticalInset
{
    return _topInset + _bottomInset;
}

- (CGRect)frameForContentFrame:(CGRect)aFrame
{
    return CGRectMake(CGRectGetMinX(aFrame) - _leftInset,
                      CGRectGetMinY(aFrame) - _topInset,
                      CGRectGetWidth(aFrame) + _leftInset + _rightInset,
                      CGRectGetHeight(aFrame) + _topInset + _bottomInset);
}

- (void)setFrameForContentFrame:(CGRect)aFrame
{
    [self setFrame:[self frameForContentFrame:aFrame]];
}

- (void)drawRect:(CGRect)aRect
{
    [super drawRect:aRect];

    if (_mode == SCBorderViewModeShadow)
    {
        var context = [[CPGraphicsContext currentContext] graphicsPort],
            frame = [_contentView frame],
            fillRect = CGRectInset(frame, -_borderWidth, -_borderWidth),
            strokeRect = CGRectInset(frame, -_borderWidth * 0.5, -_borderWidth * 0.5);

        if (_shadowBlur > 0)
        {
            CGContextSaveGState(context);
            CGContextSetShadowWithColor(context, _shadowOffset, _shadowBlur, _shadowColor);
            CGContextSetFillColor(context, [CPColor whiteColor]);
            CGContextFillRect(context, fillRect);
            CGContextRestoreGState(context);
        }

        if (_borderWidth > 0)
        {
            CGContextSetLineWidth(context, _borderWidth);
            CGContextSetStrokeColor(context, _borderColor);
            CGContextStrokeRect(context, strokeRect);
        }
    }
}

@end
