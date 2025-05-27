//
//  AddingPasswordViewController.swift
//  PasswordManager
//
//  Created by Komarov Danil on 09.03.2025.
//

import UIKit

final class AddingPasswordViewController: UIViewController {
    
    //MARK: - Properties
    
    var viewModel: AddingPasswordViewModel?
    
    //MARK: - Private properties
    
    private lazy var phraseLabel: UILabel = {
        let label = UILabel()
        label.text = "Фраза для запоминания:"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var phraseTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите фразу"
        textField.textAlignment = .left
        textField.textColor = .black
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var phraseGenerationButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 5
        button.backgroundColor = .systemBlue
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.setTitle("Сгенерировать", for: .normal)
        return button
    }()
    
    private lazy var websiteTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Сайт или заметка"
        textField.textAlignment = .left
        textField.textColor = .black
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var wordsLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = .darkGray
        label.layer.cornerRadius = 16
        label.clipsToBounds = true
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var userLabel: UILabel = {
        let label = UILabel()
        label.text = "Имя пользователя"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var userTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "имя пользователя"
        textField.textAlignment = .right
        textField.textColor = .black
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var passwordLabel: UILabel = {
        let label = UILabel()
        label.text = "Пароль"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "пароль"
        textField.textAlignment = .right
        textField.textColor = .black
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var helpPasswordButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "questionmark.circle"), for: .normal)
        button.tintColor = .systemBlue
        return button
    }()
    
    private lazy var imageHint: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "default_product_image")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.color = .gray
        indicator.isHidden = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private lazy var editButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 5
        button.backgroundColor = .systemBlue
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitle("Изменить", for: .normal)
        return button
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 5
        button.backgroundColor = .systemRed
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitle("Удалить", for: .normal)
        return button
    }()
    
    private let topSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let middleSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let bottomSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var settingView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        view.layer.cornerRadius = 8
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var lettersToggle: UISwitch = {
        let control = UISwitch()
        control.translatesAutoresizingMaskIntoConstraints = false
        control.isOn = true
        return control
    }()
    
    private lazy var randomDigitsToggle: UISwitch = {
        let control = UISwitch()
        control.translatesAutoresizingMaskIntoConstraints = false
        control.isOn = true
        return control
    }()
    
    private lazy var lettersLabel: UILabel = {
        let label = UILabel()
        label.text = "Символы"
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var randomDigitsLabel: UILabel = {
        let label = UILabel()
        label.text = "Цифры"
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var passGenerationButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 5
        button.backgroundColor = .systemBlue
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.setTitle("Сгенерировать", for: .normal)
        return button
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureNavigationBar()
        configure()
        configureLayout()
        configureButton()
        showingData()
    }
}

private extension AddingPasswordViewController {
    
    //MARK: - Private function
    
