//
//  ViewController.swift
//  GlKitTest
//
//  Created by Adam Nagy on 10/11/2015.
//  Copyright © 2015 Adam Nagy. All rights reserved.
//

import UIKit
import GLKit

class ViewController: UIViewController,
GLKViewDelegate {
  
  var effect: GLKBaseEffect?
  var distance: Float = 2
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Initialize the system
    let view: GLKView = (self.view as? GLKView)!
    view.context = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
    
    // You can also set this in the storyboard
    view.delegate = self
    EAGLContext.setCurrentContext(view.context)
    effect = GLKBaseEffect()
    let aspect = fabs(self.view.bounds.size.width/self.view.bounds.size.height)
    
    let projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0), Float(aspect), 0.1, 10.0)
    
    effect!.transform.projectionMatrix = projectionMatrix
    effect!.transform.modelviewMatrix = GLKMatrix4MakeLookAt(
      0,0,distance,
      0,0,0,
      0,1,0)
    
    // Or set "Enable setNeedsDisplay" e.g. in storyboard
    view.enableSetNeedsDisplay = true
  }
  
  func glkView(view: GLKView, drawInRect rect: CGRect) {
    // Set background color
    glClearColor(0.65,0.65,0.65,1.0)
    glClear(GLenum(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
    // Render the object with GLKit
    glEnable(GLenum(GL_DEPTH_TEST))
    //glEnable(GLenum(GL_CULL_FACE))
    glDepthFunc(GLenum(GL_LEQUAL))
    let vertices: [GLfloat] = [
		    0.0, 0.5, 0.0,
      -0.5, 0.0, 0.0,
		    0.5, 0.0, 0.0,
		    0.0, -0.5, 0.0,
		    0.5, 0.0, 0.0,
      -0.5, 0.0, 0.0]
    
    effect!.constantColor = GLKVector4Make(1,0,0,1)
    effect!.prepareToDraw()
    // 1: number of float per vertex
    // 2: type
    // 3: distance between vertices
    // 4: pointer to vertices
    glVertexAttribPointer(GLuint(GLKVertexAttrib.Position.rawValue),3,GLenum(GL_FLOAT),0,0,vertices)
    // Enable its use
    glEnableVertexAttribArray(GLuint(GLKVertexAttrib.Position.rawValue))
    // 1: type
    // 2: start index
    // 3: number of vertices
    glDrawArrays(GLenum(GL_TRIANGLES),0,6)
  }
  
  func rotateMatrix(rotX: CGFloat?, rotY: CGFloat?, rotZ: CGFloat?) {
    var mx = effect!.transform.modelviewMatrix;
    
    // In this function we are providing the coordinates in
    // OpenGL coordinate system (x, y, z)
    // So the below toOrigin translation is acting along the z axis,
    // which is perpendicular to the screen
    // Here 'toOrigin' means translation to the origin of the
    // OpenGL coordinate system (screen/view center)
    let toOrigin = GLKMatrix4MakeTranslation(0, 0, distance);
    mx = GLKMatrix4Multiply(toOrigin, mx);
    
    if (rotX != nil) {
      mx = GLKMatrix4Multiply(GLKMatrix4MakeXRotation(Float(rotX!)), mx)
    }
    
    if (rotY != nil) {
      mx = GLKMatrix4Multiply(GLKMatrix4MakeYRotation(Float(rotY!)), mx)
    }
    
    if (rotZ != nil) {
      mx = GLKMatrix4Multiply(GLKMatrix4MakeZRotation(Float(rotZ!)), mx)
    }
    
    let fromOrigin = GLKMatrix4MakeTranslation(0, 0, -distance);
    mx = GLKMatrix4Multiply(fromOrigin, mx);
    
    effect!.transform.modelviewMatrix = mx;
  }
  
  @IBAction func onPan(sender: UIPanGestureRecognizer) {
    
    struct funcData {
      static var prevPoint = CGPoint()
      static var numOfTouches = 0
    }
    
    if (sender.state == UIGestureRecognizerState.Began) {
      funcData.prevPoint = sender.locationInView(view)
      
      // Number of touches can change, so better stick to the one that
      // is started
      
      funcData.numOfTouches = sender.numberOfTouches()
    } else if (sender.state == UIGestureRecognizerState.Changed &&
      funcData.numOfTouches == sender.numberOfTouches()) {
      let pt: CGPoint = sender.locationInView(view)
      
      // Two touches is rotation
      if (funcData.numOfTouches == 1) {
        let rotX: CGFloat? = (pt.y - funcData.prevPoint.y) / 180;
        let rotY: CGFloat? = (pt.x - funcData.prevPoint.x) / 180;
        
        rotateMatrix(rotX, rotY: rotY, rotZ: nil)
      }
      
      funcData.prevPoint = pt;
      
      view.setNeedsDisplay()
    }
    
    NSLog("onPan with state \(sender.state) and number \(sender.numberOfTouches())");
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}

