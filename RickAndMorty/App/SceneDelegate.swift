//
//  SceneDelegate.swift
//  RickAndMorty
//
//  Created by Варвара Уткина on 02.12.2024.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.makeKeyAndVisible()
        window?.rootViewController = UINavigationController(rootViewController: CharactersViewController())
        
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }


}

