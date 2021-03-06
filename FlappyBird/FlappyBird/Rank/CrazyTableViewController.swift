//
//  CrazyTableViewController.swift
//  FlappyBird
//
//  Created by 吴国权 on 2017/11/25.
//  Copyright © 2017年 NJU. All rights reserved.
//

import UIKit

class CrazyTableViewController: UITableViewController
{
    
    var meters=["Top 1","Top 2","Top 3","Top 4","Top 5"]
    
    let defaultStand = UserDefaults.standard
    var aab = 666
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.tableView.isScrollEnabled=false
        
        self.tableView.allowsSelection=false
        
        self.tableView.backgroundView=UIImageView(image: UIImage(named: "bg1"))
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int
    {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // #warning Incomplete implementation, return the number of rows
        return meters.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "crazyCell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text=meters[indexPath.row]
        if meters[indexPath.row]=="Top 1"
        {
            aab = defaultStand.integer(forKey: UserDefaultKeys.crazy.ctop1.rawValue)
        }
        else if meters[indexPath.row]=="Top 2"
        {
            aab = defaultStand.integer(forKey: UserDefaultKeys.crazy.ctop2.rawValue)
        }
        else if meters[indexPath.row]=="Top 3"
        {
            aab = defaultStand.integer(forKey: UserDefaultKeys.crazy.ctop3.rawValue)
        }
        else if meters[indexPath.row]=="Top 4"
        {
            aab = defaultStand.integer(forKey: UserDefaultKeys.crazy.ctop4.rawValue)
        }
        else if meters[indexPath.row]=="Top 5"
        {
            aab = defaultStand.integer(forKey: UserDefaultKeys.crazy.ctop5.rawValue)
        }
        cell.detailTextLabel?.text=String(aab)
        cell.backgroundColor=UIColor.clear
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
