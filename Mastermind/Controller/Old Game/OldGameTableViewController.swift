//
//  OldGameTableViewController.swift
//  Mastermind
//
//  Created by Sébastien Gaya on 27/03/2018.
//  Copyright © 2018 Sébastien Gaya. All rights reserved.
//

import UIKit

class OldGameTableViewController: UITableViewController {
    var game: Game!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        game.getAISolve()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return game.rounds.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "oldRoundTableViewCell", for: indexPath) as? OldRoundTableViewCell else {
            fatalError("Can't instantiate OldRoundTableViewCell")
        }

        // Configure the cell...
        let round = game.rounds[indexPath.row]
        var aiRound: Round?
        if indexPath.row < game.aiRounds.count {
            aiRound = game.aiRounds[indexPath.row]
        }
        
        guard let userCombination = round.userCombination as? [Int] else {
            fatalError("userCombination is not full")
        }
        
        cell.roundLabel.text = "Round \(indexPath.row + 1)"
        
        for imageView in cell.combinationImageViews {
            let number = imageView.tag
            let image = Game.Color(rawValue: userCombination[number])?.image()
            
            imageView.image = image
        }
        
        var placedText = "Placed : \(round.placedCount!.description) "
        if aiRound != nil && aiRound!.placedCount != nil && aiRound!.placedCount != 4 {
            placedText += "(AI : \(aiRound!.placedCount!.description))"
        } else {
            placedText += "(AI : Trouvé)"
        }
        cell.placedLabel.text = placedText
        
        
        var misplacedText = "Misplaced : \(round.misplacedCount!.description) "
        if aiRound != nil && aiRound!.placedCount != nil && aiRound!.placedCount != 4 {
            misplacedText += "(AI : \(aiRound!.misplacedCount!.description))"
        } else {
            misplacedText += "(AI : Trouvé)"
        }
        cell.misplacedLabel.text = misplacedText
        
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
