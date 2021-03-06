//
//  AppDelegate.swift
//  Organization
//
//  Created by Menlo on 18/05/18.
//  Copyright © 2018 self. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?


  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
    populateData()
    
    return true
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
    self.saveContext()
  }

  // MARK: - Core Data stack

  lazy var persistentContainer: NSPersistentContainer = {
      /*
       The persistent container for the application. This implementation
       creates and returns a container, having loaded the store for the
       application to it. This property is optional since there are legitimate
       error conditions that could cause the creation of the store to fail.
      */
      let container = NSPersistentContainer(name: "Organization")
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
    
      container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

      return container
  }()

  // MARK: - Core Data Saving support

  func saveContext () {
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
  }
  
  private func populateData() {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Employee")
    fetchRequest.predicate = NSPredicate(
      format: "empID != nil")
    
    let managedContext = persistentContainer.viewContext
    /****** Check if any data already populated ******/
    var count = 0
    do {
      count = try managedContext.count(for: fetchRequest);
    } catch { print("No data present.") }
    
    // Commentted following for check futureproof
    // if count > 0 { return }
    
    /****** Access JSON file and parse it ******/
    guard let path = Bundle.main.path(forResource: "SampleData", ofType: "json") else { return }
    let url = URL(fileURLWithPath: path)
    
    guard let dataArray = try? Data(contentsOf: url, options: .mappedIfSafe),
      let jsonArray = try? JSONSerialization.jsonObject(with: dataArray, options: .mutableContainers) else {
        return
    }
    
    if let empArray = jsonArray as? [Dictionary<String,AnyObject>] {
      for emp in empArray {
        
        guard let type = emp["type"] as? String,
          let entity = NSEntityDescription.entity(forEntityName: type, in: managedContext) else {
            continue
        }
        
        let newEmp = NSManagedObject(entity: entity, insertInto: managedContext)
        
        for k in entity.attributesByName.keys {
          //Assume all keys will be present in the JSON
          newEmp.setValue(emp[k], forKey: k)
        }
      }
    }
    
    do {
      try managedContext.save()
    } catch let e {
      print("Failed to save managed Context :: ", e)
    }
    
  }

}

