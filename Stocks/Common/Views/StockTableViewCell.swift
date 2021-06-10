//
//  StockTableViewCell.swift
//  Stocks
//
//  Created by Никита Гусев on 08.06.2021.
//

import UIKit
import SnapKit

protocol IStockTableCell: class {
    var favouriteButtonTapHandler: (() -> Void)? { get set }
    
    func setLogoImage(_ image: UIImage)
    func setTicker(_ ticker: String)
    func setCompanyName(_ companyName: String)
    func setPrice(_ price: String)
    func setDelta(_ delta: String, increased: Bool)
    func setFavouriteButtonImage(_ image: UIImage)
    func setBackgroundColor(_ color: UIColor)
}

class StockTableViewCell: UITableViewCell {
    static let identifier = "StockTableViewCell"
    
    var favouriteButtonTapHandler: (() -> Void)?
    
    private let logoImageView = UIImageView()
    private let tickerLabel = UILabel()
    private let companyNameLabel = UILabel()
    private let priceLabel = UILabel()
    private let deltaLabel = UILabel()
    private let favouriteButton = UIButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        self.contentView.layer.cornerRadius = 10
    }
}

extension StockTableViewCell: IStockTableCell {
    func setLogoImage(_ image: UIImage) {
        self.logoImageView.image = image
    }
    
    func setTicker(_ ticker: String) {
        self.tickerLabel.text = ticker
    }
    
    func setCompanyName(_ companyName: String) {
        self.companyNameLabel.text = companyName
    }
    
    func setPrice(_ price: String) {
        self.priceLabel.text = price
    }
    
    func setDelta(_ delta: String, increased: Bool) {
        self.deltaLabel.text = delta
        let greenColor = UIColor(red: 35 / 255.0, green: 175 / 255.0, blue: 86 / 255.0, alpha: 1.0)
        self.deltaLabel.textColor = increased ? greenColor : .red
    }
    
    func setFavouriteButtonImage(_ image: UIImage) {
        self.favouriteButton.setBackgroundImage(image, for: .normal)
    }
    
    func setBackgroundColor(_ color: UIColor) {
        self.contentView.backgroundColor = color
    }
}

private extension StockTableViewCell {
    func configureView() {
        self.selectionStyle = .none
        self.addSubviews()
        self.configureLogoImageView()
        self.configureTickerLabel()
        self.configureCompanyNameLabel()
        self.configurePriceLabel()
        self.configureDeltaLabel()
        self.configureFavouriteButton()
    }
    
    func addSubviews() {
        self.contentView.addSubview(self.logoImageView)
        self.contentView.addSubview(self.tickerLabel)
        self.contentView.addSubview(self.companyNameLabel)
        self.contentView.addSubview(self.priceLabel)
        self.contentView.addSubview(self.deltaLabel)
        self.contentView.addSubview(self.favouriteButton)
    }
    
    func configureLogoImageView() {
        self.logoImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(50)
        }
        self.logoImageView.layer.cornerRadius = 10
        self.logoImageView.clipsToBounds = true
    }
    
    func configureTickerLabel() {
        self.tickerLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.equalTo(self.logoImageView.snp.right).offset(10)
        }
        self.tickerLabel.font = .systemFont(ofSize: 16, weight: .bold)
        self.tickerLabel.textColor = .black
    }
    
    func configureCompanyNameLabel() {
        self.companyNameLabel.snp.makeConstraints { make in
            make.top.equalTo(self.tickerLabel.snp.bottom).offset(7)
            make.left.equalTo(self.logoImageView.snp.right).offset(10)
        }
        self.companyNameLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        self.companyNameLabel.textColor = .black
    }
    
    func configurePriceLabel() {
        self.priceLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-15)
        }
        self.priceLabel.font = .systemFont(ofSize: 16, weight: .bold)
        self.priceLabel.textColor = .black
    }
    
    func configureDeltaLabel() {
        self.deltaLabel.snp.makeConstraints { make in
            make.top.equalTo(self.priceLabel.snp.bottom).offset(10)
            make.right.equalToSuperview().offset(-15)
        }
        self.deltaLabel.font = .systemFont(ofSize: 13, weight: .semibold)
    }
    
    func configureFavouriteButton() {
        self.favouriteButton.snp.makeConstraints { make in
            make.top.equalTo(self.tickerLabel)
            make.bottom.equalTo(self.tickerLabel)
            make.left.equalTo(self.tickerLabel.snp.right).offset(8)
            make.width.equalTo(21)
        }
        self.favouriteButton.addTarget(self,
                                         action: #selector(self.favouriteButtonPressed),
                                         for: .touchUpInside)
    }
    
    @objc func favouriteButtonPressed() {
        self.favouriteButtonTapHandler?()
    }
}