    func configureNavigationBar() {
        let addButton = UIBarButtonItem(image: UIImage(named: "ico_add_button"),
                                    style: .plain,
                                    target: self, action: #selector(addAction))
        addButton.tintColor = .black
        
        let backButton = UIBarButtonItem(title: "Назад",
                                         style: .plain,
                                         target: self,
                                         action: #selector(backAction))

        navigationItem.rightBarButtonItem = addButton
        navigationItem.leftBarButtonItem = backButton
    }
    
    func showingData() {
        guard let data = viewModel?.model else { return }
        
        websiteTextField.text = data.website
        userTextField.text = data.encryptedLogin
        userTextField.isEnabled = false
        passwordTextField.text = data.encryptedPassword
        passwordTextField.isEnabled = false
        phraseTextField.text = data.encryptedPhrase
        phraseTextField.isEnabled = false
        editButton.isHidden = false
        deleteButton.isHidden = false
        phraseGenerationButton.isEnabled = false
        passwordTextField.isSecureTextEntry = true
        
        if let imageFileName = data.imageFileName, let image = viewModel?.showImage(imageFileName: imageFileName) {
            imageHint.image = image
        }
    }
    
    func configure() {
        view.addSubview(wordsLabel)
        view.addSubview(websiteTextField)
        
        view.addSubview(phraseLabel)
        view.addSubview(phraseGenerationButton)
        view.addSubview(phraseTextField)
        
        view.addSubview(userLabel)
        view.addSubview(userTextField)
        
        view.addSubview(passwordLabel)
        view.addSubview(passwordTextField)
        view.addSubview(helpPasswordButton)
        
        view.addSubview(imageHint)
        view.addSubview(editButton)
        view.addSubview(deleteButton)
        
        view.addSubview(topSeparator)
        view.addSubview(middleSeparator)
        view.addSubview(bottomSeparator)
        imageHint.addSubview(activityIndicator)
        
        websiteTextField.addTarget(self, action: #selector(changeWord(sender:)), for: .editingChanged)
    }
    
    func configureLayout() {
        NSLayoutConstraint.activate([
            wordsLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            wordsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            wordsLabel.widthAnchor.constraint(equalToConstant: 60),
            wordsLabel.heightAnchor.constraint(equalToConstant: 60),
            
            websiteTextField.centerYAnchor.constraint(equalTo: wordsLabel.centerYAnchor),
            websiteTextField.leadingAnchor.constraint(equalTo: wordsLabel.trailingAnchor, constant: 16),
            websiteTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            topSeparator.topAnchor.constraint(equalTo: wordsLabel.bottomAnchor, constant: 16),
            topSeparator.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            topSeparator.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            topSeparator.heightAnchor.constraint(equalToConstant: 0.5),
            
            phraseLabel.topAnchor.constraint(equalTo: topSeparator.bottomAnchor, constant: 16),
            phraseLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            
            phraseGenerationButton.centerYAnchor.constraint(equalTo: phraseLabel.centerYAnchor),
            phraseGenerationButton.leadingAnchor.constraint(equalTo: phraseLabel.trailingAnchor, constant: 32),
            phraseGenerationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            phraseGenerationButton.heightAnchor.constraint(equalToConstant: 20),
            
            phraseTextField.topAnchor.constraint(equalTo: phraseLabel.bottomAnchor, constant: 16),
            phraseTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            phraseTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            
            middleSeparator.topAnchor.constraint(equalTo: phraseTextField.bottomAnchor, constant: 16),
            middleSeparator.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            middleSeparator.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            middleSeparator.heightAnchor.constraint(equalToConstant: 0.5),
            
            userLabel.topAnchor.constraint(equalTo: middleSeparator.bottomAnchor, constant: 16),
            userLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            
            userTextField.topAnchor.constraint(equalTo:  middleSeparator.bottomAnchor, constant: 16),
            userTextField.leadingAnchor.constraint(equalTo:  userLabel.trailingAnchor, constant: 8),
            userTextField.trailingAnchor.constraint(equalTo:  view.trailingAnchor, constant: -32),
            
            bottomSeparator.topAnchor.constraint(equalTo: userLabel.bottomAnchor, constant: 16),
            bottomSeparator.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            bottomSeparator.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            bottomSeparator.heightAnchor.constraint(equalToConstant: 0.5),
            
            passwordLabel.topAnchor.constraint(equalTo: bottomSeparator.bottomAnchor, constant: 16),
            passwordLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            
            helpPasswordButton.centerYAnchor.constraint(equalTo: passwordLabel.centerYAnchor),
            helpPasswordButton.leadingAnchor.constraint(equalTo:  passwordLabel.trailingAnchor, constant: 5),
            
            passwordTextField.topAnchor.constraint(equalTo:  bottomSeparator.bottomAnchor, constant: 16),
            passwordTextField.leadingAnchor.constraint(equalTo:  helpPasswordButton.leadingAnchor, constant: 32),
            passwordTextField.trailingAnchor.constraint(equalTo:  view.trailingAnchor, constant: -32),
        ])
        
        NSLayoutConstraint.activate([
            imageHint.widthAnchor.constraint(equalToConstant: view.bounds.width - 16 * 2),
            imageHint.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            imageHint.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            imageHint.topAnchor.constraint(equalTo: editButton.bottomAnchor, constant: 16),
            imageHint.heightAnchor.constraint(equalToConstant: view.bounds.height / 3),
            
            activityIndicator.heightAnchor.constraint(equalToConstant: 25),
            activityIndicator.widthAnchor.constraint(equalToConstant: 25),
            activityIndicator.centerXAnchor.constraint(equalTo: imageHint.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: imageHint.centerYAnchor),
            
            editButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 16),
            editButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            editButton.widthAnchor.constraint(equalToConstant: view.bounds.width / 3),
            
            deleteButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 16),
            deleteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            deleteButton.widthAnchor.constraint(equalToConstant: view.bounds.width / 3),
        ])
    }
    
    func configureButton() {
        phraseGenerationButton.addTarget(self, action: #selector(phraseGenerationAction), for: .touchUpInside)
        helpPasswordButton.addTarget(self, action: #selector(helpPasswordAction), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(editAction(sender:)), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
        passGenerationButton.addTarget(self, action: #selector(passGenerationAction), for: .touchUpInside)
    }
    
    @objc
    func addAction() {
        guard let website = websiteTextField.text,
              let login = userTextField.text,
              let password = passwordTextField.text
        else { return }
        
        viewModel?.saveData(website: website, login: login, password: password, phrase: phraseTextField.text, image: imageHint.image)
        navigationController?.dismiss(animated: true)
    }
    
    @objc
    func phraseGenerationAction() {
        if let phrase = phraseTextField.text, !phrase.isEmpty {
            requestImage(phrase: phrase)
        } else {
            guard let generatePhrase = viewModel?.generateLocalMnemonicPhrase() else { return }
            phraseTextField.text = generatePhrase
            passwordTextField.text = self.viewModel?.generatePassword(from: generatePhrase)
            requestImage(phrase: generatePhrase)
        }
    }
    
    @objc
    func editAction(sender: UIButton) {
        if sender.titleLabel?.text == "Изменить" {
            editButton.setTitle("Сохранить", for: .normal)
            userTextField.isEnabled = true
            passwordTextField.isEnabled = true
            phraseGenerationButton.isEnabled = true
            passwordTextField.isSecureTextEntry = false
        } else {
            editButton.setTitle("Изменить", for: .normal)
            userTextField.isEnabled = false
            passwordTextField.isEnabled = false
            phraseGenerationButton.isEnabled = false
            passwordTextField.isSecureTextEntry = true
        }
    }
    
    @objc
    func deleteAction() {
        viewModel?.deleteRecord()
        navigationController?.dismiss(animated: true)
    }
    
    @objc
    func helpPasswordAction() {
        configureSettingView()
        
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.5,
                       options: []) { [weak self] in
            self?.settingView.transform = .identity
            self?.settingView.alpha = 1
        }
    }
    
    // TODO: - Сделать как отдельное вью и передавать данные делегатом
    
    func configureSettingView() {
        view.addSubview(settingView)
        settingView.addSubview(lettersToggle)
        settingView.addSubview(lettersLabel)
        settingView.addSubview(randomDigitsToggle)
        settingView.addSubview(randomDigitsLabel)
        settingView.addSubview(passGenerationButton)
        
        NSLayoutConstraint.activate([
            settingView.bottomAnchor.constraint(equalTo: helpPasswordButton.topAnchor, constant: -10), // Появляется над кнопкой
            settingView.centerXAnchor.constraint(equalTo: helpPasswordButton.centerXAnchor),
            settingView.widthAnchor.constraint(equalToConstant: 150),
            settingView.heightAnchor.constraint(equalToConstant: 150),
            
            lettersLabel.topAnchor.constraint(equalTo: settingView.topAnchor, constant: 16),
            lettersLabel.leadingAnchor.constraint(equalTo: settingView.leadingAnchor, constant: 5),

            lettersToggle.centerYAnchor.constraint(equalTo: lettersLabel.centerYAnchor),
            lettersToggle.trailingAnchor.constraint(equalTo: settingView.trailingAnchor, constant: -5),
            
            randomDigitsLabel.topAnchor.constraint(equalTo: lettersLabel.bottomAnchor, constant: 32),
            randomDigitsLabel.leadingAnchor.constraint(equalTo: settingView.leadingAnchor, constant: 5),

            randomDigitsToggle.centerYAnchor.constraint(equalTo: randomDigitsLabel.centerYAnchor),
            randomDigitsToggle.trailingAnchor.constraint(equalTo: settingView.trailingAnchor, constant: -5),
            
            passGenerationButton.leadingAnchor.constraint(equalTo: settingView.leadingAnchor, constant: 16),
            passGenerationButton.trailingAnchor.constraint(equalTo: settingView.trailingAnchor, constant: -16),
            passGenerationButton.bottomAnchor.constraint(equalTo: settingView.bottomAnchor, constant: -16),
        ])
        
        settingView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        settingView.alpha = 0
    }
    
    @objc
    func passGenerationAction() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.settingView.alpha = 0
        } completion: { [weak self] _ in
            self?.settingView.removeFromSuperview()
        }
        
        guard let text = self.phraseTextField.text else { return }
        passwordTextField.text = self.viewModel?.generatePassword(from: text,
                                                                  replaceLetters: lettersToggle.isOn,
                                                                  useRandomDigits: randomDigitsToggle.isOn)
    }
    
    @objc
    func backAction() {
        navigationController?.dismiss(animated: true)
    }
    
    @objc
    func changeWord(sender: UITextField) {
        guard let text = sender.text else { return }
        
        if let word = text.first?.description {
            wordsLabel.text = word
        } else {
            wordsLabel.text = ""
        }
    }
    
    func requestImage(phrase: String) {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        viewModel?.requestAIImage(phrase: phrase, completion: { [weak self] image in
            guard let self = self, let image = image else { return }
            imageHint.image = image
            activityIndicator.stopAnimating()
        })
    }
}
