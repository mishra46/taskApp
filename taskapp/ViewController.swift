//
//  ViewController.swift
//  taskapp
//
//  Created by 堅田史朗 on 2016/09/19.
//  Copyright © 2016年 堅田史朗. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController, UITableViewDelegate, UISearchBarDelegate, UITableViewDataSource{

    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    let realm = try! Realm()
    var taskArray = try! Realm().objects(Task).sorted("date", ascending: false)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // データの数（＝セルの数）を返すメソッド
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    // 各セルの内容を返すメソッド
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
       
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
            
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
            
        let dateString:String = formatter.stringFromDate(task.date)
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    
    
    //検索ボタン押下時の呼び出しメソッド
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.endEditing(true)
        
            taskArray = try! Realm().objects(Task).filter("category BEGINSWITH[c] %@", searchBar.text!)

        tableView.reloadData()
    }
    
    // 各セルを選択した時に実行されるメソッド
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            performSegueWithIdentifier("cellSegue",sender: nil) // ←追加する
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath)-> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            // ローカル通知をキャンセルする
            let task = taskArray[indexPath.row]
            
            for notification in UIApplication.sharedApplication().scheduledLocalNotifications! {
                if notification.userInfo!["id"] as! Int == task.id {
                    UIApplication.sharedApplication().cancelLocalNotification(notification)
                    break
                }
            }
            
            // データベースから削除
            try! realm.write {
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            }
        }
    }
    
    
    

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        let inputViewController:InputViewController = segue.destinationViewController as! InputViewController
        
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            let task = Task()
            task.date = NSDate()
            
            if taskArray.count != 0 {
                task.id = taskArray.max("id")! + 1
            }
            inputViewController.task = task
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

}

