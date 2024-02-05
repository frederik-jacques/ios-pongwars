//
//  BallNode.swift
//  PongWars
//
//  Created by Frederik Jacques on 04/02/2024.
//

import SpriteKit

final class BallNode: SKShapeNode {
    
    // MARK: - Properties
    private let side: Side
    private let radius: CGFloat
    
    // MARK: - Lifecycle methods
    init(side: Side, radius: CGFloat, initialPosition: CGPoint) {
        self.side = side
        self.radius = radius
            
        super.init()
        
        let path = CGMutablePath()
        path.addArc(center: CGPoint.zero,
                    radius: radius,
                    startAngle: 0,
                    endAngle: CGFloat.pi * 2,
                    clockwise: true)
        
        self.path = path
        
        setupView(initialPosition: initialPosition, radius: radius)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("no-op") }
    
    // MARK: - Public methods
    func activate() {
        lineWidth = 2
        strokeColor = .white        
    }
    
    func deactivate() {
        lineWidth = 1
        strokeColor = side.ballColor
    }
    
    // MARK: - Private methods
    private func setupView(initialPosition: CGPoint, radius: CGFloat) {
        position = initialPosition
        lineWidth = 1
        fillColor = side.ballColor
        strokeColor = side.ballColor
        
        setupPhysicsBody()        
    }
    
    private func setupPhysicsBody() {
        physicsBody = SKPhysicsBody(circleOfRadius: radius)
        physicsBody?.friction = 0
        physicsBody?.restitution = 1
        physicsBody?.linearDamping = 0.0
        physicsBody?.angularDamping = 0.0
                
        physicsBody?.affectedByGravity = false
        physicsBody?.isDynamic = true
        
        switch side {
        case .light:
            physicsBody?.categoryBitMask = PhysicsCategory.ball1
            physicsBody?.collisionBitMask = PhysicsCategory.tile2
            physicsBody?.contactTestBitMask = PhysicsCategory.tile2
            
        case .dark:
            physicsBody?.categoryBitMask = PhysicsCategory.ball2
            physicsBody?.collisionBitMask = PhysicsCategory.tile1
            physicsBody?.contactTestBitMask = PhysicsCategory.tile1
        }
    }
    
}

private extension Side {
    
    var ballColor: UIColor {
        switch self {
        case .light : return .darkTile
        case .dark  : return .lightTile
        }
    }
    
}
