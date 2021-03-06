//
//  GameSceneObjects.swift
//  Spacecraft
//
//  Created by Cassio Diego Tavares Campos on 16/05/20.
//  Copyright (c) 2020 Cassio Diego Tavares Campos. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

class GameSceneObjects: SKScene {

    var xAcceleration: CGFloat  = 0.0

    var player: SKSpriteNode = SKSpriteNode()
    var leftJet: SKSpriteNode = SKSpriteNode()
    var rightJet: SKSpriteNode = SKSpriteNode()
    var livesIcon: SKSpriteNode = SKSpriteNode()
    var scoreIcon: SKSpriteNode = SKSpriteNode()

    var explosion: SKSpriteNode!
    var fireLeft: SKSpriteNode!
    var fireRight: SKSpriteNode!

    let directions = Constants.Directions.self
    let collisions = Constants.CollisionCategories.self
    let assets = Constants.Assets.self
    let dataConfigKeys = Constants.DataConfigKeys.self
    let gameConfigInitialValues = Constants.GameConfigInitialValues.self
    
    let screenSize = UIScreen.main.bounds

    func alreadyExist(key: String) -> Bool { return UserDefaults.standard.object(forKey: key) != nil }

    func getKindShip() -> String {
        
        let playerChoosedShip = alreadyExist(key: dataConfigKeys.ship)
        !playerChoosedShip ? UserDefaults.standard.set(assets.armory, forKey: dataConfigKeys.ship) : nil
        return (UserDefaults.standard.object(forKey: dataConfigKeys.ship)! as? String)!
        
    }

    func setupPlayer() {

        var spritePlayer: String = ""
        self.getKindShip() == assets.armory ? (spritePlayer = assets.armory) : (spritePlayer = assets.rinzler)
        player = SKSpriteNode(imageNamed: spritePlayer)
        player.position = CGPoint(x: self.frame.size.width/2, y: player.size.height/2 + 30)
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width/2)
        player.physicsBody!.isDynamic = true
        player.physicsBody!.categoryBitMask = collisions.playerCategory
        player.physicsBody!.contactTestBitMask = collisions.rockCategory
        player.physicsBody!.categoryBitMask = collisions.EdgeBody
        player.physicsBody!.collisionBitMask = 0
        player.physicsBody!.usesPreciseCollisionDetection = true
        player.physicsBody?.velocity = CGVector(dx: xAcceleration * 900, dy: 0)
        player.zPosition = 5

        self.addChild(player)

