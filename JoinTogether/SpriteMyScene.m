//
//  SpriteMyScene.m
//  JoinTogether
//
//  Created by Nicholas Barr on 9/30/13.
//  Copyright (c) 2013 Nicholas Barr. All rights reserved.
//

#import "SpriteMyScene.h"

@interface SpriteMyScene () <SKPhysicsContactDelegate>
@property BOOL contentCreated;
@end

static const uint32_t rockCategory        =  0x1 << 0;
static const uint32_t stuckCategory        =  0x1 << 1;
static const uint32_t shipCategory        =  0x1 << 2;




@implementation SpriteMyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
   
    }
    return self;
}

- (void)didMoveToView: (SKView *) view
{
    if (!self.contentCreated)
    {
        [self createSceneContents];
        self.contentCreated = YES;
   
    }
    self.physicsWorld.gravity = CGVectorMake(0.0,-4.0);
    self.physicsWorld.contactDelegate = self;

}




-(SKLabelNode *)word2 {
    SKLabelNode *hello = [SKLabelNode labelNodeWithFontNamed:@"Courier-Bold"];
    hello.name= @"world";
    hello.text = @"World!";
    hello.fontSize = 20;
    hello.position = CGPointMake(CGRectGetMidX(self.frame),
                                 CGRectGetMidY(self.frame)-200);
    hello.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(hello.frame.size.width+30,hello.frame.size.height+50)];
    hello.physicsBody.dynamic = NO;
    hello.physicsBody.contactTestBitMask = rockCategory;
    hello.physicsBody.categoryBitMask = shipCategory;


//    testNode.anchorPoint = CGPointMake(0.5,0.0);
    SKAction *getintoposition = [SKAction sequence:@[
                                                     [SKAction rotateToAngle:(M_PI/2) duration:1]]];
    [hello runAction: getintoposition];

    return hello;
    
}


static inline CGFloat skRandf() {
    return rand() / (CGFloat) RAND_MAX;
}

static inline CGFloat skRand(CGFloat low, CGFloat high) {
    return skRandf() * (high - low) + low;
}

static inline CGFloat rndValue(CGFloat low, CGFloat high) {
    return skRandf() * (high - low) + low;
}

NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

-(NSString *) genRandStringLength: (int) len {
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    
    return randomString;
}


- (void)addWord
{
    //SKSpriteNode *testNode = [[SKSpriteNode alloc] init];//parent
    SKLabelNode *hello = [SKLabelNode labelNodeWithFontNamed:@"Courier-Bold"];
   // [testNode addChild:hello];
  //  testNode.name = @"testNode";
    hello.text = [self genRandStringLength:4];
    hello.fontSize = 20;
     hello.position = CGPointMake(skRand(0, self.size.width), self.size.height+100);
     hello.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:hello.frame.size];
 hello.physicsBody.usesPreciseCollisionDetection = YES;
    hello.zRotation = M_PI/rndValue(1.8,2.2);
//    SKAction *getintoposition = [SKAction sequence:@[
  //                                                   [SKAction rotateToAngle:(M_PI/rndValue(1.8,2.2)) duration:0]]];
  //  [hello runAction: getintoposition];
    
    [self addChild: hello];
    hello.physicsBody.collisionBitMask = 0;
    hello.physicsBody.contactTestBitMask = rockCategory;
    hello.physicsBody.categoryBitMask = rockCategory;
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
  
}


- (void)touchesEnded:(NSSet *) touches withEvent:(UIEvent *)event {
    SKNode *hello = [self childNodeWithName:@"world"];
    UITouch *touch = [touches anyObject];
    CGPoint pointToMove = [touch locationInNode: self];
    
    CGFloat xlocation = pointToMove.x;
    float speed = 1000;
    float distance = ABS(xlocation - hello.position.x)/1.0;
    float time = distance/speed;
    
    
    SKAction *teleport = [SKAction sequence:@[
                                              [SKAction waitForDuration:0],
                                              [SKAction moveTo:CGPointMake(xlocation, hello.position.y) duration:time]]];
    [hello runAction: [SKAction repeatAction: teleport count:(1)]];
   // NSString *realdistance = [NSString stringWithFormat:@"%f", distance];
}


- (void)didBeginContact:(SKPhysicsContact *)contact {

    NSLog(@"contact!");
    SKPhysicsBody *firstBody, *secondBody;

   if (contact.bodyA.categoryBitMask != contact.bodyB.categoryBitMask){
       

        if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
        {
            firstBody = contact.bodyA;
            secondBody = contact.bodyB;

            
        }
        else
        {
            firstBody = contact.bodyB;
            secondBody = contact.bodyA;
        
        }
        
       // [firstBody.node removeFromParent];
        firstBody.node.name = @"stuck";
       // firstBody.node.physicsBody.collisionBitMask = 0;
       // firstBody.node.physicsBody.contactTestBitMask = 0;
       // firstBody.node.physicsBody.categoryBitMask = 0;
       // [secondBody.node addChild:firstBody.node];
        //secondBody.node.name = @"stuck";
        //secondBody.node.physicsBody.collisionBitMask = 0;
        //secondBody.node.physicsBody.contactTestBitMask = 0;
        //secondBody.node.physicsBody.categoryBitMask = 0;
    }
    else {
           NSLog(@"cool rock on rock");
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
        firstBody.node.name = @"stuck";
        secondBody.node.name = @"stuck";

        
        
        }


}

- (void)rock:(SKSpriteNode *)rock didCollideWithShip:(SKSpriteNode *)ship {
    
   // SKNode *testNode = [self childNodeWithName:@"world"];
    CGPoint rockposition = [rock.scene convertPoint:rock.position toNode:ship];
    CGFloat rockorientation = rock.zRotation;
    rock.name = @"stuck";
//[rock removeFromParent];
//    rock.physicsBody.contactTestBitMask = 0;
//   rock.physicsBody.categoryBitMask = shipCategory;
//rock.physicsBody.dynamic = NO;
 //   rock.position = rockposition;
 //   rock.zRotation = rockorientation;
  //  [ship addChild:rock];


}


- (void)createSceneContents
{

    SKLabelNode *world = [self word2];

 
    
    [self addChild:world];
    
    SKAction *makeWord = [SKAction sequence: @[
                                                [SKAction performSelector:@selector(addWord) onTarget:self],
                                                [SKAction waitForDuration:.50 withRange:0.05]
                                                ]];
    [self runAction: [SKAction repeatActionForever:makeWord]];


}

-(void)didSimulatePhysics
{
    [self enumerateChildNodesWithName:@"testNode" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.y < 0)
            [node removeFromParent];
    }];
   
}




-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    SKNode *world = [self childNodeWithName:@"world"];

[self enumerateChildNodesWithName:@"stuck" usingBlock:^(SKNode *node, BOOL *stop) {
        [node removeFromParent];
        [world addChild:node];
        node.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(80,80)];
        node.physicsBody.categoryBitMask = rockCategory;
        node.physicsBody.contactTestBitMask = rockCategory;
        node.physicsBody.dynamic = NO;
        CGPoint desiredposition = CGPointMake(world.position.x, node.position.y);
        node.position = [node.scene convertPoint:desiredposition toNode:world];
        node.zRotation = 2*M_PI;
          }];
  
 }

@end
