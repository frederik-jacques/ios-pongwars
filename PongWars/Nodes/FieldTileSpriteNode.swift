//
//  FieldTileSpriteNode.swift
//  PongWars
//
//  Created by Frederik Jacques on 04/02/2024.
//

import SpriteKit

final class FieldTileSpriteNode: SKShapeNode {
    
    // MARK: - Properties
    private(set) var side: Side {
        didSet {
            sideDidChange()
        }
    }
    private let column: Int
    private let row: Int
    private let colorAlpha: CGFloat
    
    // MARK: - Lifecycle methods
    init(side: Side, column: Int, row: Int, size: CGSize, colorAlpha: CGFloat) {
        self.side = side
        self.column = column
        self.row = row
        self.colorAlpha = colorAlpha
        
        super.init()
        
        let origin = CGPoint(x: -size.width / 2, y: -size.height / 2)
        self.path = CGPath(rect: CGRect(origin: origin, size: size), transform: nil)
        
        setupPhysicsBody()
        updatePhysicBody()
        
        fillColor = side.tileColor.withAlphaComponent(colorAlpha)
        strokeColor = side.tileColor.withAlphaComponent(colorAlpha)
        lineWidth = 1
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("no-op") }
    
    // MARK: - Public methods
    func switchSide() {
        switch side {
        case .light:
            self.side = .dark
            
        case .dark:
            self.side = .light
        }
    }
    
    // MARK: - Private methods
    private func setupPhysicsBody() {
        physicsBody = SKPhysicsBody(rectangleOf: frame.size)
        physicsBody?.restitution = 1
        physicsBody?.isDynamic = false
    }
    
    private func updatePhysicBody() {
        switch side {
        case .light:
            name = "Tile-Light-\(column)-\(row)"
            physicsBody?.categoryBitMask = PhysicsCategory.tile1
            
        case .dark:
            name = "Tile-Dark-\(column)-\(row)"
            physicsBody?.categoryBitMask = PhysicsCategory.tile2
        }
    }
    
    private func sideDidChange() {
        // Play sound
        let soundAction = SKAction.playSoundFileNamed("hit.aac", waitForCompletion: false)
        run(soundAction)
        
        // Update the physics body, so the tile category bitmask get's updated
        updatePhysicBody()
        
        // Add some explosion ... because we can.
        addExplosion()
        
        // Animate the tile color
        flipSide(newColor: side.tileColor, colorAlpha: colorAlpha)
    }
    
    private func flipSide(newColor: UIColor, colorAlpha: CGFloat) {
        // Scale down animation
        let scaleDown = SKAction.scale(to: 0.1, duration: 0.1)
        
        // Change color in the middle of the animation where it's scaled down completely
        let changeColor = SKAction.run {
            self.fillColor = newColor.withAlphaComponent(colorAlpha)
            self.strokeColor = newColor
        }
        
        // Scale back up animation
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
        
        // Create sequence to first scale down, change color, then scale back up
        let sequence = SKAction.sequence([scaleDown, changeColor, scaleUp])
        
        // Run the animation sequence on the node
        run(sequence)
    }
    
    private func createExplosion() -> SKEmitterNode {
        let explosion = SKEmitterNode()
        explosion.position = CGPoint(x: -frame.size.width / 2, y: -frame.size.height / 2)
        explosion.numParticlesToEmit = 100 // Number of particles
        explosion.particleLifetime = 1 // How long each particle lives
        explosion.particleBlendMode = .alpha
        explosion.particleBirthRate = 1000
        explosion.particleSize = CGSize(width: 5, height: 5) // Size of particles
        explosion.particleColor = UIColor.explosion
        explosion.emissionAngleRange = 360
        explosion.particleSpeed = 200
        explosion.particleSpeedRange = 50
        explosion.particleAlpha = 0.8
        explosion.particleAlphaRange = 0.2
        explosion.particleAlphaSpeed = -0.5
        explosion.particleScale = 0.5
        explosion.particleScaleRange = 0.25
        explosion.particleScaleSpeed = -0.5 // Particles shrink
        return explosion
    }
    
    private func addExplosion() {
        let explosion = createExplosion()
        addChild(explosion)
        
        // Remove the explosion effect after it's done
        let removeAfterDelay = SKAction.sequence([
            SKAction.wait(forDuration: 1), // Wait for the duration of the particle lifetime
            SKAction.removeFromParent()
        ])
        
        explosion.run(removeAfterDelay)
    }
    
}

private extension Side {
    
    var tileColor: UIColor {
        switch self {
        case .light : return .lightTile
        case .dark  : return .darkTile
        }
    }
    
}

