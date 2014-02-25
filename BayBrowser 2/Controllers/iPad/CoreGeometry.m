#import "CoreGeometry.h"

CGFloat CGSizeGetMaxDimension(CGSize size) {
	return fmaxf(size.width, size.height);
}

CGFloat CGSizeGetMinDimension(CGSize size) {
	return fminf(size.width, size.height);
}

CGFloat CGPointGetVectorMagnitude(CGPoint point) {
	return powf(powf(point.x, 2) + powf(point.y, 2), 0.5f);
}

CGFloat CGSizeGetVectorMagnitude(CGSize size) {
	return CGPointGetVectorMagnitude(CGPointFromCGSize(size));
}

CGFloat CGRectGetVectorMagnitude(CGRect rect) {
	return CGSizeGetVectorMagnitude(rect.size);
}

CGPoint CGPointGetVectorToPoint(CGPoint origin, CGPoint targetPoint) {
	return CGPointMake(targetPoint.x - origin.x, targetPoint.y - origin.y);
}

CGFloat CGPointGetDistanceToPoint(CGPoint origin, CGPoint targetPoint) {
	return CGPointGetVectorMagnitude(CGPointGetVectorToPoint(origin, targetPoint));
}

CGPoint CGPointGetNormalizedVector(CGPoint vector) {
	CGFloat length = CGPointGetVectorMagnitude(vector);
	return CGPointScalarMultiply(vector, 1.0f / length);
}

CGPoint CGPointGetVectorWithLength(CGPoint vector, CGFloat length) {
	return CGPointScalarMultiply(CGPointGetNormalizedVector(vector), length);
}

CGPoint CGPointVectorAddPoint(CGPoint firstVector, CGPoint secondVector) {
	return CGPointMake(firstVector.x + secondVector.x, firstVector.y + secondVector.y);
}

CGPoint CGPointScalarMultiply(CGPoint vector, CGFloat scalar) {
	return CGPointMake(vector.x * scalar, vector.y * scalar);
}

CGRect CGRectEdgeInset(CGRect rect, UIEdgeInsets insets) {
	CGRect newRect = CGRectMake(rect.origin.x + insets.left, rect.origin.y + insets.top, rect.size.width - insets.right - insets.left, rect.size.height - insets.bottom - insets.top);
	return newRect;
}

CGRect CGRectGetBounds(CGRect rect) {
	CGRect newRect = CGRectMake(0.0f, 0.0f, CGRectGetWidth(rect), CGRectGetHeight(rect));
	return newRect;
}

CGPoint CGRectGetCenter(CGRect rect) {
	CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
	return center;
}

CGPoint CGRectGetExtent(CGRect rect) {
	CGPoint extent = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
	return extent;
}

CGRect CGRectGetBoundingRect(CGRect rect) {
	return CGRectMakeWithExtent(CGRectGetExtent(rect));
}

CGSize CGRectGetBoundingSize(CGRect rect) {
	return CGSizeFromCGPoint(CGRectGetExtent(rect));
}

CGPoint CGPointFromCGSize(CGSize size) {
	return CGPointMake(size.width, size.height);
}

CGSize CGSizeFromCGPoint(CGPoint point) {
	return CGSizeMake(point.x, point.y);
}

CGRect CGRectAlignTop(CGRect rect, CGRect containingRect) {
	return CGRectWithOriginY(rect, containingRect.origin.y);
}

CGRect CGRectAlignBottom(CGRect rect, CGRect containingRect) {
	return CGRectWithExtentY(rect, CGRectGetMaxY(containingRect));
}

CGRect CGRectAlignLeft(CGRect rect, CGRect containingRect) {
	return CGRectWithOriginX(rect, containingRect.origin.x);
}

CGRect CGRectAlignRight(CGRect rect, CGRect containingRect) {
	return CGRectWithExtentX(rect, CGRectGetMaxX(containingRect));
}

CGRect CGRectAlignTopRight(CGRect rect, CGRect containingRect) {
	return CGRectAlignTop(CGRectAlignRight(rect, containingRect), containingRect);
}

CGRect CGRectAlignBottomRight(CGRect rect, CGRect containingRect) {
	return CGRectAlignBottom(CGRectAlignRight(rect, containingRect), containingRect);
}

