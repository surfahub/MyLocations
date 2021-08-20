//
//  SceneDelegate.swift
//  MyLocations
//
//  Created by Surfa on 06.08.2021.
//

import UIKit
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
   
        let tabController = window?.rootViewController as! UITabBarController
        if let tabViewControllers = tabController.viewControllers{
            
            let navController1 = tabViewControllers[0] as! UINavigationController
            let controller1 = navController1.viewControllers.first as! CurrentLocationViewController
            
            controller1.managedObjectContext = managedObjectContext
            
            let navController2 = tabViewControllers[1] as! UINavigationController
            let controller2 = navController2.viewControllers.first as! LocationsViewController
            
            controller2.managedObjectContext = managedObjectContext
            //let _ = controller2.view
            
            let navController3 = tabViewControllers[2] as! UINavigationController
            let controller3 = navController3.viewControllers.first as! MapViewController
            
            controller3.managedObjectContext = managedObjectContext

        }
        
        guard let _ = (scene as? UIWindowScene) else { return }
        listenForFatalCoreDataNotifications()
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

        // Save changes in the application's managed object context when the application transitions to the background.
        saveContext()
    }
    
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
       
        let container = NSPersistentContainer(name: "MyLocations")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
               
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    lazy var managedObjectContext = persistentContainer.viewContext
    
    func listenForFatalCoreDataNotifications(){
        NotificationCenter.default.addObserver(
            forName: dataSaveFailedNotification,
            object: nil,
            queue: OperationQueue.main){
            _ in
            let message = """
                There was a fatal error in the app and it cannot continue.

                Press OK to terminate the app. Sorry for the inconvenience.
                """
            let alert = UIAlertController(title: "Internal Error", message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default){
                _ in
                let exception = NSException(
                    name: NSExceptionName.internalInconsistencyException,
                    reason: "Fatal Core Data Error",
                    userInfo: nil)
                
                exception.raise()
            }
            alert.addAction(action)
            let tabController = self.window!.rootViewController!
            tabController.present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    
    
    

}