        setupJet(x: self.player.position.x-10, y: self.player.position.y-30, side: self.directions.left)
        setupJet(x: self.player.position.x+10, y: self.player.position.y-30, side: self.directions.right)

    }

    func setupAurora() {

        let aurora: SKSpriteNode = SKSpriteNode(imageNamed: assets.auroraOne)

        aurora.zPosition = 2

        let minX = aurora.size.width/2
        let maxX = self.frame.size.width - aurora.size.width/2
        let rangeX = maxX - minX
        let position: CGFloat = CGFloat(arc4random()).truncatingRemainder(dividingBy: CGFloat(rangeX)) + CGFloat(minX)

        aurora.position = CGPoint(x: position, y: self.frame.size.height+aurora.size.height)

        self.addChild(aurora)

        let duration = 25
        var actionArray = [SKAction]()
        actionArray.append(SKAction.move(to: CGPoint(x: position, y: -aurora.size.height), duration: TimeInterval(duration)))
        actionArray.append(SKAction.removeFromParent())
        aurora.run(SKAction.sequence(actionArray))

    }

    func setupExplosion(x: CGFloat, y: CGFloat) {

       let boom = SKAction.repeatForever(
           SKAction.animate(with: [SKTexture(imageNamed: "e-1"), SKTexture(imageNamed: "e-2"), SKTexture(imageNamed: "e-3"),
                SKTexture(imageNamed: "e-4"), SKTexture(imageNamed: "e-5"), SKTexture(imageNamed: "e-6"),
                SKTexture(imageNamed: "e-7"), SKTexture(imageNamed: "e-8"), SKTexture(imageNamed: "e-9")],
                timePerFrame: 0.09))

       explosion = SKSpriteNode(texture: SKTexture(imageNamed: "e-1"))
       explosion.setScale(0.6)
       explosion.position = CGPoint(x: x, y: y)
       explosion.zPosition = 6
       explosion.run(boom)
       self.addChild(explosion)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.explosion.removeFromParent()
        }
       
    }
    
    func jetAnimation() -> SKAction {
        
        let anim = SKAction.animate(with: [SKTexture(imageNamed: "f-1"), SKTexture(imageNamed: "f-2"), SKTexture(imageNamed: "f-3"),
                                           SKTexture(imageNamed: "f-4"), SKTexture(imageNamed: "f-5"), SKTexture(imageNamed: "f-6"),
                                           SKTexture(imageNamed: "f-7"), SKTexture(imageNamed: "f-8"), SKTexture(imageNamed: "f-9"),
                                           SKTexture(imageNamed: "f-10"), SKTexture(imageNamed: "f-11"), SKTexture(imageNamed: "f-12"),
                                           SKTexture(imageNamed: "f-13"), SKTexture(imageNamed: "f-14"), SKTexture(imageNamed: "f-15"),
                                           SKTexture(imageNamed: "f-16"), SKTexture(imageNamed: "f-17"), SKTexture(imageNamed: "f-18"),
                                           SKTexture(imageNamed: "f-19"), SKTexture(imageNamed: "f-20"), SKTexture(imageNamed: "f-21"),
                                           SKTexture(imageNamed: "f-22"), SKTexture(imageNamed: "f-23"), SKTexture(imageNamed: "f-24"),
                                           SKTexture(imageNamed: "f-25"), SKTexture(imageNamed: "f-26"), SKTexture(imageNamed: "f-27"),
                                           SKTexture(imageNamed: "f-28"), SKTexture(imageNamed: "f-29"), SKTexture(imageNamed: "f-30"),
                                           SKTexture(imageNamed: "f-31"), SKTexture(imageNamed: "f-32"), SKTexture(imageNamed: "f-33"),
                                           SKTexture(imageNamed: "f-34"), SKTexture(imageNamed: "f-35"), SKTexture(imageNamed: "f-36"),
                                           SKTexture(imageNamed: "f-37"), SKTexture(imageNamed: "f-38"), SKTexture(imageNamed: "f-39")],
                                    timePerFrame: 0.09)
        return anim
        
    }
    
    func setupJet(x: CGFloat, y: CGFloat, side: String) {

        let anim = self.jetAnimation()
        let boom = SKAction.repeatForever(anim)
        let fire = SKSpriteNode(texture: SKTexture(imageNamed: "f-1"))
        fire.setScale(0.05)
        fire.position = CGPoint(x: x, y: y)
        fire.zPosition = 4
        fire.run(boom)

        if(side == directions.left) {
            fireLeft = fire
            self.addChild(fireLeft)
        } else if(side == directions.right) {
            fireRight = fire
            self.addChild(fireRight)
        }

    }
    
    func setupRock(_ rockType: NSString, score: Int) {
        
        let rock: SKSpriteNode = SKSpriteNode(imageNamed: rockType as String)
        let minX = rock.size.width/2
        let maxX = self.frame.size.width - rock.size.width/2
        let rangeX = maxX - minX
        let position: CGFloat = CGFloat(arc4random()).truncatingRemainder(dividingBy: CGFloat(rangeX)) + CGFloat(minX)
        rock.physicsBody = SKPhysicsBody(rectangleOf: rock.size)
        rock.physicsBody!.isDynamic = true
        rock.physicsBody!.categoryBitMask = collisions.rockCategory
        rock.physicsBody!.contactTestBitMask = collisions.shotCategory
        rock.physicsBody!.contactTestBitMask = collisions.playerCategory
        rock.physicsBody!.collisionBitMask = 0
        rock.zPosition = 4
        rock.position = CGPoint(x: position, y: self.frame.size.height+rock.size.height)
        self.addChild(rock)
        var minDuration = 2
        var maxDuration = 4
        if score > 50 {
            minDuration = 1
            maxDuration = 4
        } else if score > 100 {
            minDuration = 1
            maxDuration = 1
        }
        let rangeDuration = maxDuration - minDuration
        let duration = Int(arc4random_uniform(20)) % Int(rangeDuration) + Int(minDuration)
        var actionArray = [SKAction]()
        actionArray.append(SKAction.move(to: CGPoint(x: position, y: -rock.size.height), duration: TimeInterval(duration)))
        actionArray.append(SKAction.removeFromParent())
        rock.run(SKAction.sequence(actionArray))
        
    }
    
    func setupStars() {
        
        if let starParticles = SKEmitterNode(fileNamed: "StarEmitter.sks") {
            starParticles.position = CGPoint(x: size.width/2, y: size.height)
            starParticles.name = assets.starParticle
            starParticles.targetNode = scene
            addChild(starParticles)
        }
        
    }
    
    func setupHeader() {
        
        scoreIcon = SKSpriteNode(imageNamed: Constants.Assets.scoreIcon)
        scoreIcon.position = CGPoint(x: (screenSize.width * 0.12), y: (screenSize.height * 0.895))
        scoreIcon.zPosition = 2
        self.addChild(scoreIcon)
        
        livesIcon = SKSpriteNode(imageNamed: Constants.Assets.heartIcon)
        livesIcon.position = CGPoint(x: (screenSize.width * 0.48), y: (screenSize.height * 0.895))
        livesIcon.zPosition = 2
        self.addChild(livesIcon)
        
    }
}
