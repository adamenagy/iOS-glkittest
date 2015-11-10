//
//  ViewController.m
//  GlKitTest
//
//  Created by Adam Nagy on 11/11/2012.
//  Copyright (c) 2012 Adam Nagy. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()
  @property (strong, nonatomic) GLKBaseEffect * effect;
@end

@implementation ViewController

@synthesize effect;



- (void)viewDidLoad
{
  [super viewDidLoad];
  
  // Initialize the system
  
  GLKView * view = (GLKView *)self.view;
  view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
  
  // You can also set this in the storyboard
  view.delegate = self;
  
  [EAGLContext setCurrentContext:view.context];
  
  self.effect = [[GLKBaseEffect alloc] init];
  
  float aspect = fabs(self.view.bounds.size.width / self.view.bounds.size.height);
  GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 10.0f);
  self.effect.transform.projectionMatrix = projectionMatrix;
  
  self.effect.transform.modelviewMatrix = GLKMatrix4MakeLookAt(
    0, 0, 2,  // eye
    0, 0, 0,  // center
    0, 1, 0); // up vector
  
  // Or set "Enable setNeedsDisplay" e.g. in storyboard
  [view display];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
  // Set background color

  glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
  
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
  // Render the object with GLKit
  
  glEnable(GL_DEPTH_TEST);
  glEnable(GL_CULL_FACE);
  glDepthFunc(GL_LEQUAL);
  
  GLfloat vertices[] = {
    0.0, 0.5, 0.0,
   -0.5, 0.0, 0.0,
    0.5, 0.0, 0.0,
    0.0, -0.5, 0.0,
    0.5, 0.0, 0.0,
   -0.5, 0.0, 0.0};
  
  self.effect.constantColor = GLKVector4Make(1, 0, 0, 1);

  [self.effect prepareToDraw];
  
  // 1: number of float per vertex
  // 2: type
  // 3: distance between vertices
  // 4: pointer to vertices
  glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, 0, 0, vertices);

  // Enable its use
  glEnableVertexAttribArray(GLKVertexAttribPosition);

  // 1: type
  // 2: start index
  // 3: number of vertices
  glDrawArrays(GL_TRIANGLES, 0, 6);
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
