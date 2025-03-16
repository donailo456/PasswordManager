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
        stack.layer.cornerRadius = 16
        return stack
    }()
    
    private var userStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.backgroundColor = .systemGray
        stack.layoutMargins = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layer.cornerRadius = 16
        return stack
    }()
    
    private var passwordStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.backgroundColor = .systemGray
        stack.layoutMargins = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layer.cornerRadius = 16
        return stack
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureNavigationBar()
        configure()
        configureLayout()
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
    
    func configure() {
        userStackView.addArrangedSubview(userLabel)
        userStackView.addArrangedSubview(userTextField)

        passwordStackView.addArrangedSubview(passwordLabel)
        passwordStackView.addArrangedSubview(passwordTextField)
        
        view.addSubview(mainStackView)
        mainStackView.addArrangedSubview(userStackView)
        mainStackView.addArrangedSubview(passwordStackView)
    }
    
    func configureLayout() {
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            mainStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            userStackView.heightAnchor.constraint(equalToConstant: 50),
            userLabel.trailingAnchor.constraint(equalTo: userTextField.leadingAnchor,
                                                constant: -12),
            
            passwordStackView.heightAnchor.constraint(equalToConstant: 50),
            passwordLabel.trailingAnchor.constraint(equalTo: passwordTextField.leadingAnchor,
                                                   constant: -12),
        ])
    }
    
    @objc
    func addAction() {
        guard let user = userTextField.text, let password = passwordTextField.text else { return }
        viewModel?.requestInfo(user: user, password: password)
        navigationController?.dismiss(animated: true)
    }
    
    @objc
    func backAction() {
        navigationController?.dismiss(animated: true)
    }
}
