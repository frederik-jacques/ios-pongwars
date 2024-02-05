//
//  GameScene.swift
//  PongWars
//
//  Created by Frederik Jacques on 04/02/2024.
//

import SpriteKit
import GameplayKit

final class GameScene: SKScene {
    
    // MARK: - Properties
    private let labelFontName = "Futura-CondensedMedium"
    
    private let fieldNode = SKNode()
    private var lightBall: BallNode!
    private var darkBall: BallNode!
    
    private var ballInControl: BallNode?
    
    private var lightLabelNode: SKLabelNode!
    private var darkLabelNode: SKLabelNode!
    
    private var tileNodes: [FieldTileSpriteNode] = []
    
    // MARK: - Lifecycle methods
    override func sceneDidLoad() {
        setupWorld()
        setupGameField()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: { [weak self] in
            self?.start()
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        
        // Check if we have touched a ball
        let touchedBall = nodes(at: location).compactMap({ $0 as? BallNode }).first
        
        if let ballInControl {
            // If we are currently controlling a ball
            // and the ball is the same as the ball we just touched, deactivate it.
            if ballInControl == touchedBall {
                ballInControl.deactivate()
                self.ballInControl = nil
            }
            else {
                // Otherwise we'll give it a little push.
                applyForce(ball: ballInControl, at: location)
            }
        }
        // If we have no ball in control, and we have touched one, activate it so we can apply so force to it
        else if let touchedBall {
            ballInControl = touchedBall
            ballInControl?.activate()
        }
    }
    
    // MARK: - Public methods
    
    // MARK: - Private methods
    private func start() {
        lightBall.physicsBody?.applyImpulse(CGVector(dx: 8, dy: 2))
        darkBall.physicsBody?.applyImpulse(CGVector(dx: -4, dy: -3))
    }
    
    private func setupWorld() {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = .zero
    }
    
    private func setupGameField() {
        let tileSize = CGSize(width: 44.0, height: 44.0)
        let fieldSize = calculateFieldSize(tileSize: tileSize)
        
        let gameFieldRect = CGRect(x: -fieldSize.width * 0.5, y: -fieldSize.height * 0.5, width: fieldSize.width, height: fieldSize.height)
        
        fieldNode.physicsBody = SKPhysicsBody(edgeLoopFrom: gameFieldRect)
        fieldNode.physicsBody?.friction = 0
        fieldNode.physicsBody?.restitution = 1
        fieldNode.physicsBody?.linearDamping = 0.0
        fieldNode.physicsBody?.angularDamping = 0.0
        addChild(fieldNode)
        
        let leftFieldFrame = CGRect(x: gameFieldRect.minX, y: gameFieldRect.minY, width: gameFieldRect.width * 0.5, height: gameFieldRect.height)
        let rightFieldFrame = CGRect(x: gameFieldRect.midX, y: gameFieldRect.minY, width: gameFieldRect.width * 0.5, height: gameFieldRect.height)
        
        buildField(within: leftFieldFrame, tileSize: tileSize, side: .light)
        
        lightBall = BallNode(side: .light, radius: 12, initialPosition: CGPoint(x: leftFieldFrame.minX, y: leftFieldFrame.midY))
        addChild(lightBall)
        
        buildField(within: rightFieldFrame, tileSize: tileSize, side: .dark)
        
        darkBall = BallNode(side: .dark, radius: 12, initialPosition: CGPoint(x: rightFieldFrame.maxX, y: rightFieldFrame.midY))
        addChild(darkBall)
        
        lightLabelNode = SKLabelNode(text: "Light side")
        lightLabelNode.fontName = labelFontName
        lightLabelNode.fontSize = 16.0
        lightLabelNode.horizontalAlignmentMode = .left
        lightLabelNode.position = CGPoint(x: leftFieldFrame.minX, y: leftFieldFrame.maxY + 6.0)
        addChild(lightLabelNode)
        
        darkLabelNode = SKLabelNode(text: "Dark side")
        darkLabelNode.fontName = labelFontName
        darkLabelNode.fontSize = 16.0
        darkLabelNode.horizontalAlignmentMode = .right
        darkLabelNode.position = CGPoint(x: rightFieldFrame.maxX, y: leftFieldFrame.maxY + 6.0)
        addChild(darkLabelNode)
        
        updateScore()
    }
    
    private func buildField(within frame: CGRect, tileSize: CGSize, side: Side) {
        // Calculate the number of possible rows based on the available width
        let numberOfColumns = Int(frame.width / tileSize.width)
        
        // Calculate the number of possible columns based on the available height
        let numberOfRows = Int(frame.height / tileSize.height)
        
        // Calculate the inital position of the tile, keep in mind that the anchorpoint of the tiles
        // is in the center, so we need to take that into account.
        let initialTilePosition = calculateInitialTilePosition(side: side, in: frame, tileSize: tileSize)
        
        var xPosition: CGFloat = initialTilePosition.x
        var yPosition: CGFloat = initialTilePosition.y
        
        // Create all the columns
        for columnIndex in 0..<numberOfColumns {
            
            // Create all the rows
            for rowIndex in 0..<numberOfRows {
                // Calculate the ratio based on the position of the column
                // The further out of the middle the lower the ratio will be (between 0.1 & 1)
                // This is used to create the visual fade of the tiles.
                let ratio: CGFloat = CGFloat(columnIndex) / CGFloat(numberOfColumns)
                let colorAlpha = (1 - ratio).clamped(minimum: 0.2, maximum: 1.0)
                
                // Create the tile and position it
                let fieldTileSprite = FieldTileSpriteNode(side: side, column: columnIndex, row: rowIndex, size: tileSize, colorAlpha: colorAlpha)
                fieldTileSprite.position = CGPoint(x: xPosition, y: yPosition)
                fieldNode.addChild(fieldTileSprite)
                
                yPosition = nextFieldTileYPosition(currentYPosition: yPosition, tileHeight: tileSize.height)
                
                tileNodes.append(fieldTileSprite)
            }
            
            // Calculate the next x position for a tile, when one column has been fully constructed.
            xPosition = nextTileXPosition(side: side, currentXPosition: xPosition, tileWidth: tileSize.width)
            
            // Reset the y position to be back at the top
            yPosition = initialTileYPosition(frame: frame, tileHeight: tileSize.height)
        }
    }
    
    private func applyForce(ball: BallNode, at location: CGPoint) {
        // Calculate the vector from the touch to the ball
        let dx = ball.position.x - location.x
        let dy = ball.position.y - location.y
        
        // Create a vector for the force
        let vector = CGVector(dx: dx, dy: dy)
        
        // Normalize the vector
        let normalizedVector = vector.normalize()
        
        // Apply the force to the ball
        let forceMagnitude: CGFloat = 200
        let forceVector = CGVector(dx: normalizedVector.dx * forceMagnitude, dy: normalizedVector.dy * forceMagnitude)
        
        ball.physicsBody?.applyForce(forceVector)
    }
    
    private func updateScore() {
        let numberOfLightTiles = tileNodes.filter({ $0.side == .light }).count
        let numberOfDarkTiles = tileNodes.filter({ $0.side == .dark }).count
        
        lightLabelNode.text = "Light side: \(numberOfLightTiles)"
        darkLabelNode.text = "Dark side: \(numberOfDarkTiles)"
    }
    
}

// MARK: - Gamefield + tile position calculations
extension GameScene {
    
