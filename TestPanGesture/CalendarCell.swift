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
            ? "Hoy"
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
    }
    
    private func configureView() {
        numberLabel.font = UIFont.scaledFont(ofSize: 18, weight: .semibold)
        dayLabel.font = UIFont.scaledFont(ofSize: 11, weight: .semibold)
        todayIndicatorView.backgroundColor = .red
    }
    
    private func asSelected() {
        numberLabel.textColor = .white
        dayLabel.textColor = .white
        todayIndicatorView.isHidden = true
        backgroundColor = .green
        isUserInteractionEnabled = false
    }
    
    private func asSelectable() {
        numberLabel.textColor = .black
        dayLabel.textColor = .black
        todayIndicatorView.isHidden = true
        backgroundColor = .white
        isUserInteractionEnabled = true
    }
    
    private func asNotSelectable() {
        numberLabel.textColor = .gray
        dayLabel.textColor = .gray
        todayIndicatorView.isHidden = true
        backgroundColor = .white
        isUserInteractionEnabled = false
    }
    
    private func asToday() {
        numberLabel.textColor = .black
        dayLabel.textColor = .black
        todayIndicatorView.isHidden = false
        backgroundColor = .white
        isUserInteractionEnabled = false
    }
}

extension UIFont {
    static func scaledFont(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let font = UIFont.systemFont(ofSize: size, weight: weight)
        return UIFontMetrics.default.scaledFont(for: font)
    }
}
