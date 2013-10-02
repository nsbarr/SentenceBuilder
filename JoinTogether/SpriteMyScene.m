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
static const uint32_t shipCategory        =  0x1 << 1;




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




-(SKSpriteNode *)word2 {
    SKSpriteNode *testNode = [[SKSpriteNode alloc] init];//parent
    SKLabelNode *hello = [SKLabelNode labelNodeWithFontNamed:@"Courier-Bold"];
    [testNode addChild:hello];
    testNode.name= @"world";
    hello.text = @"World!";
    hello.fontSize = 20;
    testNode.position = CGPointMake(CGRectGetMidX(self.frame),
                                 CGRectGetMidY(self.frame)-200);
    testNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:hello.frame.size];
    testNode.physicsBody.dynamic = NO;
    testNode.physicsBody.contactTestBitMask = rockCategory;
    testNode.physicsBody.categoryBitMask = shipCategory;


//    testNode.anchorPoint = CGPointMake(0.5,0.0);
    SKAction *getintoposition = [SKAction sequence:@[
                                                     [SKAction rotateToAngle:(M_PI/2) duration:1]]];
    [testNode runAction: getintoposition];

    return testNode;
    
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



- (void)addWord
{
    SKSpriteNode *testNode = [[SKSpriteNode alloc] init];//parent
    SKLabelNode *hello = [SKLabelNode labelNodeWithFontNamed:@"Courier-Bold"];
    [testNode addChild:hello];
    testNode.name = @"testNode";
    hello.text = @"Hello!";
    hello.fontSize = 20;
     testNode.position = CGPointMake(skRand(0, self.size.width), self.size.height+100);
     testNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:hello.frame.size];
 testNode.physicsBody.usesPreciseCollisionDetection = YES;
    SKAction *getintoposition = [SKAction sequence:@[
                                                     [SKAction rotateToAngle:(M_PI/rndValue(1.8,2.2)) duration:0]]];
    [testNode runAction: getintoposition];
    
    [self addChild: testNode];
    testNode.physicsBody.collisionBitMask = rockCategory;
    testNode.physicsBody.categoryBitMask = rockCategory;
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
    if (contact.bodyA.categoryBitMask != contact.bodyB.categoryBitMask){
        SKPhysicsBody *firstBody, *secondBody;

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


        [self rock:(SKSpriteNode *) firstBody.node didCollideWithShip:(SKSpriteNode *) secondBody.node];
        
    }

}

- (void)rock:(SKSpriteNode *)rock didCollideWithShip:(SKSpriteNode *)ship {
    
   // SKNode *testNode = [self childNodeWithName:@"world"];
    CGPoint samespot = rock.position;
    [rock removeFromParent];
    [ship addChild:rock];
    rock.physicsBody.contactTestBitMask = rockCategory;
    rock.physicsBody.categoryBitMask = shipCategory;
    rock.physicsBody.dynamic = NO;
    rock.position = samespot;
    NSLog(@"word on ship contact");

}


- (void)createSceneContents
{
    SKSpriteNode *world = [self word2];

 
    
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
}

@end
