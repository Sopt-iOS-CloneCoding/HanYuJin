//
//  StopwatchTableViewCell.swift
//  Clock-Clone
//
//  Created by 한유진 on 2022/04/25.
//

import UIKit

class StopwatchTableViewCell: UITableViewCell {

    //Cell을 구분하기 위한 Identifier
    static let identifier = "StopwatchTableViewCell"
    
    @IBOutlet weak var labLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //각 Cell 별로 다른 정보가 표시되어야 하므로, 값을 넣어주는 함수
    func setData(_ laps: [String], _ indexPath: IndexPath){
        labLabel.text = "랩 \((laps.count) - (indexPath as NSIndexPath).row)"
        timerLabel.text = laps[laps.count - (indexPath as NSIndexPath).row - 1]
    }
}
