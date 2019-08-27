//
//  GameScene.swift
//  Flappy Bird (Clone)
//  Mini project from Udemy (iOS10 & Swift 3 complete developer) course
//
//  Created by admin on 22/02/2018.
//  Copyright © 2018 Josh_Dog101. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var bird          = SKSpriteNode()
    var bg            = SKSpriteNode()
    var score:Int     = 0
    var scoreLabel    = SKLabelNode()
    var gameOverLabel = SKLabelNode()
    var timer         = Timer()
    var gameOver      = false
    
    enum ColliderType: UInt32 {
        case Bird    = 1
        case Object  = 2
        case Gap     = 4
    }
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        gameSetup()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !gameOver {
            bird.physicsBody!.isDynamic = true
            bird.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 0))
            bird.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 50))
        } else {
            gameOver   = false
            score      = 0
            self.speed = 1
            self.removeAllChildren()
            gameSetup()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    @objc func makePipes() {
        
        let movePipes      = SKAction.move(by: CGVector.init(dx: -2 * self.frame.width, dy: 0), duration: TimeInterval(self.frame.width / 100))
        let gapHeight      = bird.size.height * 4
        let movementAmount = arc4random() % UInt32(self.frame.height / 2)
        let pipeOffset     = CGFloat(movementAmount) - (self.frame.height / 4)
        
        let pipe1Texture   = SKTexture(imageNamed: "pipe1.png")
        let pipe1          = SKSpriteNode(texture: pipe1Texture)
        let pipe2Texture   = SKTexture(imageNamed: "pipe2.png")
        let pipe2          = SKSpriteNode(texture: pipe2Texture)
        let gap            = SKNode()
        
        pipe1.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + pipe1Texture.size().height / 2 + gapHeight / 2 + pipeOffset)
        pipe2.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY - pipe2Texture.size().height / 2 - gapHeight / 2 + pipeOffset)
        gap.position   = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + pipeOffset)
        
        pipe1.run(movePipes)
        pipe2.run(movePipes)
        gap.run(movePipes)
        
        pipe1.physicsBody = SKPhysicsBody(rectangleOf: pipe1Texture.size())
        pipe2.physicsBody = SKPhysicsBody(rectangleOf: pipe2Texture.size())
        gap.physicsBody   = SKPhysicsBody(rectangleOf: CGSize(width: pipe1Texture.size().width, height: gapHeight))
        
        pipe1.physicsBody!.isDynamic = false
        pipe2.physicsBody!.isDynamic = false
        gap.physicsBody!.isDynamic   = false
        
        pipe1.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        pipe1.physicsBody!.categoryBitMask    = ColliderType.Object.rawValue
        pipe1.physicsBody!.collisionBitMask   = ColliderType.Object.rawValue
        pipe2.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        pipe2.physicsBody!.categoryBitMask    = ColliderType.Object.rawValue
        pipe2.physicsBody!.collisionBitMask   = ColliderType.Object.rawValue
        gap.physicsBody!.contactTestBitMask   = ColliderType.Bird.rawValue
        gap.physicsBody!.categoryBitMask      = ColliderType.Gap.rawValue
        gap.physicsBody!.collisionBitMask     = ColliderType.Gap.rawValue
        
        pipe1.zPosition = -1
        pipe2.zPosition = -1
        
        self.addChild(pipe1)
        self.addChild(pipe2)
        self.addChild(gap)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if !gameOver  {
            if contact.bodyA.categoryBitMask == ColliderType.Gap.rawValue || contact.bodyB.categoryBitMask == ColliderType.Gap.rawValue {
                score += 1
                scoreLabel.text = String(score)
            } else {
                gameOverLabel.fontName  = "Helvetica"
                gameOverLabel.fontSize  = 60
                gameOverLabel.text      = "Game Over! Tap to play again."
                gameOverLabel.position  = CGPoint(x: self.frame.midX, y: self.frame.midY)
                gameOverLabel.zPosition = 2
                gameOver                = true
                
                timer.invalidate()
                self.speed = 0
            }
        }
    }
    
    func gameSetup() {
        
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.makePipes), userInfo: nil, repeats: true)
        
        let bgTexture    = SKTexture(imageNamed: "bg.png")
        let birdTexture  = SKTexture(imageNamed: "flappy1.png")
        let birdTexture2 = SKTexture(imageNamed: "flappy2.png")
        let ground       = SKNode()
        let animation    = SKAction.animate(with: [birdTexture, birdTexture2], timePerFrame: 0.1)
        let makeBirdFlap = SKAction.repeatForever(animation)
        
        let moveBGAnimation  = SKAction.move(by: CGVector.init(dx: -bgTexture.size().width, dy: 0), duration: 7)
        let shiftBGAnimation = SKAction.move(by: CGVector.init(dx: bgTexture.size().width, dy: 0), duration: 0)
        let animateBg        = SKAction.repeatForever(SKAction.sequence([moveBGAnimation, shiftBGAnimation]))
        var i:CGFloat        = 0.0
        
        while (i < 3) {
            bg             = SKSpriteNode(texture: bgTexture)
            bg.position    = CGPoint(x: bgTexture.size().width * i, y: self.frame.midY)
            bg.size.height = self.frame.height
            bg.run(animateBg)
            bg.zPosition   = -2
            self.addChild(bg)
            i += 1
        }
        
        bird = SKSpriteNode(texture: birdTexture)
        
        bird.position   = CGPoint(x: self.frame.midX, y: self.frame.midY)
        ground.position = CGPoint(x: self.frame.midX, y: -self.frame.height / 2)
        
        bird.run(makeBirdFlap)
        
        bird.physicsBody   = SKPhysicsBody(circleOfRadius: birdTexture.size().height / 2)
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1))
        
        bird.physicsBody!.isDynamic   = false
        ground.physicsBody!.isDynamic = false
        
        bird.physicsBody!.contactTestBitMask   = ColliderType.Object.rawValue
        bird.physicsBody!.categoryBitMask      = ColliderType.Bird.rawValue
        bird.physicsBody!.collisionBitMask     = ColliderType.Bird.rawValue
        ground.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        ground.physicsBody!.categoryBitMask    = ColliderType.Object.rawValue
        ground.physicsBody!.collisionBitMask   = ColliderType.Object.rawValue
        
        scoreLabel.fontName = "Helvetica"
        scoreLabel.fontSize = 60
        scoreLabel.text     = "0"
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.height / 2 - 70)
        
        self.addChild(bird)
        self.addChild(ground)
        self.addChild(scoreLabel)
    }
}
