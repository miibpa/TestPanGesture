//
//  ViewController.swift
//  TestPanGesture
//
//  Created by Miguel Ibañez Patricio on 2/3/21.
//

import UIKit

let viewHeight: CGFloat = 100

class ViewController: UIViewController {
    @IBOutlet private weak var firstView: UIView!
    @IBOutlet private weak var secondView: UIView!
    @IBOutlet private weak var thirdView: UIView!
    @IBOutlet private weak var stackView: UIView!
    
    @IBOutlet private weak var firstViewHeightConstrint: NSLayoutConstraint!
    @IBOutlet private weak var secondViewHeightConstrint: NSLayoutConstraint!
    @IBOutlet private weak var thirdViewHeightConstraint: NSLayoutConstraint!
    
    private var selectedView: SelectedView? = nil {
        didSet { compactView() }
    }
    
    var isViewCompact = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: stackView)
        
        if translation.y < 0 && isViewCompact { return }
        if translation.y > 0 && !isViewCompact { return }
        
        let translationY = translation.y / 2 //divide this to make expansion/compact smoother
        
        if gesture.state == .ended {
            let velocity = abs(gesture.velocity(in: stackView).y / 2) //smooth the velocity also
            
            if abs(translationY) > viewHeight / 3 {
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
        
        let heigthConstraint = translationY > 0 ? translationY : viewHeight + translationY
        guard heigthConstraint < viewHeight else {
            return
        }
        redrawViews(heigth: heigthConstraint)
    }
}

private extension ViewController {
    @IBAction func firstViewTapped(_ sender: Any) { selectedView = .first }
    
    @IBAction func secondViewTapped(_ sender: Any) { selectedView = .second }
    
    @IBAction func thridViewTapped(_ sender: Any) { selectedView = .third }
    
    func redrawViews(heigth: CGFloat) {
        let alpha = heigth / viewHeight
        
        switch selectedView {
        case .first:
            secondViewHeightConstrint.constant = heigth
            secondView.alpha = alpha
            thirdViewHeightConstraint.constant = heigth
            thirdView.alpha = alpha
            self.view.layoutIfNeeded()
        case .second:
            firstViewHeightConstrint.constant = heigth
            firstView.alpha = alpha
            thirdViewHeightConstraint.constant = heigth
            thirdView.alpha = alpha
            self.view.layoutIfNeeded()
        case .third:
            firstViewHeightConstrint.constant = heigth
            firstView.alpha = alpha
            secondViewHeightConstrint.constant = heigth
            secondView.alpha = alpha
            self.view.layoutIfNeeded()
        case .none:
            return
        }
    }
    
    func compactView(velocity: CGFloat = 200) {
        guard let selectedView = selectedView else { return }
        isViewCompact = true
        switch selectedView {
        case .first:
            hideView(view: secondView, constraint: secondViewHeightConstrint, velocity: velocity)
            hideView(view: thirdView, constraint: thirdViewHeightConstraint, velocity: velocity)
        case .second:
            hideView(view: firstView, constraint: firstViewHeightConstrint, velocity: velocity)
            hideView(view: thirdView, constraint: thirdViewHeightConstraint, velocity: velocity)
        case .third:
            hideView(view: firstView, constraint: firstViewHeightConstrint, velocity: velocity)
            hideView(view: secondView, constraint: secondViewHeightConstrint, velocity: velocity)
        }
    }
    
    func expandView(velocity: CGFloat = 200) {
        isViewCompact = false
        showView(view: firstView, constraint: firstViewHeightConstrint, velocity: velocity)
        showView(view: secondView, constraint: secondViewHeightConstrint, velocity: velocity)
        showView(view: thirdView, constraint: thirdViewHeightConstraint, velocity: velocity)
    }
    
    func hideView(view: UIView, constraint: NSLayoutConstraint, velocity: CGFloat) {
        let duration = min(constraint.constant / velocity, 0.5) //calculate the animation duration based on the distance left (current view height) and pan velocity
        
        //        UIView.animate(withDuration: Double(duration), delay: 0.0, options: [.curveEaseOut]) {
        //            constraint.constant = 0
        //            view.alpha = 0
        //            self.view.layoutIfNeeded()
        //        }
        
        let normalizedVelocity = velocity / viewHeight
        
        UIView.animate(withDuration: 0.5,
                       delay: 0.0, usingSpringWithDamping: 0.9,
                       initialSpringVelocity: normalizedVelocity,
                       options: .curveEaseOut,
                       animations: {
                        constraint.constant = 0
                        view.alpha = 0
                        self.view.layoutIfNeeded()
                       }, completion: nil)
    }
    
    func showView(view: UIView, constraint: NSLayoutConstraint, velocity: CGFloat) {
        let duration = min((viewHeight - constraint.constant) / velocity, 0.5) //calculate the animation duration based on the distance left (current view height) and pan velocity
        
        //        UIView.animate(withDuration: Double(duration), delay: 0.0, options: [.curveEaseIn]) {
        //            constraint.constant = viewHeigth
        //            view.alpha = 1
        //            self.view.layoutIfNeeded()
        //        }
        
        let normalizedVelocity = velocity / viewHeight
        
        UIView.animate(withDuration: 0.5, delay: 0.0,
                       usingSpringWithDamping: 0.9,
                       initialSpringVelocity: normalizedVelocity,
                       options: .curveEaseIn,
                       animations: {
                        constraint.constant = viewHeight
                        view.alpha = 1
                        self.view.layoutIfNeeded()
                       }, completion: nil)
    }
}

enum SelectedView {
    case first, second, third
}
