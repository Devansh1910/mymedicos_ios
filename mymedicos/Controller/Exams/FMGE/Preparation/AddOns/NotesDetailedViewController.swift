import UIKit
import PDFKit

class NoteDetailPopupViewController: UIViewController {
    private var note: Note
    
    private let popupView = UIView()
    private let titleLabel = UILabel()
    private var pdfView = PDFView()
    private let descriptionLabel = UILabel()
    private let downloadButton = DownloadButton()
    private let closeButton = UIButton(type: .system)
    private let previewBannerLabel = UILabel()  // Banner label

    init(note: Note) {
        self.note = note
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupViews()
        loadPDF()
        updateDownloadButtonState()
    }

    private func setupNavigationBar() {
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.black,
            .font: UIFont.boldSystemFont(ofSize: 18)
        ]
        
        navigationItem.title = note.title
        
        let closeButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(closeButtonTapped))
        closeButton.tintColor = .darkGray
        navigationItem.leftBarButtonItem = closeButton
    }

    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }

    private func setupViews() {
        view.backgroundColor = UIColor.white  // Background color for the main view

        // Popup View
        popupView.backgroundColor = .white  // Ensuring popup view is white
        popupView.layer.cornerRadius = 12
        popupView.layer.masksToBounds = true
        popupView.translatesAutoresizingMaskIntoConstraints = false

        // PDF View
        pdfView.backgroundColor = UIColor(hex: "#E5E5E5")  // Explicitly setting PDFView's background to the custom color
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .horizontal
        pdfView.autoScales = true
        pdfView.usePageViewController(true, withViewOptions: [UIPageViewController.OptionsKey.interPageSpacing: 20])
        pdfView.isUserInteractionEnabled = true

        // Description Label
        descriptionLabel.attributedText = convertHTMLToAttributedString(html: note.description)
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textColor = .darkGray
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.backgroundColor = .white  // Ensuring the background of the label is white

        // Download Button
        downloadButton.translatesAutoresizingMaskIntoConstraints = false
        downloadButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(downloadButtonTapped)))

        // Add all subviews to popupView
        view.addSubview(popupView)
        popupView.addSubview(titleLabel)
        popupView.addSubview(pdfView)
        popupView.addSubview(descriptionLabel)
        popupView.addSubview(downloadButton)
        view.addSubview(closeButton)  // Added directly to the main view

        previewBannerLabel.text = "Preview"
        previewBannerLabel.textColor = .white
        previewBannerLabel.backgroundColor = .darkGray
        previewBannerLabel.font = UIFont.boldSystemFont(ofSize: 12)
        previewBannerLabel.textAlignment = .center
        previewBannerLabel.layer.cornerRadius = 5
        previewBannerLabel.clipsToBounds = true
        previewBannerLabel.translatesAutoresizingMaskIntoConstraints = false
        pdfView.addSubview(previewBannerLabel)

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            popupView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            popupView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            popupView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            popupView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            titleLabel.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -20),

            pdfView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            pdfView.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 20),
            pdfView.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -20),
            pdfView.heightAnchor.constraint(equalToConstant: 300), // Adjust height as needed

            descriptionLabel.topAnchor.constraint(equalTo: pdfView.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -20),

            downloadButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10),
            downloadButton.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 20),
            downloadButton.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -20),
            downloadButton.heightAnchor.constraint(equalToConstant: 50),
            downloadButton.bottomAnchor.constraint(equalTo: popupView.bottomAnchor, constant: -20),
            
            previewBannerLabel.topAnchor.constraint(equalTo: pdfView.topAnchor, constant: 10),  // Vertical padding
            previewBannerLabel.trailingAnchor.constraint(equalTo: pdfView.trailingAnchor, constant: -10),  // Horizontal padding
            previewBannerLabel.widthAnchor.constraint(equalToConstant: 60),  // Adjust the width as necessary
            previewBannerLabel.heightAnchor.constraint(equalToConstant: 20)   // Adjust the height as necessary
        ])
    }

    private func convertHTMLToAttributedString(html: String) -> NSAttributedString? {
        let modifiedFont = """
        <style>
            body { font-family: '-apple-system', 'HelveticaNeue'; font-size: 14px; color: #242424; }
        </style>
        <div>\(html)</div>
        """

        guard let data = modifiedFont.data(using: .utf8) else {
            print("Unable to encode HTML string.")
            return nil
        }

        do {
            return try NSAttributedString(
                data: data,
                options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue],
                documentAttributes: nil)
        } catch {
            print("Error converting HTML to NSAttributedString: \(error)")
            return nil
        }
    }

    private func loadPDF() {
        guard let url = URL(string: note.previewURL) else {
            print("Invalid file URL")
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            if let document = PDFDocument(url: url) {
                DispatchQueue.main.async {
                    self.pdfView.document = document
                }
            } else {
                print("Failed to load document")
            }
        }
    }

    private func updateDownloadButtonState() {
        // Check if the note is locked
        if note.type != "BASIC" {
            downloadButton.lockButton()
        }
    }

    @objc private func downloadButtonTapped() {
        guard note.type == "BASIC" else {
            showUpgradeAlert(for: note.type)
            return
        }

        guard let url = URL(string: note.fileURL) else {
            print("Invalid file URL")
            return
        }

        downloadButton.startLoading()

        downloadFile(from: url)
    }

    private func downloadFile(from url: URL) {
        let task = URLSession.shared.downloadTask(with: url) { localURL, response, error in
            guard let localURL = localURL, error == nil else {
                DispatchQueue.main.async {
                    self.showToast(message: "Download failed: \(error?.localizedDescription ?? "Unknown error")")
                    self.downloadButton.currentState = .normal
                }
                return
            }
            
            do {
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let destinationURL = documentsURL.appendingPathComponent(url.lastPathComponent)
                
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.removeItem(at: destinationURL)
                }
                
                try FileManager.default.moveItem(at: localURL, to: destinationURL)
                
                DispatchQueue.main.async {
                    self.downloadButton.completeLoading()
                    self.showDownloadCompleteAlert(for: destinationURL)
                }
            } catch {
                DispatchQueue.main.async {
                    self.showToast(message: "File move error: \(error.localizedDescription)")
                    self.downloadButton.currentState = .normal
                }
            }
        }
        task.resume()
    }

    private func showUpgradeAlert(for type: String) {
        let alert = UIAlertController(title: "Upgrade Required",
                                      message: "This content is part of the \(type) plan. Please upgrade to access it.",
                                      preferredStyle: .alert)
        alert.overrideUserInterfaceStyle = .light
        alert.addAction(UIAlertAction(title: "Upgrade", style: .default, handler: { _ in
            // Handle upgrade action
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }

    private func showToast(message: String) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75,
                                               y: self.view.frame.size.height-100,
                                               width: 150,
                                               height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 14)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        self.view.addSubview(toastLabel)

        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: { _ in
            toastLabel.removeFromSuperview()
        })
    }

    private func showDownloadCompleteAlert(for fileURL: URL) {
        let alert = UIAlertController(title: "Download Complete",
                                      message: "The file has been downloaded. Would you like to open it?",
                                      preferredStyle: .alert)
        
        // Force the alert to use light mode
        alert.overrideUserInterfaceStyle = .light
        
        alert.addAction(UIAlertAction(title: "Open", style: .default, handler: { _ in
            self.openDownloadedFile(at: fileURL)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }

    private func openDownloadedFile(at fileURL: URL) {
        let documentInteractionController = UIDocumentInteractionController(url: fileURL)
        documentInteractionController.delegate = self
        documentInteractionController.presentPreview(animated: true)
    }
}

extension NoteDetailPopupViewController: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}
