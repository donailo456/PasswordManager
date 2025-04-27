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
    
    private var mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.backgroundColor = .systemGray
        stack.layoutMargins = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layer.cornerRadius = 16
        return stack
    }()
    
    private var userStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.backgroundColor = .systemGray
        stack.layer.cornerRadius = 16
        return stack
    }()
    
    private var passwordStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.backgroundColor = .systemGray
        stack.layer.cornerRadius = 16
        return stack
    }()
    
    private var phraseStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.backgroundColor = .systemGray
        stack.layer.cornerRadius = 16
        return stack
    }()
    
    private lazy var phraseLabel: UILabel = {
        let label = UILabel()
        label.text = "Фраза для запоминания:"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var phraseTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите фразу"
        textField.text = "A Muslim man dances with a pirate"
        textField.textAlignment = .left
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var phraseGenerationButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Сгенирирвоать", for: .normal)
        return button
    }()
    
    private var websiteStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.backgroundColor = .systemGray
        stack.layoutMargins = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layer.cornerRadius = 16
        return stack
    }()
    
    private lazy var websiteTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Сайт или заметка"
        textField.textAlignment = .left
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.backgroundColor = .red
        return imageView
    }()
    
    private lazy var userLabel: UILabel = {
        let label = UILabel()
        label.text = "Имя пользователя"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var userTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "имя пользователя"
        textField.textAlignment = .right
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var passwordLabel: UILabel = {
        let label = UILabel()
        label.text = "Пароль"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "пароль"
        textField.textAlignment = .right
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var helpPasswordButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "questionmark.circle"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private lazy var imageHint: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.backgroundColor = .red
        return imageView
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
        title = "Добавить пароль"
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
        guard let data = viewModel?.showingData() else { return }
        
        userTextField.text = data.website
        userTextField.isEnabled = true
        passwordTextField.text = data.website
        passwordTextField.isEnabled = true
        passwordTextField.isSecureTextEntry = true
    }
    
    func configure() {
        userStackView.addArrangedSubview(userLabel)
        userStackView.addArrangedSubview(userTextField)

        passwordStackView.addArrangedSubview(passwordLabel)
        passwordStackView.addArrangedSubview(helpPasswordButton)
        passwordStackView.addArrangedSubview(passwordTextField)
        
        phraseStackView.addArrangedSubview(phraseLabel)
        phraseStackView.addArrangedSubview(phraseGenerationButton)
        
        websiteStackView.addArrangedSubview(iconImageView)
        websiteStackView.addArrangedSubview(websiteTextField)
        
        view.addSubview(imageHint)
        view.addSubview(mainStackView)
        mainStackView.addArrangedSubview(websiteStackView)
        mainStackView.addArrangedSubview(phraseStackView)
        mainStackView.addArrangedSubview(phraseTextField)
        mainStackView.addArrangedSubview(userStackView)
        mainStackView.addArrangedSubview(passwordStackView)
    }
    
    func configureLayout() {
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            
            userStackView.heightAnchor.constraint(equalToConstant: 50),
            userLabel.trailingAnchor.constraint(equalTo: userTextField.leadingAnchor,
                                                constant: -12),
            
            passwordStackView.heightAnchor.constraint(equalToConstant: 50),
            passwordLabel.trailingAnchor.constraint(equalTo: helpPasswordButton.leadingAnchor,
                                                   constant: -5),
            helpPasswordButton.trailingAnchor.constraint(equalTo: passwordTextField.leadingAnchor,
                                                   constant: -12),
            
            phraseStackView.heightAnchor.constraint(equalToConstant: 50),
            phraseTextField.heightAnchor.constraint(equalToConstant: 40),
            
            websiteStackView.heightAnchor.constraint(equalToConstant: 100),
            iconImageView.widthAnchor.constraint(equalToConstant: 100 - 12 * 2),
            iconImageView.trailingAnchor.constraint(equalTo: websiteTextField.leadingAnchor, constant: -12),
        ])
        
        NSLayoutConstraint.activate([
            imageHint.widthAnchor.constraint(equalToConstant: view.bounds.width - 16 * 2),
            imageHint.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            imageHint.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            imageHint.topAnchor.constraint(equalTo: mainStackView.bottomAnchor, constant: 16),
            imageHint.heightAnchor.constraint(equalToConstant: view.bounds.height / 3),
        ])
    }
    
    func configureButton() {
        phraseGenerationButton.addTarget(self, action: #selector(phraseGenerationAction), for: .touchUpInside)
        helpPasswordButton.addTarget(self, action: #selector(helpPasswordAction), for: .touchUpInside)
    }
    
    @objc
    func addAction() {
        guard let website = websiteTextField.text,
              let login = userTextField.text,
              let password = passwordTextField.text,
              let phrase = phraseTextField.text else { return }
        viewModel?.saveData(website: website, login: login, password: password, phrase: phrase)
        navigationController?.dismiss(animated: true)
    }
    
    @objc
    func phraseGenerationAction() {
        guard let phrase = phraseTextField.text else { return }
        viewModel?.requestAIImage(phrase: phrase, completion: { [weak self] image in
            guard let self = self, let image = image else { return }
            imageHint.image = image
        })
    }
    
    @objc
    func helpPasswordAction() {
        let alertController = UIAlertController(title: "Помощь",
                                      message: "Помочь сгенирировать вам пароль, по вашей фразе?",
                                      preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "Да",
                                      style: .default,
                                      handler: { [weak self] _ in
            guard let self = self, let text = self.phraseTextField.text else { return }
            passwordTextField.text = self.viewModel?.algorithСreatingPassword(phrase: text)
        }))
        
        alertController.addAction(UIAlertAction(title: "Нет",
                                      style: .default,
                                      handler: { _ in
            print("Нажата кнопка NO")
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc
    func backAction() {
        navigationController?.dismiss(animated: true)
    }
}
