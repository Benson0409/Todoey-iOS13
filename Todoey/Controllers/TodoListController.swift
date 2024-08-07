//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class TodoListController: UITableViewController {
    
    var itemArray = [Item]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //selectCategory 是 Category 類型的可選變數
    //當它被設定時會觸發 didSet 方法，從而調用 LoadItemData() 加載對應的項目資料。
    var selectCategory : Category?{
        didSet{
            //載入Data資料
            LoadItemData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        // Do any additional setup after loading the view.
    }
    
    //MARK: - TableView Datasource Method
    //tableview 功能
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        //選擇列表會出現樣式 再點選一次就會取消
        cell.accessoryType = item.done ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //刪除Item
        context.delete(itemArray[indexPath.row])
        itemArray.remove(at: indexPath.row)
        
        //標記勾選
//        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        SaveItemData()
        
        //讓他會有一個動畫不會一直是灰色
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    //MARK: - IBAction
    //添加新item功能
    @IBAction func AddItemBtn(_ sender: UIBarButtonItem) {
        
        //告了一個變數 textField，用來保存用戶在警告框中輸入的文字
        var textField = UITextField()
        
        //建立了一個標題為 “Add New Item” 的警告框，警告框的風格設為 .alert。
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        
        //這裡建立了一個標題為 “Add Item" 的動作，當用戶按下這個動作時會執行閉包中的程式碼。
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
           
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            
            newItem.parentCategory = self.selectCategory
            
            self.itemArray.append(newItem)
            self.SaveItemData()
            
        }
        
        //使用 alert.addTextField 方法在警告框中添加一個文字輸入框
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Creat a Item Name"
            textField = alertTextField
        }
        
        //將先前建立的 action 動作添加到警告框中。
        alert.addAction(action)
        
        //present 方法顯示警告框，並設定動畫效果
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - CoreData Function
    //儲存coredata功能
    func SaveItemData(){
        
        do{
           try context.save()
        }
        catch{
            print("Error saving context \(error)")
        }
        
        //更新ＵＩ
        self.tableView.reloadData()
    }
    
    func LoadItemData(with request:NSFetchRequest<Item> = Item.fetchRequest(),predicate:NSPredicate? = nil){
        
        ////使用 NSPredicate 過濾出屬於 selectCategory 的項目。
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectCategory!.name!)
        
        
        //如果有額外的 predicate（例如搜尋條件），則使用 NSCompoundPredicate 合併條件。
        if let additionPredicate = predicate{
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [additionPredicate,categoryPredicate])
        }
        else{
            request.predicate = categoryPredicate
        }
        
        
        do{
            itemArray = try context.fetch(request)
        }
        catch{
            print("Error fetching data from context \(error)")
        }
        tableView.reloadData()
    }
    
}


//MARK: - UISearchBarDelegate
//searchbar 功能
extension TodoListController:UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request:NSFetchRequest<Item> = Item.fetchRequest()
        
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@",searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        LoadItemData(with: request,predicate: predicate)
        
    }
    
    //收尋列文字判斷
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            
            LoadItemData()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}


