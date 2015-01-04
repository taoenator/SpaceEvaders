//
//  GameScene.swift
//  SpaceEvaders
//
//  Created by Tristen Miller on 12/24/14.
//  Copyright (c) 2014 Tristen Miller. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    let alienSpawnRate = 5
    var isGameOver = false
    var score: Int = 0
    let scoreboard = SKLabelNode(text: "Score: 0")
    var rocket: Sprite!
    var aliens = NSMutableSet()
    var powerups = NSMutableSet()
    var fireArray = Array<SKTexture>();
    
    override func didMoveToView(view: SKView) {
        setupBackground()
        rocketSetup()
        scoreBoard()
    }
    
    func rocketSetup() {
        rocket = Sprite(imageNamed:"rocket", name:"rocket", x: size.width/2, y: size.height/2).addTo(self)
        for index in 0...2 {
            fireArray.append(SKTexture(imageNamed: "fire" + String(index)))
        }
        var fire = SKSpriteNode(texture:fireArray[0]);
        fire.anchorPoint = CGPoint(x: 0.5, y: 1.3)
        rocket.sprite.addChild(fire)
        let animateAction = SKAction.animateWithTextures(self.fireArray, timePerFrame: 0.10);
        fire.runAction(SKAction.repeatActionForever(animateAction))
    }
    
    func scoreBoard() {
        scoreboard.setScale(2.5)
        scoreboard.position = CGPoint(x: size.width/6, y: size.height - size.height/5)
        scoreboard.horizontalAlignmentMode = .Right
        self.addChild(scoreboard)
    }
    
    func setupBackground() {
        let background = UIImage(named: "space1.jpg")
        backgroundColor = UIColor(patternImage: background!)
        fadeMainLaser()
        backAndForth()
        Sprite(imageNamed: "laserside", x: size.width/100, y: size.height/2).addTo(self)
        Sprite(imageNamed: "laserside", x: size.width - size.width/100, y: size.height/2).addTo(self)
    }
    
    func fadeMainLaser() {
        let laser = Sprite(imageNamed: "laser", x: size.width/2, y: size.height/2, scale: 2.3).addTo(self)
        laser.sprite.runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.fadeAlphaBy(-0.75, duration: 1.0),
                SKAction.fadeAlphaBy(0.75, duration: 1.0),
                ])
            ))
    }
    
    func backAndForth() {
        let lasermove = Sprite(imageNamed: "lasermove", x: 0, y: size.height/2).addTo(self)
        lasermove.sprite.runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.moveTo(CGPoint(x: size.width, y: size.height/2), duration: 2),
                SKAction.moveTo(CGPoint(x: 0, y: size.height/2), duration: 2),
                ])
            ))
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        followFinger(touches)
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        followFinger(touches)
    }
    
    func followFinger(touches: NSSet!) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            rocket.sprite.position = location
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        if (!isGameOver) {
            spawnAliens(true)
            spawnAliens(false)
            alienLogic()
            spawnPowerup()
            hitPowerup()
        }
    }
    
    func spawnAliens(startAtTop: Bool) {
        if Int(arc4random_uniform(1000)) < alienSpawnRate {
            let randomX = randomInRange(10, hi: Int(size.width))
            var startY = startAtTop.boolValue ? size.height : 0
            let alien = Alien(x: CGFloat(randomX), y: startY, startAtTop: startAtTop).addTo(self)
            aliens.addObject(alien)
        }
    }
    
    func spawnPowerup() {
        if Int(arc4random_uniform(1000)) < 1 {
            var x = CGFloat(random() % Int(size.width))
            var y = CGFloat(random() % Int(size.height))
            var powerup = Powerup(x: x, y: y).addTo(self)
            powerups.addObject(powerup)
            powerup.sprite.runAction(
                SKAction.sequence([
                    SKAction.fadeAlphaBy(-0.75, duration: 2.0),
                    SKAction.fadeAlphaBy(0.75, duration: 2.0),
                    SKAction.fadeAlphaBy(-0.75, duration: 2.0),
                    SKAction.removeFromParent()
                ])
            )
        }
    }
    
    func randomInRange(lo: Int, hi : Int) -> Int {
        return lo + Int(arc4random_uniform(UInt32(hi - lo + 1)))
    }
    
    func gameOver() {
        isGameOver = true
        let gameOverScene = GameOverScene(size: size, score: score)
        gameOverScene.scaleMode = scaleMode
        let reveal = SKTransition.crossFadeWithDuration(0.5)
        view?.presentScene(gameOverScene, transition: reveal)
    }
    
    func alienLogic() {
        for alien in aliens {
            let alien = alien as Alien
            if CGRectIntersectsRect(CGRectInset(alien.sprite.frame, 20, 20), self.rocket.sprite.frame) {
                rocket.sprite.removeFromParent()
                gameOver()
            }
            let y = alien.sprite.position.y
            //disabled by laser
            if !alien.isDisabled() {
                let middle = size.height/2
                if ((!alien.startAtTop.boolValue && y > middle) || (alien.startAtTop.boolValue && y < middle)) {
                    alien.setDisabled()
                    score += 5
                    scoreboard.text = "Score: " + String(score)
                }
            }
            alien.moveTo(rocket.sprite.position.x, y: rocket.sprite.position.y)
            if (y < 0 || y > size.height) {
                alien.sprite.removeFromParent()
                aliens.removeObject(alien)
            }
        }
    }
    
    func hitPowerup() {
        for powerup in powerups {
            let powerup = powerup as Powerup
            if CGRectIntersectsRect(CGRectInset(powerup.sprite.frame, 5, 5), self.rocket.sprite.frame) {
                powerup.boom()
                //powerup.sprite.removeFromParent()
            }
        }
    }
}