CGRect CGRectAlignTopLeft(CGRect rect, CGRect containingRect) {
	return CGRectAlignTop(CGRectAlignLeft(rect, containingRect), containingRect);
}

CGRect CGRectAlignBottomLeft(CGRect rect, CGRect containingRect) {
	return CGRectAlignBottom(CGRectAlignLeft(rect, containingRect), containingRect);
}

CGRect CGRectAlignCenterVertical(CGRect rect, CGRect containingRect) {
	return CGRectWithCenterY(rect, CGRectGetMidY(containingRect));
}

CGRect CGRectAlignCenterHorizontal(CGRect rect, CGRect containingRect) {
	return CGRectWithCenterX(rect, CGRectGetMidX(containingRect));
}

CGRect CGRectAlignCenter(CGRect rect, CGRect containingRect) {
	return CGRectAlignCenterHorizontal(CGRectAlignCenterVertical(rect, containingRect), containingRect);
}

CGRect CGRectAlignCenterTop(CGRect rect, CGRect containingRect) {
	return CGRectAlignCenterHorizontal(CGRectAlignTop(rect, containingRect), containingRect);
}

CGRect CGRectAlignCenterLeft(CGRect rect, CGRect containingRect) {
	return CGRectAlignCenterVertical(CGRectAlignLeft(rect, containingRect), containingRect);
}

CGRect CGRectAlignCenterBottom(CGRect rect, CGRect containingRect) {
	return CGRectAlignCenterHorizontal(CGRectAlignBottom(rect, containingRect), containingRect);
}

CGRect CGRectAlignCenterRight(CGRect rect, CGRect containingRect) {
	return CGRectAlignCenterVertical(CGRectAlignRight(rect, containingRect), containingRect);
}

CGRect CGRectWithOrigin(CGRect rect, CGPoint origin) {
	CGRect newRect = CGRectMake(origin.x, origin.y, rect.size.width, rect.size.height);
	return newRect;
}

CGRect CGRectWithOriginX(CGRect rect, CGFloat originX) {
	return CGRectWithOrigin(rect, CGPointMake(originX, rect.origin.y));
}

CGRect CGRectWithOriginY(CGRect rect, CGFloat originY) {
	return CGRectWithOrigin(rect, CGPointMake(rect.origin.x, originY));
}

CGRect CGRectWithExtent(CGRect rect, CGPoint extent) {
	CGPoint origin = CGPointMake(extent.x - rect.size.width, extent.y - rect.size.height);
	return CGRectWithOrigin(rect, origin);
}

CGRect CGRectWithExtentX(CGRect rect, CGFloat extentX) {
	return CGRectWithExtent(rect, CGPointMake(extentX, CGRectGetMaxY(rect)));
}

CGRect CGRectWithExtentY(CGRect rect, CGFloat extentY) {
	return CGRectWithExtent(rect, CGPointMake(CGRectGetMaxX(rect), extentY));
}

CGRect CGRectOffsetPoint(CGRect rect, CGPoint offsetPoint) {
	return CGRectOffset(rect, offsetPoint.x, offsetPoint.y);
}

CGRect CGRectOffsetX(CGRect rect, CGFloat offsetX) {
	return CGRectOffset(rect, offsetX, 0.0f);
}

CGRect CGRectOffsetY(CGRect rect, CGFloat offsetY) {
	return CGRectOffset(rect, 0.0f, offsetY);
}

CGRect CGRectWithSize(CGRect rect, CGSize size) {
	CGRect newRect = CGRectMake(rect.origin.x, rect.origin.y, size.width, size.height);
	return newRect;
}

CGRect CGRectWithWidth(CGRect rect, CGFloat width) {
	return CGRectWithSize(rect, CGSizeMake(width, rect.size.height));
}

CGRect CGRectWithHeight(CGRect rect, CGFloat height) {
	return CGRectWithSize(rect, CGSizeMake(rect.size.width, height));
}

CGRect CGRectWithDeltaSize(CGRect rect, CGSize sizeDelta) {
	return CGRectWithSize(rect, CGSizeWithDeltaSize(rect.size, sizeDelta));
}

