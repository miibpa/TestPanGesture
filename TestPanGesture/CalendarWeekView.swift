import Foundation
import UIKit

protocol CalendarWeekViewDelegate: class {
    func calendarWeekView(_ view: CalendarWeekView, didSelectDate date: Date)
}

class CalendarWeekView: UIView {
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 6
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    private var dates: [Date] = []
    private var availableDates: [Date] = []
    
    weak var delegate: CalendarWeekViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    override func layoutSubviews() {
        let height: CGFloat = (bounds.width - 32 - 36) / 7
        collectionView.heightAnchor.constraint(equalToConstant: height).isActive = true
        collectionView.layoutIfNeeded()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureView()
    }
    
    func setDays(_ days: [Date], availableDays: [Date]) {
        availableDates = days
        dates = days
        
        guard
            availableDates.first?.startOfDay != nil,
            availableDates.last?.startOfDay != nil
            else { return }
        
        collectionView.reloadData()
    }
    
    // Select the date passed if it is available
    func selectDay(_ day: Date) {
        if let date = day.startOfDay,
            availableDates.contains(date),
            let index = dates.firstIndex(of: date) {
            
            let indexPath = IndexPath(row: index, section: 0)
            collectionView.selectItem(at: indexPath,
                                      animated: false,
                                      scrollPosition: .centeredHorizontally)
        }
    }
    
    private func configureView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        collectionView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        collectionView.registerNibCell(CalendarCell.self)
    }
}

extension CalendarWeekView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return dates.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let date = dates[indexPath.row]
        //let isSelectable = !availableDates.filter { $0.isSameDay(date: date) }.isEmpty
        
        let cell: CalendarCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.configure(with: date, isSelectable: true)
        
        return cell
    }
}

extension CalendarWeekView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedDate = dates[indexPath.row]
        delegate?.calendarWeekView(self, didSelectDate: selectedDate)
    }
}

extension CalendarWeekView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.height
        return CGSize(width: size, height: size)
    }
}
