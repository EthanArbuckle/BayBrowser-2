#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//static const int UIViewAutoresizingFlexibleMargins = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
//static const int UIViewAutoresizingFlexibleSize = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
//static const int UIViewAutoresizingFlexibleAll = UIViewAutoresizingFlexibleMargins|UIViewAutoresizingFlexibleSize;

CGRect CGRectEdgeInset(CGRect rect, UIEdgeInsets insets);

CGFloat CGSizeGetMaxDimension(CGSize size);
CGFloat CGSizeGetMinDimension(CGSize size);
CGFloat CGPointGetVectorMagnitude(CGPoint point);
CGFloat CGSizeGetVectorMagnitude(CGSize size);
CGFloat CGRectGetVectorMagnitude(CGRect rect);

CGPoint CGPointGetVectorToPoint(CGPoint origin, CGPoint targetPoint);
CGFloat CGPointGetDistanceToPoint(CGPoint origin, CGPoint targetPoint);
CGPoint CGPointGetNormalizedVector(CGPoint vector);
CGPoint CGPointGetVectorWithLength(CGPoint vector, CGFloat length);
CGPoint CGPointVectorAddPoint(CGPoint firstVector, CGPoint secondVector);
CGPoint CGPointScalarMultiply(CGPoint vector, CGFloat scalar);

CGRect CGRectGetBounds(CGRect rect);
CGPoint CGRectGetCenter(CGRect rect);
CGPoint CGRectGetExtent(CGRect rect);
CGRect CGRectGetBoundingRect(CGRect rect);
CGSize CGRectGetBoundingSize(CGRect rect);

CGPoint CGPointFromCGSize(CGSize size);
CGSize CGSizeFromCGPoint(CGPoint point);

static const CGSize CGSizeUnit = {1.0f,1.0f};

CGRect CGRectAlignTop(CGRect rect, CGRect containingRect);
CGRect CGRectAlignBottom(CGRect rect, CGRect containingRect);
CGRect CGRectAlignLeft(CGRect rect, CGRect containingRect);
CGRect CGRectAlignRight(CGRect rect, CGRect containingRect);

CGRect CGRectAlignTopRight(CGRect rect, CGRect containingRect);
CGRect CGRectAlignBottomRight(CGRect rect, CGRect containingRect);
CGRect CGRectAlignTopLeft(CGRect rect, CGRect containingRect);
CGRect CGRectAlignBottomLeft(CGRect rect, CGRect containingRect);

CGRect CGRectAlignCenterVertical(CGRect rect, CGRect containingRect);
CGRect CGRectAlignCenterHorizontal(CGRect rect, CGRect containingRect);
CGRect CGRectAlignCenter(CGRect rect, CGRect containingRect);

CGRect CGRectAlignCenterTop(CGRect rect, CGRect containingRect);
CGRect CGRectAlignCenterLeft(CGRect rect, CGRect containingRect);
CGRect CGRectAlignCenterBottom(CGRect rect, CGRect containingRect);
CGRect CGRectAlignCenterRight(CGRect rect, CGRect containingRect);

CGRect CGRectWithOrigin(CGRect rect, CGPoint origin);
CGRect CGRectWithOriginX(CGRect rect, CGFloat originX);
CGRect CGRectWithOriginY(CGRect rect, CGFloat originY);

CGRect CGRectWithExtent(CGRect rect, CGPoint extent);
CGRect CGRectWithExtentX(CGRect rect, CGFloat extentX);
CGRect CGRectWithExtentY(CGRect rect, CGFloat extentY);

CGRect CGRectOffsetPoint(CGRect rect, CGPoint offsetPoint);
CGRect CGRectOffsetX(CGRect rect, CGFloat offsetX);
CGRect CGRectOffsetY(CGRect rect, CGFloat offsetY);

CGRect CGRectWithSize(CGRect rect, CGSize size);
CGRect CGRectWithWidth(CGRect rect, CGFloat width);
CGRect CGRectWithHeight(CGRect rect, CGFloat height);

CGRect CGRectWithDeltaSize(CGRect rect, CGSize sizeDelta);
CGRect CGRectWithDeltaWidth(CGRect rect, CGFloat widthDelta);
CGRect CGRectWithDeltaHeight(CGRect rect, CGFloat heightDelta);

CGSize CGSizeWithDeltaSize(CGSize size, CGSize sizeDelta);
CGSize CGSizeWithDeltaWidth(CGSize size, CGFloat widthDelta);
CGSize CGSizeWithDeltaHeight(CGSize size, CGFloat heightDelta);

CGRect CGRectTrimTop(CGRect rect, CGFloat trimHeight);
CGRect CGRectTrimBottom(CGRect rect, CGFloat trimHeight);
CGRect CGRectTrimLeft(CGRect rect, CGFloat trimWidth);
CGRect CGRectTrimRight(CGRect rect, CGFloat trimWidth);

CGRect CGRectMakeWithPointAndSize(CGPoint point, CGSize size);
CGRect CGRectMakeBounds(CGSize size);
CGRect CGRectMakeWithExtent(CGPoint extent);

CGRect CGRectWithCenter(CGRect rect, CGPoint center);
CGRect CGRectWithCenterX(CGRect rect, CGFloat centerX);
CGRect CGRectWithCenterY(CGRect rect, CGFloat centerY);

CGRect CGRectCenterWithSize(CGRect rect, CGSize size);
CGRect CGRectCenterWithWidth(CGRect rect, CGFloat width);
CGRect CGRectCenterWithHeight(CGRect rect, CGFloat height);

CGRect CGRectRoundedDown(CGRect rect);

CGPoint CGPointOffset(CGPoint point, CGPoint offset);
CGPoint CGPointOffsetX(CGPoint point, CGFloat xOffset);
CGPoint CGPointOffsetY(CGPoint point, CGFloat yOffset);