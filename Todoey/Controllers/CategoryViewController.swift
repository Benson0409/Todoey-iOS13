//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by Benson on 2024/8/6.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {

    var categoryItem = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

       LoadItemData()
    }

    //MARK: - TableView Datasource Method
    //tableview 功能
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryItem.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        let item = categoryItem[indexPath.row]
        
        cell.textLabel?.text = item.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "GoToItem", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListController
        if let indexPath = tableView.indexPathForSelectedRow{
            //將選定的類別傳遞給目標視圖控制器（destinationVC）
            destinationVC.selectCategory = categoryItem[indexPath.row]
        }
    }
    
    //MARK: - IBAction
    @IBAction func AddItemBtn(_ sender: UIBarButtonItem) {
        
        //告了一個變數 textField，用來保存用戶在警告框中輸入的文字
        var textField = UITextField()
        
        //建立了一個標題為 “Add New Item” 的警告框，警告框的風格設為 .alert。
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        //這裡建立了一個標題為 “Add Item" 的動作，當用戶按下這個動作時會執行閉包中的程式碼。
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
           
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text!
            
            self.categoryItem.append(newCategory)
            self.SaveItemData()
            
        }
        
        //使用 alert.addTextField 方法在警告框中添加一個文字輸入框
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Creat a new category"
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
        tableView.reloadData()
    }
    
    func LoadItemData(with request:NSFetchRequest<Category> = Category.fetchRequest()){
//        let request:NSFetchRequest<Item> = Item.fetchRequest()
        do{
            categoryItem = try context.fetch(request)
        }
        catch{
            print("Error fetching data from context \(error)")
        }
        tableView.reloadData()
    }
}
