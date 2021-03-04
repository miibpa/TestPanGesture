import UIKit

class CalendarCell: UICollectionViewCell {
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var todayIndicatorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureView()
    }
    
    override var isSelected: Bool {
        didSet { isSelected ? asSelected() : asSelectable() }
    }
    
    func configure(with date: Date, isSelectable: Bool) {
        numberLabel.text = String(date.dayNumber)
        dayLabel.text = date.isToday
            ? NSLocalizedString("all_today", comment: "").uppercased()
            : date.weekdayShortName.uppercased()
        
        switch (isSelected, isSelectable) {
        case (true, _):
            asSelected()
        case (false, true):
            asSelectable()
        case (false, false):
            asNotSelectable()
        }
        
        if date.isToday {
            asToday()
        }
        accessibilityIdentifier =  AccessibilityIdentifier.Delivery.calendarCell
    }
    
    private func configureView() {
        numberLabel.font = .semibold18
        dayLabel.font = .semibold11
        todayIndicatorView.backgroundColor = .tomato100
    }
    
    private func asSelected() {
        numberLabel.textColor = .white100
        dayLabel.textColor = .white100
        todayIndicatorView.isHidden = true
        backgroundColor = .cucumber100
        isUserInteractionEnabled = false
    }
    
    private func asSelectable() {
        numberLabel.textColor = .black100
        dayLabel.textColor = .black100
        todayIndicatorView.isHidden = true
        backgroundColor = .white100
        isUserInteractionEnabled = true
    }
    
    private func asNotSelectable() {
        numberLabel.textColor = .smoked40
        dayLabel.textColor = .smoked40
        todayIndicatorView.isHidden = true
        backgroundColor = .white100
        isUserInteractionEnabled = false
    }
    
    private func asToday() {
        numberLabel.textColor = .black100
        dayLabel.textColor = .black100
        todayIndicatorView.isHidden = false
        backgroundColor = .whiteCreamLight
        isUserInteractionEnabled = false
    }
}
