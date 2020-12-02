//
//  SceneDelegate.swift
//  Photos
//
//  Created by Владимир Кваша on 26.11.2020.
//

import UIKit

// MARK: - SceneDelegate

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    //MARK: - Properties

    var window: UIWindow?
    
    // MARK: - Functions

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
    }
}

