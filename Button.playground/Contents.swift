//: A UIKit based Playground for presenting user interface

import UIKit
import PlaygroundSupport

extension UIView {

    static func activate(constraints: [NSLayoutConstraint]) {
        constraints.forEach { ($0.firstItem as? UIView)?.translatesAutoresizingMaskIntoConstraints = false }
        NSLayoutConstraint.activate(constraints)
    }

    func center(in view: UIView, offset: UIOffset = .zero) {
        UIView.activate(constraints: [
            centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: offset.horizontal),
            centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: offset.vertical)
            ])
    }
}

class ReactiveButton: UIControl {

    private lazy var iconImageView: UIImageView = {
        let icon = UIImageView(image: nil)
        icon.tintColor = .clear
        return icon
    }()

    private var animator = UIViewPropertyAnimator()
    private let normalColor = UIColor.blue
    private let highlightedColor = UIColor.black

    enum IconName: String {
        case add
        case minus
    }

    private var tappedAction: () -> Void = {}

    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }

    convenience init(image: ReactiveButton.IconName, action: @escaping () -> Void) {
        self.init()
        iconImageView.image = UIImage(named: image.rawValue)
        iconImageView.image = iconImageView.image?.withRenderingMode(.alwaysTemplate)
        tappedAction = action
    }

    private func sharedInit() {
        backgroundColor = .gray

        addTarget(self, action: #selector(touchDown), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(touchUp), for: [.touchUpInside, .touchDragExit, .touchCancel])

        addSubview(iconImageView)
        iconImageView.center(in: self)
    }

    override var intrinsicContentSize: CGSize {
        let size = UIScreen.main.bounds
        return CGSize(width: size.width, height: size.height / 2)
    }

    func toggleIcon(isVisible: Bool) {
        iconImageView.tintColor = isVisible ? .blue : .clear
        print("is visible? \(isVisible) - selected color: \(iconImageView.tintColor!)")
    }

    @objc private func touchDown() {
        animator.stopAnimation(true)
        iconImageView.tintColor = highlightedColor
    }

    @objc private func touchUp() {
        animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut, animations: {
            self.iconImageView.tintColor = self.normalColor
        })
        animator.startAnimation()
        tappedAction()
    }

}

class MyViewController : UIViewController {

    private var stickerAmount = 0

    private lazy var addButton: ReactiveButton = ReactiveButton(image: .add) { [weak self] in
        self?.addSticker()
    }

    private lazy var minusButton: ReactiveButton = ReactiveButton(image: .minus) { [weak self] in
        self?.removeSticker()
    }

    private lazy var containerStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [addButton, minusButton])
        minusButton.isHidden = true
        minusButton.alpha = 0
        stack.distribution = .fillEqually
        stack.axis = .vertical
        stack.spacing = 2
        return stack
    }()

    override func loadView() {
        let view = UIView()
        view.backgroundColor = .black
        view.addSubview(containerStackView)
        containerStackView.center(in: view)
        self.view = view
    }

    private func addSticker() {
        stickerAmount+=1
        print("sticker amount: \(stickerAmount)")
        if stickerAmount == 1 {
            animateContainer()
        }
    }

    private func removeSticker() {
        guard stickerAmount >= 1 else { return }
        stickerAmount-=1
        print("sticker amount: \(stickerAmount)")
        if stickerAmount == 0 {
            animateContainer()
        }
    }

    private func animateContainer() {
        UIView.animate(withDuration: 0.25) {
            self.addButton.toggleIcon(isVisible: self.stickerAmount >= 1)
            self.minusButton.toggleIcon(isVisible: self.stickerAmount >= 1)
            self.minusButton.alpha = self.stickerAmount >= 1 ? 1 : 0
            self.minusButton.isHidden = self.stickerAmount < 1
            self.containerStackView.layoutIfNeeded()
        }
    }
}

PlaygroundPage.current.liveView = MyViewController()
//PlaygroundPage.current.needsIndefiniteExecution = true
