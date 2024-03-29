//
//  SceneDelegate.swift
//  Mafia
//
//  Created by Булат Мусин on 19.10.2022.
//

import UIKit

protocol FirstPageCoordinable {
    func openHomeView(with user: User)
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate, FirstPageCoordinable {

    var window: UIWindow?
    
    func openHomeView(with user: User) {
        let coorinator = HomeCoordinator.make(user: user, client: URLSession.shared)
        setRootViewController(coorinator)
    }

    func setRootViewController(_ vc: UIViewController) {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.window!.rootViewController?.view.alpha = 0
        }) { _ in
            vc.view.alpha = 0
            self.window!.rootViewController = vc
            UIView.animate(withDuration: 1, delay: 0, options: .curveEaseIn) {
                self.window!.rootViewController?.view.alpha = 1
            }
        }
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(windowScene: windowScene)
        let vc: UIViewController
        if let savedUser = try? MafiaUserDefaults.standard.object(forKey: "User", type: User.self) {
            vc = HomeCoordinator.make(user: savedUser, client: URLSession.shared)
        } else {
            let loginVC = LoginViewController.make(client: URLSession.shared, defaults: MafiaUserDefaults.standard, delegate: self)
            vc = UINavigationController(rootViewController: loginVC)
        }
        
        self.window!.rootViewController = vc
        self.window!.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

