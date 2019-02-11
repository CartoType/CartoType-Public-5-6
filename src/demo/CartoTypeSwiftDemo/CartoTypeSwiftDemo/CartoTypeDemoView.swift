//
//  CartoTypeDemoView.swift
//  CartoTypeSwiftDemo
//
//  Created by Graham Asher on 21/11/2016.
//  Copyright © 2016-2018 CartoType Ltd. All rights reserved.
//

import UIKit
import GLKit

/** A view class for drawing maps using graphics acceleration. */
class CartoTypeDemoView : GLKView
{
    var m_framework : CartoTypeFramework?
    var m_map_renderer : CartoTypeMapRenderer?
    
    override init(frame aFrame: CGRect)
    {
        let opengl_context = EAGLContext.init(api: EAGLRenderingAPI.openGLES2)
        super.init(frame: aFrame, context:opengl_context!);
        self.drawableDepthFormat = GLKViewDrawableDepthFormat.format24 // so that 3D buildings work
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.context = EAGLContext.init(api: EAGLRenderingAPI.openGLES2)
        self.drawableDepthFormat = GLKViewDrawableDepthFormat.format24 // so that 3D buildings work
    }
    
    func setFramework(_ aFramework: CartoTypeFramework!)
    {
        m_framework = aFramework
        m_map_renderer = nil;
    }
    
    override func draw(_ rect: CGRect)
    {
        if (m_map_renderer == nil && m_framework != nil)
            {
            m_map_renderer = CartoTypeMapRenderer.init(_: m_framework)
            }
        
        if (m_map_renderer != nil)
            {
            m_map_renderer!.draw();
            }
    }
}
