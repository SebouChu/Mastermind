//
//  GameViewController.swift
//  Mastermind
//
//  Created by Sébastien Gaya on 20/03/2018.
//  Copyright © 2018 Sébastien Gaya. All rights reserved.
//

import UIKit

class GameViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Properties
    var game = Game()
    
    // MARK: - Outlets
    @IBOutlet weak var roundsCounterLabel: UILabel!
    @IBOutlet weak var roundsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(endGame), name: Notification.Name(rawValue: "endGame"), object: nil)
        
        roundsTableView.delegate = self
        roundsTableView.dataSource = self
        roundsTableView.layer.borderColor = UIColor.darkGray.cgColor
        roundsTableView.layer.borderWidth = 1.0
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func numberBtnPressed(_ sender: UIButton) {
        if let lastRound = game.rounds.last, lastRound.selectedIndex < 4 {
            lastRound.userCombination[lastRound.selectedIndex] = sender.tag
            lastRound.selectedIndex += 1
            
            let lastRow = roundsTableView.numberOfRows(inSection: 0) - 1
            let lastIndexPath = IndexPath(row: lastRow, section: 0)
            roundsTableView.reloadRows(at: [lastIndexPath], with: .none)
        }
        
    }
    
    @IBAction func backspaceBtnPressed(_ sender: UIButton) {
        if let lastRound = game.rounds.last {
            if lastRound.selectedIndex > 0 {
                lastRound.selectedIndex -= 1
            }
            
            lastRound.userCombination[lastRound.selectedIndex] = nil
            let lastRow = roundsTableView.numberOfRows(inSection: 0) - 1
            let lastIndexPath = IndexPath(row: lastRow, section: 0)
            roundsTableView.reloadRows(at: [lastIndexPath], with: .none)
        }
    }
    
    @IBAction func checkBtnPressed(_ sender: UIButton) {
        if let lastRound = game.rounds.last, let _ = lastRound.userCombination as? [Int] {
            //print(lastUserCombination)
            game.endRound()
            roundsTableView.reloadData()
            let lastRow = roundsTableView.numberOfRows(inSection: 0) - 1
            let lastIndexPath = IndexPath(row: lastRow, section: 0)
            roundsTableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
        } else {
            let alert = UIAlertController(title: "Incomplete Combination", message: "You didn't fill the combination.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func endGame() {
        let alert = UIAlertController(title: "You Win !", message: "You found the combination in \(game.rounds.count) try/tries ! It was \(game.secretCombination)", preferredStyle: .alert)
        let action = UIAlertAction(title: "Go to Main Menu", style: .default) { (action) in
            self.navigationController?.popToRootViewController(animated: true)
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - UITableView Delegate & Data Source Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return game.rounds.count
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "roundTableViewCell") as? RoundTableViewCell else {
            fatalError("Can't instantiate RoundTableViewCell")
        }
        
        let round = game.rounds[indexPath.row]
        cell.selectionStyle = .none
        
        for colorImageView in cell.userCombinationImageViews {
            colorImageView.layer.cornerRadius = 16
            
            if colorImageView.gestureRecognizers == nil || colorImageView.gestureRecognizers!.isEmpty {
                let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapOnImageView))
                tapGestureRecognizer.numberOfTapsRequired = 1
                colorImageView.addGestureRecognizer(tapGestureRecognizer)
            }
            
            if let number = round.userCombination[colorImageView.tag] {
                colorImageView.image = Game.Color(rawValue: number)?.image()
            } else {
                colorImageView.image = UIImage(named: "grey")
            }
            
            if indexPath.row == game.rounds.count - 1, colorImageView.tag == round.selectedIndex {
                colorImageView.layer.borderColor = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1).cgColor
                colorImageView.layer.borderWidth = 2.0
            } else {
                colorImageView.layer.borderColor = UIColor.clear.cgColor
                colorImageView.layer.borderWidth = 0
            }
        }
        
        cell.placedCounterLabel.text = "Good : \(round.placedCount?.description ?? "?")"
        cell.misplacedCounterLabel.text = "Almost Good : \(round.misplacedCount?.description ?? "?")"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print(indexPath.row)
    }
    
    // MARK: - UITapGestureRecognizer Delegate Methods
    @objc func handleTapOnImageView(gestureRecognizer: UIGestureRecognizer) {
        print(gestureRecognizer.view?.tag ?? "0")
        let tapLocation = gestureRecognizer.location(in: roundsTableView)
        print(tapLocation.x)
        print(tapLocation.y)
        if let selectedIndexPath = roundsTableView.indexPathForRow(at: tapLocation) {
            print(selectedIndexPath.row)
            self.game.rounds[selectedIndexPath.row].selectedIndex = gestureRecognizer.view!.tag
            roundsTableView.reloadRows(at: [selectedIndexPath], with: .none)
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
