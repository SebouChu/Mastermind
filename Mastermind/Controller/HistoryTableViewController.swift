//
//  HistoryTableViewController.swift
//  Mastermind
//
//  Created by Sébastien Gaya on 26/03/2018.
//  Copyright © 2018 Sébastien Gaya. All rights reserved.
//

import UIKit
import SVProgressHUD
import FirebaseAuth
import FirebaseDatabase

class HistoryTableViewController: UITableViewController {
    
    var games = [Game]()
    var selectedIndex: Int = 0
    
    @IBOutlet weak var refreshBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserHistory()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func refreshBtnPressed(_ sender: UIBarButtonItem) {
        loadUserHistory()
    }
    
    func loadUserHistory() {
        SVProgressHUD.show()
        refreshBarButton.isEnabled = false
        guard let user = Auth.auth().currentUser else {
            // User not signed in
            let alert = UIAlertController(title: "Not logged in", message: "Game history is user-only.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Main Menu", style: .default, handler: { (action) in
                self.navigationController?.popToRootViewController(animated: true)
            }))
            self.present(alert, animated: true)
            return
        }
        
        let historyDB = Database.database().reference().child("users/\(user.uid)/games")
        
        historyDB.observeSingleEvent(of: .value) { (snapshot) in
            // Get user games
            SVProgressHUD.dismiss()
            guard let value = snapshot.value as? [String: [String:Any]] else {
                let alert = UIAlertController(title: "No saved games", message: "Your game history is empty. Go play some !", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Main Menu", style: .default, handler: { (action) in
                    self.navigationController?.popToRootViewController(animated: true)
                }))
                self.present(alert, animated: true)
                self.refreshBarButton.isEnabled = true
                return
            }
            
            self.games = [Game]()
            
            for game in value {
                let gameData = game.value
                let secretCombination = gameData["secretCombination"] as? [Int]
                let timestamp = gameData["timestamp"] as? Int
                let userCombinations = gameData["userCombinations"] as? [[Int]]
                
                let game = Game(secret: secretCombination!, combinations: userCombinations!, timestamp: timestamp!)
                self.games.append(game)
            }
            
            self.refreshBarButton.isEnabled = true
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return games.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "historyTableViewCell", for: indexPath) as? HistoryTableViewCell else {
            fatalError("Can't instantiate HistoryTableViewCell")
        }

        // Configure the cell...
        let game = games[indexPath.row]
        
        let secretCombination = game.secretCombination
        for imageView in cell.combinationImageViews {
            let number = secretCombination[imageView.tag]
            let image = Game.Color(rawValue: number)?.image()
            
            imageView.image = image
        }
        
        let timestamp = game.timestamp
        let dateObj = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "fr_FR")
        
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        let date = dateFormatter.string(from: dateObj)
        
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        let time = dateFormatter.string(from: dateObj)
        
        cell.dateLabel.text = date
        cell.timeLabel.text = time

        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.selectedIndex = indexPath.row
        self.performSegue(withIdentifier: "goToOldGame", sender: self)
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToOldGame" {
            guard let oldGameTVC = segue.destination as? OldGameTableViewController else {
                fatalError("Can't cast to OldGameTableViewController")
            }
            
            oldGameTVC.game = self.games[self.selectedIndex]
        }
    }
    

}
