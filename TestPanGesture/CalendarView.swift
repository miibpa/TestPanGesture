import Foundation
import UIKit

protocol CalendarViewDelegate: class {
    func calendarView(_ view: CalendarView, didSelectDate date: Date)
}

class CalendarView: UIView {
    private lazy var firstWeekCollectionView: CalendarWeekView = {
        return CalendarWeekView()
    }()
    
    private lazy var secondWeekCollectionView: CalendarWeekView = {
        return CalendarWeekView()
    }()
    
    private lazy var thirdWeekCollectionView: CalendarWeekView = {
        return CalendarWeekView()
    }()
    
    private var firstWeekCollectionViewHeightConstraint: NSLayoutConstraint?
    private var secondWeekCollectionViewHeightConstraint: NSLayoutConstraint?
    private var thirdWeekCollectionViewHeightConstraint: NSLayoutConstraint?
    
    private lazy var calendarStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.addArrangedSubview(firstWeekCollectionView)
        stackView.addArrangedSubview(secondWeekCollectionView)
        stackView.addArrangedSubview(thirdWeekCollectionView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan)))
        return stackView
    }()
    
    private var dates: [Date] = []
    private var availableDates: [Date] = []
    
    private var selectedView: SelectedView? = nil {
        didSet { compactView() }
    }
    
    private var isViewCompact = false
    
    private var weekCollectionViewHeight: CGFloat = 44
    
    weak var delegate: CalendarViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    override func layoutSubviews() {
        let height: CGFloat = (bounds.width - 32 - 36) / 7
        weekCollectionViewHeight = height
        firstWeekCollectionViewHeightConstraint = firstWeekCollectionView.heightAnchor.constraint(equalToConstant: height)
        secondWeekCollectionViewHeightConstraint = secondWeekCollectionView.heightAnchor.constraint(equalToConstant: height)
        thirdWeekCollectionViewHeightConstraint = thirdWeekCollectionView.heightAnchor.constraint(equalToConstant: height)
        
        firstWeekCollectionViewHeightConstraint?.isActive = true
        secondWeekCollectionViewHeightConstraint?.isActive = true
        thirdWeekCollectionViewHeightConstraint?.isActive = true
        
        firstWeekCollectionView.layoutIfNeeded()
        secondWeekCollectionView.layoutIfNeeded()
        thirdWeekCollectionView.layoutIfNeeded()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureView()
    }
    
    func setDays(_ days: [Date]) {
        availableDates = days
        
        configureDates()
    }
    
    // Select the date passed if it is available
    func selectDay(_ day: Date) {
        if let date = day.startOfDay,
            availableDates.contains(date) {
            
            firstWeekCollectionView.selectDay(day)
            secondWeekCollectionView.selectDay(day)
            thirdWeekCollectionView.selectDay(day)
        }
    }
    
    private func configureView() {
        addSubview(calendarStackView)
        calendarStackView.translatesAutoresizingMaskIntoConstraints = false
        calendarStackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        calendarStackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        calendarStackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        firstWeekCollectionView.delegate = self
        secondWeekCollectionView.delegate = self
        thirdWeekCollectionView.delegate = self
        
        configureDates()
    }
    
    private func configureDates() {
        guard
            let date = Date().startOfDay // Today
            else { return }
        
        firstWeekCollectionView.setDays(date.weekDays(), availableDays: date.weekDays())
        secondWeekCollectionView.setDays(date.weekDays(offset: 1), availableDays: date.weekDays())
        thirdWeekCollectionView.setDays(date.weekDays(offset: 2), availableDays: date.weekDays())
    }
}

private extension CalendarView {
    func compactView(velocity: CGFloat = 200) {
        guard let selectedView = selectedView else { return }
        isViewCompact = true
        switch selectedView {
        case .first:
            hideView(view: secondWeekCollectionView, constraint: secondWeekCollectionViewHeightConstraint, velocity: velocity)
            hideView(view: thirdWeekCollectionView, constraint: thirdWeekCollectionViewHeightConstraint, velocity: velocity)
        case .second:
            hideView(view: firstWeekCollectionView, constraint: firstWeekCollectionViewHeightConstraint, velocity: velocity)
            hideView(view: thirdWeekCollectionView, constraint: thirdWeekCollectionViewHeightConstraint, velocity: velocity)
        case .third:
            hideView(view: firstWeekCollectionView, constraint: firstWeekCollectionViewHeightConstraint, velocity: velocity)
            hideView(view: secondWeekCollectionView, constraint: secondWeekCollectionViewHeightConstraint, velocity: velocity)
        }
    }
    
