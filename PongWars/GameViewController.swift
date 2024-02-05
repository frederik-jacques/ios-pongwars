//
//  GameViewController.swift
//  PongWars
//
//  Created by Frederik Jacques on 04/02/2024.
//

import UIKit
import SpriteKit
import GameplayKit

final class GameViewController: UIViewController {

    // MARK: - Properties

    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = GameScene(size: view.bounds.size)
        scene.scaleMode = .aspectFill
        scene.backgroundColor = .gameBackground
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)

        if let skView = view as? SKView {
            // Preload sound
            SKAction.playSoundFileNamed("hit.aac", waitForCompletion: false)
            
            //skView.showsPhysics = true
            //skView.showsFPS = true
            //skView.showsNodeCount = true
            skView.presentScene(scene)
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Public methods

    // MARK: - Private methods
    
}
