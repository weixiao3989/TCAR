//
//  AppDelegate.swift
//  TCAR
//
//  Created by Chris on 2017/7/9.
//  Copyright © 2017年 MUST. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import UserNotifications
import IQKeyboardManagerSwift
import GoogleMaps
import GooglePlaces
import Alamofire
import AlamofireImage
import SwiftyJSON
import Fabric
import Crashlytics
import JSSAlertView
import PCLBlurEffectAlert


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var googleAPIKey = "AIzaSyBUFJ2_nLA0cAaQb31nCYFL0-Z3-Aybi_c"
    var locationManager = CLLocationManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        Fabric.with([Crashlytics.self])
        IQKeyboardManager.sharedManager().enable = true
        GMSServices.provideAPIKey(googleAPIKey)
        GMSPlacesClient.provideAPIKey(googleAPIKey)
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringSignificantLocationChanges()
        
        // iOS 10 support
        if #available(iOS 10, *) {
            UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
            
            let notificationTypes: UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound]
            let pushNotificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
            
            application.registerUserNotificationSettings(pushNotificationSettings)
            application.registerForRemoteNotifications()
        }
        // iOS 9 support
        else if #available(iOS 9, *){
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
        
        // App is Inactive Mode status receive notification. For All iOS version.
        if launchOptions != nil {
            let option = launchOptions![UIApplicationLaunchOptionsKey.remoteNotification] as? NSDictionary
            if option != nil {
                
                if let aps = option!["aps"] as? NSDictionary {
                    if let alert = aps["alert"] as? NSDictionary {
                        if let title = alert["title"] as? NSString {
                            if title.contains("司機接單") {
                                UserDefaults.standard.removeObject(forKey: "Enter_Type")
                                UserDefaults.standard.set(1, forKey: "Enter_Type")
                                UserDefaults.standard.synchronize()
                            }
                        }
                    } else if let alert = aps["alert"] as? NSString {
                        print("alert is : \(alert)")
                    }
                }
                
            }
        }
        
        
        // TODO: User information returned in crashing.
        self.logUser()

        return true
    }
    
    // User information returned in crashing.
    func logUser() {
        let deviceToken = UserDefaults.standard.string(forKey: "deviceToken")
        Crashlytics.sharedInstance().setUserEmail("weixiao3989@gmail.com")
        Crashlytics.sharedInstance().setUserIdentifier(deviceToken)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        
        // Remove All RealTimeCallCar Back to root page switch and Enter Type index.
        UserDefaults.standard.removeObject(forKey: "Enter_Type")
        UserDefaults.standard.removeObject(forKey: "PRTCVC_root_switch")
        UserDefaults.standard.removeObject(forKey: "DRTCVC_root_switch")
        UserDefaults.standard.synchronize()
        self.saveContext()
    }
    
    
    /*
     * // MARK: - APNs Related call parameters.
     */

    // Called when APNs has assigned the device a unique token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Convert token to string
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})

        // Print it to console
        print("APNs device token: \(deviceTokenString)")

        // Write device Token to the local data, This is has DeviceToken.
        UserDefaults.standard.removeObject(forKey: "deviceToken")
        UserDefaults.standard.set(deviceTokenString, forKey: "deviceToken")
        UserDefaults.standard.synchronize()
    }

    // Called when APNs failed to register the device for push notifications
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // Print the error to console (you should alert the user that registration failed)
        print("APNs registration failed: \(error)")
        // Write device Token to the local data, This is not get DeviceToken.
        UserDefaults.standard.removeObject(forKey: "deviceToken")
        UserDefaults.standard.set("NothasDeviceToken", forKey: "deviceToken")
        UserDefaults.standard.synchronize()
    }
    
    // Push notification received
    func application(_ application: UIApplication, didReceiveRemoteNotification data: [AnyHashable : Any]) {
        
        // iOS 9.
        if #available(iOS 9, *) {
            // App is Foreground Mode status receive notification.
            if application.applicationState == UIApplicationState.active {
                
                print("Push Notification received is in Foreground Mode - iOS 9, data is : \(data)")
                
                if let aps = data["aps"] as? NSDictionary {
                    if let alert = aps["alert"] as? NSDictionary {
                        if let title = alert["title"] as? NSString {
                            if title.contains("司機接單") {
                                
                                UserDefaults.standard.removeObject(forKey: "Enter_Type")
                                UserDefaults.standard.set(1, forKey: "Enter_Type")
                                UserDefaults.standard.synchronize()
                                
                                if let driver_id = aps["driver_id"] as? Int {
                                    print("dirver_id is : \(String(driver_id))")
                                    
                                    UserDefaults.standard.removeObject(forKey: "RTCDriver_id")
                                    UserDefaults.standard.set(driver_id, forKey: "RTCDriver_id")
                                    UserDefaults.standard.synchronize()
                                    
                                    let stroyboard = UIStoryboard(name: "Main", bundle: nil);
                                    let vc = stroyboard.instantiateViewController(withIdentifier: "Passenger_RTCS_VC")
                                    let appDelegate = UIApplication.shared.delegate as! AppDelegate;
                                    appDelegate.window?.rootViewController = vc
                                }
                                
                            }
                        }
                    } else if let alert = aps["alert"] as? NSString {
                        print("alert is : \(alert)")
                    }
                }
                
            } else if application.applicationState == UIApplicationState.background {
                // App is Background Mode status receive notification.
                
                print("Push Notification received is in Background Mode - iOS 9, payload is : \(data)")
                
                if let aps = data["aps"] as? NSDictionary {
                    if let alert = aps["alert"] as? NSDictionary {
                        if let title = alert["title"] as? NSString {
                            if title.contains("司機接單") {
                                UserDefaults.standard.removeObject(forKey: "Enter_Type")
                                UserDefaults.standard.set(1, forKey: "Enter_Type")
                                UserDefaults.standard.synchronize()
                            }
                        }
                    } else if let alert = aps["alert"] as? NSString {
                        print("alert is : \(alert)")
                    }
                }
                
            }
        }
        
    }
    
    //- Foreground & Background Mode (iOS 10+)
    @available(iOS 10, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if UIApplication.shared.applicationState == UIApplicationState.active {
            
            print("Push Notification received is in Foreground Mode - iOS 10+, payload is : \(response)")
            
            
        } else if UIApplication.shared.applicationState == UIApplicationState.background {
            
            let userAction = response.actionIdentifier
            if userAction == UNNotificationDefaultActionIdentifier {
                print("User opened the notification.")
                print("Push Notification received is in Background Mode - iOS 10+, payload is : \(response)")
                
            }
            if userAction == UNNotificationDismissActionIdentifier {
                print("User dismissed the notification.")
                print("Push Notification received is in Background Mode - iOS 10+, payload is : \(response)")
            }
        }
        completionHandler()
    }
    
    
    /*
     * // MARK: - Core Data stack
     */

    @available(iOS 10.0, *)
    @objc lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "TCAR")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // iOS 9 and below
    lazy var applicationDocumentsDirectory: URL = {
        
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "coreDataTestForPreOS", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    @objc func saveContext () {
        if #available(iOS 10.0, *) {
            let context = persistentContainer.viewContext
            
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        } else {
            // iOS 9.0 and below - however you were previously handling it
            if managedObjectContext.hasChanges {
                do {
                    try managedObjectContext.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                    abort()
                }
            }
        }
        
    }

}

