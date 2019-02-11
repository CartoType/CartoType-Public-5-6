#import <GLKit/GLKit.h>
#import <CartoType/CartoType.h>

/** A view class for drawing maps using graphics acceleration. */
@interface CartoTypeMapView: GLKView

-(id)initWithFrame:(CGRect)aFrame;

/** Sets the CartoTypeFramework to be drawn. */
-(void)setFramework:(CartoTypeFramework*)aFramework;

/** Draws the current CartoTypeFramework. */
-(void)drawRect:(CGRect)rect;

@end
