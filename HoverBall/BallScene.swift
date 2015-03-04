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

class BallScene: SKScene {

    var names = [String]()
    var touchHashes = [Int]()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        physicsWorld.gravity = CGVectorMake(0, -6)
    }
    
    func addFloor(color: SKColor, size: CGSize) {
        let floor = SKSpriteNode(color: color, size: size)
        floor.anchorPoint = CGPoint(x: 0, y: 0)
//        floorNode.physicsBody = SKPhysicsBody(edgeLoopFromRect: frame) // jumps back from sides of the scene
        floor.physicsBody = SKPhysicsBody(edgeLoopFromRect: floor.frame) // jumps back from the floor
        floor.physicsBody?.dynamic = false
        addChild(floor)
    }
    
    func addBall(name: String, color: SKColor, radius: Int, position: CGPoint) {
        let ball = SKShapeNode(circleOfRadius: CGFloat(radius))
        ball.name = name
        let physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(radius))
        physicsBody.restitution = 0.7 // bounciness
        physicsBody.mass = 0.5
        physicsBody.friction = 0.7
        physicsBody.dynamic = true
        ball.physicsBody = physicsBody
        ball.position = position
        ball.fillColor = color
        addChild(ball	)
        names += [name]
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        for touch in touches {
            let touch = touch as UITouch
            let node = nodeAtPoint(touch.locationInNode(self))
            if isTouchingNode(touch as UITouch, node: node) {
                // Disable gravity for the touched node
                node.physicsBody?.affectedByGravity = false
                // Add hash to array
                touchHashes += [touch.hash]
            }
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        for touch in touches {
            let touch = touch as UITouch
            let node = nodeAtPoint(touch.locationInNode(self))
            if isTouchingNode(touch as UITouch, node: node) {
                // Re-enable gravity for the touched node
                node.physicsBody?.affectedByGravity = true
                // Remove hash from array
                touchHashes = touchHashes.filter({$0 == touch.hash})
            }
        }
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        touchesEnded(touches, withEvent: event)
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        for touch in touches {
            let touch = touch as UITouch
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