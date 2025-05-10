//
//  TaskCell.swift
//  MyOwnToDoList
//
//  Created by Никита Журавлев on 08.05.2025.
//

import UIKit

protocol TaskCellDelegate: AnyObject{
    func didToggleCompletion(in cell: TaskCell)
}

class TaskCell: UITableViewCell{
    
    //MARK: - Varibales
    weak var delegate: TaskCellDelegate?
    
    
    //Set circle button
    let circleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("○", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //Set label
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var isCompleted: Bool = false{
        didSet{
            let symbol = isCompleted ? "●" : "○"
            circleButton.setTitle(symbol, for: .normal)
            titleLabel.textColor = isCompleted ? .secondaryLabel : .label
        }
    }
    
    //MARK: - Functions
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(circleButton)
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            circleButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            circleButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            circleButton.widthAnchor.constraint(equalToConstant: 30),
            circleButton.heightAnchor.constraint(equalToConstant: 30),
            
            titleLabel.leadingAnchor.constraint(equalTo: circleButton.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
        
        circleButton.addTarget(self, action: #selector(didTapCircle), for: .touchUpInside)
    }
    
    @objc func didTapCircle(){
        delegate?.didToggleCompletion(in: self)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
