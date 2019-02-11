#import "CartoTypeMapView.h"

@implementation CartoTypeMapView

// instance variables
{
CartoTypeFramework* m_framework;
CartoTypeMapRenderer* m_map_renderer;
}

-(id)initWithFrame:(CGRect)aFrame
    {
    EAGLContext* opengl_context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    self = [super initWithFrame:aFrame context:opengl_context];
    if (self)
        self.drawableDepthFormat = GLKViewDrawableDepthFormat24; // so that 3D buildings work
    return self;
    }

-(void)setFramework:(CartoTypeFramework*)aFramework
    {
    m_framework = aFramework;
    m_map_renderer = nil;
    }

-(void)drawRect:(CGRect)rect
    {
    if (m_map_renderer == nil && m_framework != nil)
        m_map_renderer = [[CartoTypeMapRenderer alloc] init:m_framework];
    if (m_map_renderer)
        [m_map_renderer draw];
    }

@end