    func expandView(velocity: CGFloat = 200) {
        isViewCompact = false
        showView(view: firstWeekCollectionView, constraint: firstWeekCollectionViewHeightConstraint, velocity: velocity)
        showView(view: secondWeekCollectionView, constraint: secondWeekCollectionViewHeightConstraint, velocity: velocity)
        showView(view: thirdWeekCollectionView, constraint: thirdWeekCollectionViewHeightConstraint, velocity: velocity)
    }
    
    func hideView(view: UIView, constraint: NSLayoutConstraint?, velocity: CGFloat) {
        guard let constraint = constraint else { return }
        
        let duration = min(constraint.constant / velocity, 0.5) //calculate the animation duration based on the distance left (current view height) and pan velocity
        
        //        UIView.animate(withDuration: Double(duration), delay: 0.0, options: [.curveEaseOut]) {
        //            constraint.constant = 0
        //            view.alpha = 0
        //            self.view.layoutIfNeeded()
        //        }
        
        let normalizedVelocity = velocity / weekCollectionViewHeight
        
        UIView.animate(withDuration: 0.5,
                       delay: 0.0, usingSpringWithDamping: 0.9,
                       initialSpringVelocity: normalizedVelocity,
                       options: .curveEaseOut,
                       animations: {
                        constraint.constant = 0
                        view.alpha = 0
                        self.layoutIfNeeded()
                       }, completion: nil)
    }
    
    func showView(view: UIView, constraint: NSLayoutConstraint?, velocity: CGFloat) {
        guard let constraint = constraint else { return }
        
        let duration = min((weekCollectionViewHeight - constraint.constant) / velocity, 0.5) //calculate the animation duration based on the distance left (current view height) and pan velocity
        
        //        UIView.animate(withDuration: Double(duration), delay: 0.0, options: [.curveEaseIn]) {
        //            constraint.constant = viewHeigth
        //            view.alpha = 1
        //            self.view.layoutIfNeeded()
        //        }
        
        let normalizedVelocity = velocity / weekCollectionViewHeight
        
        UIView.animate(withDuration: 0.5, delay: 0.0,
                       usingSpringWithDamping: 0.9,
                       initialSpringVelocity: normalizedVelocity,
                       options: .curveEaseIn,
                       animations: {
                        constraint.constant = self.weekCollectionViewHeight
                        view.alpha = 1
                        self.layoutIfNeeded()
                       }, completion: nil)
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        
        if translation.y < 0 && isViewCompact { return }
        if translation.y > 0 && !isViewCompact { return }
        
        let translationY = translation.y / 2 //divide this to make expansion/compact smoother
        
        if gesture.state == .ended {
            let velocity = abs(gesture.velocity(in: self).y / 2) //smooth the velocity also
            
            if abs(translationY) > weekCollectionViewHeight / 3 {
                switch translationY > 0 {
                case true:
                    expandView(velocity: velocity)
                case false:
                    compactView(velocity: velocity)
                }
            } else {
                switch translationY > 0 {
                case true:
                    compactView(velocity: velocity)
                case false:
                    expandView(velocity: velocity)
                }
            }
            return
        }
        
        let heigthConstraint = translationY > 0 ? translationY : weekCollectionViewHeight + translationY
        guard heigthConstraint < weekCollectionViewHeight else {
            return
        }
        redrawViews(heigth: heigthConstraint)
    }
    
    func redrawViews(heigth: CGFloat) {
        let alpha = heigth / weekCollectionViewHeight
        
        switch selectedView {
        case .first:
            secondWeekCollectionViewHeightConstraint?.constant = heigth
            secondWeekCollectionView.alpha = alpha
            thirdWeekCollectionViewHeightConstraint?.constant = heigth
            thirdWeekCollectionView.alpha = alpha
            layoutIfNeeded()
        case .second:
            firstWeekCollectionViewHeightConstraint?.constant = heigth
            firstWeekCollectionView.alpha = alpha
            thirdWeekCollectionViewHeightConstraint?.constant = heigth
            thirdWeekCollectionView.alpha = alpha
            layoutIfNeeded()
        case .third:
            firstWeekCollectionViewHeightConstraint?.constant = heigth
            firstWeekCollectionView.alpha = alpha
            secondWeekCollectionViewHeightConstraint?.constant = heigth
            secondWeekCollectionView.alpha = alpha
            layoutIfNeeded()
        case .none:
            return
        }
    }
}

extension CalendarView: CalendarWeekViewDelegate {
    func calendarWeekView(_ view: CalendarWeekView, didSelectDate date: Date) {
        if view == firstWeekCollectionView { selectedView = .first }
        if view == secondWeekCollectionView { selectedView = .second }
        if view == thirdWeekCollectionView { selectedView = .third }
    }
}

enum SelectedView {
    case first, second, third
}
