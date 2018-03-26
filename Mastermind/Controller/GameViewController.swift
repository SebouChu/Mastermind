//
//  GameViewController.swift
//  Mastermind
//
//  Created by Sébastien Gaya on 20/03/2018.
//  Copyright © 2018 Sébastien Gaya. All rights reserved.
//

import UIKit
import AVFoundation
import FirebaseAuth
import FirebaseDatabase

class GameViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Properties
    var game = Game()
    var audioPlayer = AVAudioPlayer()
    
    var colorButtonsOriginalPositions = [Int: CGPoint]()
    var hoverImageViewTag: Int = -1
    
    // MARK: - Outlets
    @IBOutlet weak var roundsCounterLabel: UILabel!
    @IBOutlet weak var roundsTableView: UITableView!
    @IBOutlet var colorButtons: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(endGame), name: Notification.Name(rawValue: "endGame"), object: nil)
        
        for i in 0..<colorButtons.count {
            let colorButton = colorButtons[i]
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanOnButton))
            colorButton.addGestureRecognizer(panGestureRecognizer)
            colorButtonsOriginalPositions[colorButton.tag] = colorButton.center
        }
        
        roundsTableView.delegate = self
        roundsTableView.dataSource = self
        roundsTableView.layer.borderColor = UIColor.darkGray.cgColor
        roundsTableView.layer.borderWidth = 1.0
        roundsCounterLabel.text = "Round n°\(game.rounds.count)"
        
        playSound(named: "here-we-go")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func numberBtnPressed(_ sender: UIButton) {
        if let lastRound = game.rounds.last, lastRound.selectedIndex < 4 {
            lastRound.userCombination[lastRound.selectedIndex] = sender.tag
            lastRound.updateSelectedIndex()
            
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
            roundsCounterLabel.text = "Round n°\(game.rounds.count)"
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
        if let currentUser = Auth.auth().currentUser {
            let timestamp = game.timestamp
            let secretCombination = game.secretCombination
            let userCombinations = game.userCombinations
            
            let db = Database.database().reference().child("users/\(currentUser.uid)/games")
            db.childByAutoId().setValue([
                "secretCombination": secretCombination,
                "userCombinations": userCombinations,
                "timestamp": timestamp
            ])
        }
        
        
        let alert = UIAlertController(title: "You Win !", message: "You found the combination in \(game.rounds.count) tries ! It was \(game.secretCombination)", preferredStyle: .alert)
        let action = UIAlertAction(title: "Go to Main Menu", style: .default) { (action) in
            self.navigationController?.popToRootViewController(animated: true)
        }
        alert.addAction(action)
        self.present(alert, animated: true) {
            self.playSound(named: "ah")
        }
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
        var aiRound: Round?
        if indexPath.row < game.aiRounds.count {
            aiRound = game.aiRounds[indexPath.row]
        }
        
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
            
        var placedText = "Placed : "
        if let myPlacedCount = round.placedCount {
            placedText += "\(myPlacedCount.description) "
            if aiRound != nil && aiRound!.placedCount != nil && aiRound!.placedCount != 4 {
                placedText += "(AI : \(aiRound!.placedCount!.description))"
            } else {
                placedText += "(AI : Trouvé)"
            }
        } else {
            placedText += "? "
            if aiRound != nil && aiRound!.placedCount != nil && aiRound!.placedCount != 4 {
                placedText += "(AI : ?)"
            } else {
                placedText += "(AI : Trouvé)"
            }
        }
        
        
        var misplacedText = "Misplaced : "
        if let myMisplacedCount = round.misplacedCount {
            misplacedText += "\(myMisplacedCount.description) "
            if aiRound != nil && aiRound!.placedCount != nil && aiRound!.placedCount != 4 {
                misplacedText += "(AI : \(aiRound!.misplacedCount!.description))"
            } else {
                misplacedText += "(AI : Trouvé)"
            }
        } else {
            misplacedText += "? "
            if aiRound != nil && aiRound!.placedCount != nil && aiRound!.placedCount != 4 {
                misplacedText += "(AI : ?)"
            } else {
                misplacedText += "(AI : Trouvé)"
            }
        }
        
        cell.placedCounterLabel.text = placedText
        cell.misplacedCounterLabel.text = misplacedText
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print(indexPath.row)
    }
    
    // MARK: - UIGestureRecognizer Handle Methods
    
    @objc func handleTapOnImageView(gestureRecognizer: UITapGestureRecognizer) {
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
    
    @objc func handlePanOnButton(gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            break
        case .changed:
            let translation = gestureRecognizer.translation(in: self.view)
            if let colorButton = gestureRecognizer.view {
                colorButton.center = CGPoint(x: colorButton.center.x + translation.x, y: colorButton.center.y + translation.y)
                // Check if last cell visible & new center of dragged color button
                let lastIndex = roundsTableView.numberOfRows(inSection: 0) - 1
                let lastIndexPath = IndexPath(row: lastIndex, section: 0)
                let lastCell = roundsTableView.cellForRow(at: lastIndexPath) as! RoundTableViewCell
                if roundsTableView.visibleCells.contains(lastCell) {
                    var newHoverImageViewTag: Int = -1
                    for imageView in lastCell.userCombinationImageViews {
                        if let newCenter = colorButton.superview?.convert(colorButton.center, to: imageView), imageView.layer.visibleRect.contains(newCenter) {
                            newHoverImageViewTag = imageView.tag
                            break
                        }
                    }
                    if hoverImageViewTag != newHoverImageViewTag {
                        hoverImageViewTag = newHoverImageViewTag
                        if hoverImageViewTag != -1 {
                            game.rounds[lastIndex].selectedIndex = hoverImageViewTag
                            roundsTableView.reloadRows(at: [lastIndexPath], with: .none)
                        } else {
                        }
                    }
                }
            }
            gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
            break
        case .ended:
            if let colorButton = gestureRecognizer.view {
                if hoverImageViewTag != -1 {
                    let lastRow = roundsTableView.numberOfRows(inSection: 0) - 1
                    let roundSelectedIndex = game.rounds[lastRow].selectedIndex
                    game.rounds[lastRow].userCombination[roundSelectedIndex] = colorButton.tag
                    game.rounds[lastRow].updateSelectedIndex()
                    let lastIndexPath = IndexPath(row: lastRow, section: 0)
                    roundsTableView.reloadRows(at: [lastIndexPath], with: .none)
                }
                
                colorButton.center = colorButtonsOriginalPositions[colorButton.tag]!
                colorButton.updateConstraintsIfNeeded()
                hoverImageViewTag = -1
            }
        default:
            break
        }
    }
    
    // MARK: - AVFoundation Methods
    
    func playSound(named soundFileName: String) {
        let soundURL = Bundle.main.url(forResource: soundFileName, withExtension: "wav")
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL!)
        } catch {
            print(error)
        }
        
        audioPlayer.play()
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
