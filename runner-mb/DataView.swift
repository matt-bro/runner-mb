//MIT License
//
//Copyright (c) 2020 Matthias Brodalka
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.

import UIKit
import SnapKit

class DataView: UIView {

    var iconIv: UIImageView?
    var valueLabel: UILabel?
    var unitLabel: UILabel?


    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = .systemBackground
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.translatesAutoresizingMaskIntoConstraints = false

        let iconIv = UIImageView(frame: .zero)
        self.addSubview(iconIv)
        iconIv.snp.makeConstraints({ make in
            make.width.height.equalTo(35)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(15)
        })
        self.iconIv = iconIv


        let valueLabel = UILabel(frame: .zero)
        valueLabel.font = .large
        valueLabel.text = "1000"
        valueLabel.textAlignment = .center
        valueLabel.textColor = .systemGray
        self.addSubview(valueLabel)
        valueLabel.snp.makeConstraints({ make in
            make.width.equalToSuperview()
            make.top.equalTo(iconIv.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        })
        self.valueLabel = valueLabel

        let unitLabel = UILabel(frame: .zero)
        unitLabel.font = .small
        unitLabel.text = "unit"
        unitLabel.textAlignment = .center
        unitLabel.textColor = .systemGray
        self.addSubview(unitLabel)
        unitLabel.snp.makeConstraints({ make in
            make.width.equalToSuperview()
            make.top.equalTo(valueLabel.snp.bottom).offset(-5)
            make.centerX.equalToSuperview()

        })
        self.unitLabel = unitLabel
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension DataView {
    static func Timer() -> DataView {
        let dataView = DataView(frame: .zero)
        dataView.iconIv?.image = #imageLiteral(resourceName: "ic_icons8-time")
        dataView.valueLabel?.text = "0:00:00"
        dataView.unitLabel?.text = "hours"
        return dataView
    }

    static func Distance(_ unit:String = "km") -> DataView {
        let dataView = DataView(frame: .zero)
        dataView.iconIv?.image = #imageLiteral(resourceName: "ic_icons8-map-pinpoint")
        dataView.valueLabel?.text = "0.0"
        dataView.unitLabel?.text = unit
        return dataView
    }

    static func Pace(_ unit:String = "min/km") -> DataView {
        let dataView = DataView(frame: .zero)
        dataView.iconIv?.image = #imageLiteral(resourceName: "ic_icons8-running")
        dataView.valueLabel?.text = "00:00"
        dataView.unitLabel?.text = unit
        return dataView
    }

    static func Steps(_ unit:String = "Steps") -> DataView {
        let dataView = DataView(frame: .zero)
        dataView.iconIv?.image = #imageLiteral(resourceName: "ic_icons8-trainers")
        dataView.valueLabel?.text = "0"
        dataView.unitLabel?.text = unit
        return dataView
    }
}
