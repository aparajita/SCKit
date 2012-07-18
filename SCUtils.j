/*
 * SCUtils.j
 * SCKit
 *
 * Created by Aparajita Fishman.
 * Copyright 2012 Aparajita Fishman. All Rights Reserved.
 *
 * Licensed LGPL 3.0 - http://www.gnu.org/licenses/lgpl.html
 */

@implementation SCUtils : CPObject

/*!
    Aligns the text baseline of one view with the baseline of another.
    If a view does not seem to have text of any kind, it's frame is used.
*/
+ (void)alignTextBaselineOf:(CPView)aViewToAlign withBaselineOf:(CPView)anAnchorView
{
    var alignTextFrame = [self textFrameOfView:aViewToAlign],
        anchorTextFrame = [self textFrameOfView:anAnchorView],
        topDiff = CGRectGetMinY(anchorTextFrame) - CGRectGetMinY(alignTextFrame),
        ascenderDiff = [[anAnchorView font] ascender] - [[aViewToAlign font] ascender],
        alignOrigin = [aViewToAlign frameOrigin],
        anchorOrigin = [anAnchorView frameOrigin];

    alignOrigin.y = anchorOrigin.y + topDiff + ascenderDiff;

    [aViewToAlign setFrameOrigin:alignOrigin];
}

/*!
    Aligns the text baselines of an array of views. The first view in the array
    is used as the anchor view to which all of the other views are aligned.
    If a view does not seem to have text of any kind, it's frame is used.
*/
+ (void)alignTextBaselineOfViews:(CPArray)views
{
    if (views.length < 2)
        return;

    var anchorView = views[0],
        count = views.length;

    for (var i = 1; i < count; ++i)
        [self alignTextBaselineOf:views[i] withBaselineOf:anchorView];
}

+ (CGRect)textFrameOfView:(CPView)aView
{
    [aView layoutIfNeeded];

    // Most Cappuccino views use an ephemeral subview named "content-view".
    var contentView = [aView ephemeralSubviewNamed:@"content-view"],
        origin;

    if (contentView)
        origin = [contentView frameOrigin];
    else
    {
        // If there is no ephemeral subview, use the view itself
        contentView = aView;
        origin = CGPointMakeCopy([contentView bounds].origin);
    }

    // Try to extract the text frame
    if ([contentView respondsToSelector:@selector(textFrame)])
    {
        var textFrame = [contentView textFrame];

        // We want to return the offset from the view, so add in the content view's offset
        origin.x += CGRectGetMinX(textFrame);
        origin.y += CGRectGetMinY(textFrame);

        return CGRectMake(origin.x, origin.y, CGRectGetWidth(textFrame), CGRectGetHeight(textFrame));
    }
    else
        return [contentView bounds];
}

@end