    private func calculateFieldSize(tileSize: CGSize) -> CGSize {
        // Get the size of the entire scene
        let sceneSize = size
        
        // Take 85% of it
        let width85Percent = sceneSize.width * 0.85
        let height85Percent = sceneSize.height * 0.85
        
        // Take the closest value to have a field that will fill perfectly based on the tileSize
        let numberOfColumns = floor(width85Percent / tileSize.width)
        let numberOfRows = floor(height85Percent / tileSize.height)
        
        return CGSize(width: numberOfColumns * tileSize.width, height: numberOfRows * tileSize.height)
    }
    
    private func calculateInitialTilePosition(side: Side, in frame: CGRect, tileSize: CGSize) -> CGPoint {
        // The tiles start at the top of the gamefield
        let yPosition = initialTileYPosition(frame: frame, tileHeight: tileSize.height)
        
        switch side {
        case .light: // The left side of the playing field
            return CGPoint(x:  -tileSize.width * 0.5, y: yPosition)
            
        case .dark: // The right side of the playing field
            return CGPoint(x:  tileSize.width * 0.5, y: yPosition)
        }
    }
    
    private func initialTileYPosition(frame: CGRect, tileHeight: CGFloat) -> CGFloat {
        return (frame.size.height - tileHeight) * 0.5
    }
    
    private func nextFieldTileYPosition(currentYPosition: CGFloat, tileHeight: CGFloat) -> CGFloat {
        return currentYPosition - tileHeight
    }
    
    private func nextTileXPosition(side: Side, currentXPosition: CGFloat, tileWidth: CGFloat) -> CGFloat {
        switch side {
        case .light:
            return currentXPosition - tileWidth
        case .dark:
            return currentXPosition + tileWidth
        }
    }
    
}

// MARK: - SKPhysicsContactDelegate
extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let tile = contact.bodyA.node as? FieldTileSpriteNode ?? contact.bodyB.node as? FieldTileSpriteNode else { return }
        
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        let ball1Collision = PhysicsCategory.ball1 | PhysicsCategory.tile2
        let ball2Collision = PhysicsCategory.ball2 | PhysicsCategory.tile1
        
        if collision == ball1Collision || collision == ball2Collision {
            tile.switchSide()
            updateScore()
        }
    }
    
}
