//
//  OldRoundTableViewCell.swift
//  Mastermind
//
//  Created by Sébastien Gaya on 27/03/2018.
//  Copyright © 2018 Sébastien Gaya. All rights reserved.
//

import UIKit

class OldRoundTableViewCell: UITableViewCell {

    @IBOutlet var combinationImageViews: [UIImageView]!
    @IBOutlet weak var roundLabel: UILabel!
    @IBOutlet weak var placedLabel: UILabel!
    @IBOutlet weak var misplacedLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
