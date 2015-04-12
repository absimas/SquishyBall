//
//  BallScene.swift
//  HoverBall
//
//  Created by Simas Abramovas on 04/03/15.
//  Copyright (c) 2015 Simas Abramovas. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

class BallScene: SKScene, SKPhysicsContactDelegate {

    var names = [String]()
    var touchHashes = [Int]()
    
    // Bit masks
    let floorCategory: UInt32 = 0x1 << 0;
    let sceneCategory: UInt32  = 0x1 << 1;
    let ballCategory: UInt32  = 0x1 << 2;
    
    // Limitations
    let maxScaleBy = CGFloat(4/5.0)
    let maxImpulse = CGFloat(900)
    let minImpulse = CGFloat(100)
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        physicsWorld.gravity = CGVectorMake(0, -6)
        physicsBody?.categoryBitMask = sceneCategory
        physicsBody?.contactTestBitMask = sceneCategory | ballCategory
        physicsBody?.collisionBitMask = sceneCategory | ballCategory
        physicsWorld.contactDelegate = self
    }
    
    // Contact delegate
    func didBeginContact(contact: SKPhysicsContact) {
        var ballNode: SKNode?
        // Impulse must be higher than 30
        if contact.collisionImpulse > minImpulse {
            // Check if a ball is involved in the contact
            let nodeBName = contact.bodyB.node?.name
            if let nodeName = contact.bodyA.node?.name {
                if contains(names, nodeName) {
                    println("A is a ball and the impulse is \(contact.collisionImpulse)")
                    ballNode = contact.bodyA.node
                }
            } else if let nodeName = contact.bodyB.node?.name {
                if contains(names, nodeName) {
                    println("B is a ball and the impulse is \(contact.collisionImpulse)")
                    ballNode = contact.bodyB.node
                }
            } else {
                return;
            }
            
            squashNode(ballNode!, collisionImpulse: contact.collisionImpulse)
        }
    }

    // ToDo anchor on the bottom of the ball? so it move up when Y axis is scaled
    func squashNode(node: SKNode, collisionImpulse: CGFloat) {
        if collisionImpulse < minImpulse {
            return
        }
        var impulse = max(collisionImpulse, maxImpulse)
        
        let xTo = 1 + (impulse / 9000)
        let yTo = 1 - (impulse / 9000)
        let interval = 0.2 - (impulse / 9000)
        
        var actions = Array<SKAction>();
        actions.append(SKAction.scaleXBy(xTo, y: yTo, duration: NSTimeInterval(interval)))
        actions.append(SKAction.scaleXBy(1/xTo, y: 1/yTo, duration: NSTimeInterval(interval)))
        let sequence = SKAction.sequence(actions);

        node.runAction(sequence)
    }
    
    func addFloor(color: SKColor, size: CGSize) {
        let floor = SKSpriteNode(color: color, size: size)
        floor.anchorPoint = CGPoint(x: 0, y: 0)
        
        // Physics
        let physicsBody = SKPhysicsBody(edgeLoopFromRect: frame) // use scene frame edges
        physicsBody.dynamic = false
        physicsBody.categoryBitMask = floorCategory
        physicsBody.contactTestBitMask = floorCategory | ballCategory
        physicsBody.collisionBitMask = floorCategory | ballCategory
        floor.physicsBody = physicsBody
        
        addChild(floor)
    }
    
    func addBall(name: String, color: SKColor, radius: Int, position: CGPoint) {
        let ball = SKShapeNode(circleOfRadius: CGFloat(radius))
        ball.name = name
        // Physics
        let physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(radius))
        physicsBody.restitution = 0.7 // bounciness
        physicsBody.mass = 0.4
        physicsBody.friction = 0.7
        physicsBody.dynamic = true
        physicsBody.categoryBitMask = ballCategory
        physicsBody.contactTestBitMask = ballCategory | floorCategory | sceneCategory
        physicsBody.collisionBitMask = ballCategory | floorCategory | sceneCategory
        ball.physicsBody = physicsBody
        
        ball.position = position
        ball.fillColor = color
        addChild(ball)
        names += [name]
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch in touches {
            let touch = touch as! UITouch
            let node = nodeAtPoint(touch.locationInNode(self))
            if isTouchingNode(touch as UITouch, node: node) {
                // Disable gravity for the touched node
                node.physicsBody?.affectedByGravity = false
                // Add hash to array
                touchHashes += [touch.hash]
            }
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch in touches {
            let touch = touch as! UITouch
            let node = nodeAtPoint(touch.locationInNode(self))
            if isTouchingNode(touch as UITouch, node: node) {
                // Re-enable gravity for the touched node
                node.physicsBody?.affectedByGravity = true
                // Remove hash from array
                touchHashes = touchHashes.filter({$0 == touch.hash})
            }
        }
    }
    
    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        touchesEnded(touches, withEvent: event)
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch in touches {
            let touch = touch as! UITouch
            let node = nodeAtPoint(touch.locationInNode(self))
            if isNodeTouchEvent(touch as UITouch) {
                // Move the node  to the specified point
                node.position = touch.locationInNode(self)
            }
        }
    }
    
    func isTouchingNode(touch: UITouch, node: SKNode) -> Bool {
        if let name = node.name {
            if contains(names, name)  {
                return true;
            }
        }
        return false
    }
    
    func isNodeTouchEvent(touch: UITouch) -> Bool {
        return contains(touchHashes, touch.hash);
    }

}