import UIKit


public extension UICollectionView {
    func registerNibCell(_ cell: UICollectionViewCell.Type) {
        let nib = UINib(nibName: cell.name, bundle: nil)
        register(nib, forCellWithReuseIdentifier: cell.name)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.name, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.name)")
        }
        
        return cell
    }
}

public extension UIView {
    /// The name of view as String
    static var name: String {
        return String(describing: self)
    }
}
