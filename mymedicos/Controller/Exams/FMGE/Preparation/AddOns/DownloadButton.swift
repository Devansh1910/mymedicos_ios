import UIKit

class DownloadButton: UIView {
    private let titleLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let checkmarkImageView = UIImageView()
    private let lockImageView = UIImageView()

    enum State {
        case normal
        case loading
        case completed
        case locked
    }

    var currentState: State = .normal {
        didSet {
            updateState()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        self.layer.cornerRadius = 10
        self.backgroundColor = .darkGray

        titleLabel.text = "Download"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        activityIndicator.color = .white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.isHidden = true

        checkmarkImageView.image = UIImage(systemName: "checkmark")
        checkmarkImageView.tintColor = .white
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        checkmarkImageView.isHidden = true

        lockImageView.image = UIImage(systemName: "lock.fill")
        lockImageView.tintColor = .white
        lockImageView.translatesAutoresizingMaskIntoConstraints = false
        lockImageView.isHidden = true

        self.addSubview(titleLabel)
        self.addSubview(activityIndicator)
        self.addSubview(checkmarkImageView)
        self.addSubview(lockImageView)

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor),

            checkmarkImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            checkmarkImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 24),

            lockImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            lockImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            lockImageView.widthAnchor.constraint(equalToConstant: 24),
            lockImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

    private func updateState() {
        switch currentState {
        case .normal:
            titleLabel.isHidden = false
            activityIndicator.isHidden = true
            checkmarkImageView.isHidden = true
            lockImageView.isHidden = true
        case .loading:
            titleLabel.isHidden = true
            activityIndicator.isHidden = false
            checkmarkImageView.isHidden = true
            lockImageView.isHidden = true
            activityIndicator.startAnimating()
        case .completed:
            titleLabel.isHidden = true
            activityIndicator.isHidden = true
            checkmarkImageView.isHidden = false
            lockImageView.isHidden = true
            activityIndicator.stopAnimating()
        case .locked:
            titleLabel.isHidden = true
            activityIndicator.isHidden = true
            checkmarkImageView.isHidden = true
            lockImageView.isHidden = false
            activityIndicator.stopAnimating()
        }
    }

    func startLoading() {
        currentState = .loading
    }

    func completeLoading() {
        currentState = .completed
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.currentState = .normal
        }
    }

    func lockButton() {
        currentState = .locked
    }
}
