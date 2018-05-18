//
//  ViewController.swift
//  Organization
//
//  Created by Menlo on 18/05/18.
//  Copyright © 2018 self. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

  //MARK:- IBOutlets
  @IBOutlet weak var tableView: UITableView!
  
  //MARK:- Public Properties
  
  //MARK:- Private Properties
  fileprivate let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
  fileprivate var sections : [String]? = nil
  fileprivate var tableData: [String: [Dictionary<String, Any>]]? = nil
  
  //MARK:- Lifecycle Methods
  override func viewDidLoad() {
    super.viewDidLoad()
   
    DispatchQueue(label: "fetch_data").async { [weak self]() in
      guard let (tData, sData) = self?.getTableData() else { return }
      self?.tableData = tData
      self?.sections = sData
      
      DispatchQueue.main.async {
        self?.tableView.reloadData()
      }
    }
    
  }
  
  //MARK:- Utility Methods
  fileprivate func tryToInsertDuplicate() {
    
    let emp = [
      "empID": "emp5",
      "name": "Methews Somani",
      "salary": 55000,
      "type": "Manager",
      "department": "Software Testing"
      ] as [String : Any]
    
    guard let entity = NSEntityDescription.entity(forEntityName: "Manager", in: managedContext) else {
      return
    }
    
    let newEmp = NSManagedObject(entity: entity, insertInto: managedContext)
    
    for k in entity.attributesByName.keys {
      //Assume all keys will be present in the JSON
      newEmp.setValue(emp[k], forKey: k)
    }
    
    do {
      try managedContext.save()
    } catch let e {
      print("Failed to save managed Context :: ", e)
    }
    
  }
  
  fileprivate func getTableData() ->  ([String: [Dictionary<String, Any>]], [String]) {
    
    var data = [String: [Dictionary<String, Any>]]()
    var sections = [String]()
    let type = "type"
    
    let typeRequest = NSFetchRequest<NSDictionary>(entityName: "Employee")
    typeRequest.resultType = .dictionaryResultType
    typeRequest.propertiesToGroupBy = [type]
    typeRequest.propertiesToFetch = [type]
    typeRequest.sortDescriptors = [NSSortDescriptor(key: type, ascending: true)]
    typeRequest.returnsObjectsAsFaults = false
    
    let empRequest = NSFetchRequest<NSDictionary>(entityName: "Employee")
    empRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
    empRequest.resultType = .dictionaryResultType

    do {
      let result = try managedContext.fetch(typeRequest)
      for r in result  {
        let empType = r[type] as! String
        let predicate = NSPredicate(format: "type == %@", empType)
        empRequest.predicate = predicate
        
        let empResult = try managedContext.fetch(empRequest)
        sections.append(empType)
        data[empType] = empResult as? [Dictionary<String, Any>]
      }
      
    } catch let e {
      print("Failed to execute Fetch :: ", e)
    }
    
    return (data, sections)
  }
  
  fileprivate func getCellData(for indexPath: IndexPath) -> Dictionary<String, Any> {
    if let count = sections?.count,
      count > indexPath.section,
      let empType = sections?[indexPath.section],
      let employees = tableData?[empType],
      let rCount = tableData?[empType]?.count,
      rCount > indexPath.row {
      return employees[indexPath.row]
    } else { return [:] }
  }
}

//MARK:- UITableViewDataSource
extension ViewController : UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    if let count = sections?.count {
      return count
    } else {
      return 0
    }
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if let count = sections?.count,
      count > section,
      let empType = sections?[section] {
      
      return empType
    } else { return nil }
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let count = sections?.count,
      count > section,
      let empType = sections?[section],
      let rCount = tableData?[empType]?.count {
      return rCount
    } else { return 0 }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let dict = getCellData(for: indexPath)
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    
    cell.textLabel?.text = dict["name"] as? String
    cell.detailTextLabel?.text = dict["empID"] as? String
    
    return cell
  }
}