CGRect CGRectWithDeltaWidth(CGRect rect, CGFloat widthDelta) {
	return CGRectWithDeltaSize(rect, CGSizeMake(widthDelta, 0.0f));
}

CGRect CGRectWithDeltaHeight(CGRect rect, CGFloat heightDelta) {
	return CGRectWithDeltaSize(rect, CGSizeMake(0.0f, heightDelta));
}

CGSize CGSizeWithDeltaSize(CGSize size, CGSize sizeDelta) {
	return CGSizeMake(size.width + sizeDelta.width, size.height + sizeDelta.height);
}

CGSize CGSizeWithDeltaHeight(CGSize size, CGFloat heightDelta) {
	return CGSizeWithDeltaSize(size, CGSizeMake(0.0f, heightDelta));
}

CGSize CGSizeWithDeltaWidth(CGSize size, CGFloat widthDelta) {
	return CGSizeWithDeltaSize(size, CGSizeMake(widthDelta, 0.0f));
}

CGRect CGRectTrimTop(CGRect rect, CGFloat trimHeight) {
	return CGRectWithExtentY(CGRectWithDeltaHeight(rect, -trimHeight), CGRectGetMaxY(rect));
}

CGRect CGRectTrimBottom(CGRect rect, CGFloat trimHeight) {
	return CGRectWithDeltaHeight(rect, -trimHeight);
}

CGRect CGRectTrimLeft(CGRect rect, CGFloat trimWidth) {
	return CGRectWithExtentX(CGRectWithDeltaWidth(rect, trimWidth), CGRectGetMaxX(rect));
}

CGRect CGRectTrimRight(CGRect rect, CGFloat trimWidth) {
	return CGRectWithDeltaWidth(rect, trimWidth);
}

CGRect CGRectMakeBounds(CGSize size) {
	return CGRectMake(0.0f, 0.0f, size.width, size.height);
}

CGRect CGRectMakeWithPointAndSize(CGPoint point, CGSize size) {
	CGRect newRect = CGRectMake(point.x, point.y, size.width, size.height);
	return newRect;
}

CGRect CGRectMakeWithExtent(CGPoint extent) {
	return CGRectMake(0.0f, 0.0f, extent.x, extent.y);
}

CGRect CGRectWithCenter(CGRect rect, CGPoint center) {
	CGRect newRect = CGRectMake(center.x - rect.size.width / 2.0f, center.y - rect.size.height / 2.0f, rect.size.width, rect.size.height);
	return newRect;
}

CGRect CGRectWithCenterX(CGRect rect, CGFloat centerX) {
	return CGRectWithCenter(rect, CGPointMake(centerX, CGRectGetMidY(rect)));
}

CGRect CGRectWithCenterY(CGRect rect, CGFloat centerY) {
	return CGRectWithCenter(rect, CGPointMake(CGRectGetMidX(rect), centerY));
}

CGRect CGRectCenterWithSize(CGRect rect, CGSize size) {
	CGPoint center = CGRectGetCenter(rect);
	CGRect newRect = CGRectWithSize(rect, size);
	return CGRectWithCenter(newRect, center);
}

CGRect CGRectCenterWithWidth(CGRect rect, CGFloat width) {
	return CGRectCenterWithSize(rect, CGSizeMake(width, rect.size.height));
}

CGRect CGRectCenterWithHeight(CGRect rect, CGFloat height) {
	return CGRectCenterWithSize(rect, CGSizeMake(rect.size.width, height));
}

CGRect CGRectRoundedDown(CGRect rect) {
	return CGRectMake(floorf(rect.origin.x), floorf(rect.origin.y), rect.size.width, rect.size.height);
}

CGPoint CGPointOffset(CGPoint point, CGPoint offset) {
	return CGPointMake(point.x + offset.x, point.y + offset.y);
}

CGPoint CGPointOffsetX(CGPoint point, CGFloat xOffset) {
	return CGPointMake(point.x + xOffset, point.y);
}

CGPoint CGPointOffsetY(CGPoint point, CGFloat yOffset) {
	return CGPointMake(point.x, point.y + yOffset);
}
