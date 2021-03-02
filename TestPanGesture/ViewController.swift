//
//  ViewController.swift
//  TestPanGesture
//
//  Created by Miguel Ibañez Patricio on 2/3/21.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var thirdView: UIView!
    @IBOutlet weak var stackView: UIView!
    
    @IBOutlet weak var firstViewHeightConstrint: NSLayoutConstraint!
    @IBOutlet weak var secondViewHeightConstrint: NSLayoutConstraint!
    @IBOutlet weak var thirdViewHeightConstraint: NSLayoutConstraint!
    
    private var selectedView: SelectedView? = nil {
        didSet {
            compactView()
        }
    }
    
    var isViewCompact = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func handlePan(_ gesture: UIPanGestureRecognizer) {
        // 1
        
        
        let translation = gesture.translation(in: stackView)
        
        if translation.y < 0 && isViewCompact { return }
        
        if translation.y > 0 && !isViewCompact { return }
        
        let translationY = translation.y / 2
        
        var heigthConstraint: CGFloat {
            switch translationY > 0 {
            case true:
                return translationY
            case false:
                return 100 + translationY
            }
        }
        print(heigthConstraint)
        if gesture.state == .ended {
            if abs(translationY) > 30 {
                switch translationY > 0 {
                case true:
                    expandView()
                case false:
                    compactView()
                }
            } else {
                switch translationY > 0 {
                case true:
                    compactView()
                case false:
                    expandView()
                }
            }
            return
        }

        guard heigthConstraint < 100 else {
            return
        }
        
        switch selectedView {
        case .first:
            secondViewHeightConstrint.constant = heigthConstraint
            secondView.alpha = heigthConstraint / 100
            thirdViewHeightConstraint.constant = heigthConstraint
            thirdView.alpha = heigthConstraint / 100
            self.view.layoutIfNeeded()
        case .second:
            firstViewHeightConstrint.constant = heigthConstraint
            firstView.alpha = heigthConstraint / 100
            thirdViewHeightConstraint.constant = heigthConstraint
            thirdView.alpha = heigthConstraint / 100
            self.view.layoutIfNeeded()
        case .third:
            firstViewHeightConstrint.constant = heigthConstraint
            firstView.alpha = heigthConstraint / 100
            secondViewHeightConstrint.constant = heigthConstraint
            secondView.alpha = heigthConstraint / 100
            self.view.layoutIfNeeded()
        case .none:
            return
        }
        
    }
    
    @IBAction func firstViewTapped(_ sender: Any) {
        selectedView = .first
    }
    
    @IBAction func secondViewTapped(_ sender: Any) {
        selectedView = .second
    }
    
    @IBAction func thridViewTapped(_ sender: Any) {
        selectedView = .third
    }
}

private extension ViewController {
    func compactView() {
        guard let selectedView = selectedView else { return }
         isViewCompact = true
        switch selectedView {
        case .first:
            hideView(view: secondView, constraint: secondViewHeightConstrint)
            hideView(view: thirdView, constraint: thirdViewHeightConstraint)
        case .second:
            hideView(view: firstView, constraint: firstViewHeightConstrint)
            hideView(view: thirdView, constraint: thirdViewHeightConstraint)
        case .third:
            hideView(view: firstView, constraint: firstViewHeightConstrint)
            hideView(view: secondView, constraint: secondViewHeightConstrint)
        }
        
        
    }
    
    func expandView() {
        isViewCompact = false
        showView(view: firstView, constraint: firstViewHeightConstrint)
        showView(view: secondView, constraint: secondViewHeightConstrint)
        showView(view: thirdView, constraint: thirdViewHeightConstraint)
    }
    
    func hideView(view: UIView, constraint: NSLayoutConstraint) {
        let duration = constraint.constant / 100 * 0.5
        UIView.animate(withDuration: Double(duration), delay: 0.0, options: [.curveEaseOut]) {
            constraint.constant = 0
            view.alpha = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func showView(view: UIView, constraint: NSLayoutConstraint) {
        let duration = (100 - constraint.constant) / 100 * 0.5
        UIView.animate(withDuration: Double(duration), delay: 0.0, options: [.curveEaseIn]) {
            constraint.constant = 100
            view.alpha = 1
            self.view.layoutIfNeeded()
        }
    }
}

enum SelectedView {
    case first, second, third
}
