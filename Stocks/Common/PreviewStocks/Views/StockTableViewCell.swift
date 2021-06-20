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
    func setDelta(_ delta: String)
    func setFavouriteButtonImage(_ image: UIImage)
    func setBackgroundColor(_ color: UIColor)
    func setDeltaColor(_ color: UIColor)
}

class StockTableViewCell: UITableViewCell {
    static let identifier = PreviewConstants.cellIdentifier
    
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
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.frame = contentView.frame.inset(by: PreviewConstants.cellInsets)
        self.contentView.layer.cornerRadius = PreviewConstants.cellCornerRadius
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
    
    func setDelta(_ delta: String) {
        self.deltaLabel.text = delta
    }
    
    func setFavouriteButtonImage(_ image: UIImage) {
        self.favouriteButton.setBackgroundImage(image, for: .normal)
    }
    
    func setBackgroundColor(_ color: UIColor) {
        self.contentView.backgroundColor = color
    }
    
    func setDeltaColor(_ color: UIColor) {
        self.deltaLabel.textColor = color
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
        self.logoImageView.translatesAutoresizingMaskIntoConstraints = false
        self.logoImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(50)
        }
        self.logoImageView.layer.cornerRadius = PreviewConstants.cellLogoImageCornerRadius
        self.logoImageView.clipsToBounds = true
    }
    
    func configureTickerLabel() {
        self.tickerLabel.translatesAutoresizingMaskIntoConstraints = false
        self.tickerLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.equalTo(self.logoImageView.snp.right).offset(10)
        }
        self.tickerLabel.font = PreviewConstants.cellTickerFont
        self.tickerLabel.textColor = PreviewConstants.cellTickerTextColor
    }
    
    func configureCompanyNameLabel() {
        self.companyNameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.companyNameLabel.snp.makeConstraints { make in
            make.top.equalTo(self.tickerLabel.snp.bottom).offset(7)
            make.left.equalTo(self.logoImageView.snp.right).offset(10)
            make.right.equalTo(self.deltaLabel.snp.left).offset(-5)
        }
        self.companyNameLabel.font = PreviewConstants.cellCompanyFont
        self.companyNameLabel.textColor = PreviewConstants.cellCompanyTextColor
    }
    
    func configurePriceLabel() {
        self.priceLabel.translatesAutoresizingMaskIntoConstraints = false
        self.priceLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-15)
        }
        self.priceLabel.font = PreviewConstants.cellPriceFont
        self.priceLabel.textColor = PreviewConstants.cellPriceTextColor
    }
    
    func configureDeltaLabel() {
        self.deltaLabel.translatesAutoresizingMaskIntoConstraints = false
        self.deltaLabel.snp.makeConstraints { make in
            make.top.equalTo(self.priceLabel.snp.bottom).offset(10)
            make.right.equalToSuperview().offset(-15)
            make.width.equalTo(50)
        }
        self.deltaLabel.font = PreviewConstants.cellDeltaFont
        self.deltaLabel.textAlignment = .right
    }
    
    func configureFavouriteButton() {
        self.favouriteButton.translatesAutoresizingMaskIntoConstraints = false
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
