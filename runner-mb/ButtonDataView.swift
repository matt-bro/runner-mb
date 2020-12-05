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

class ButtonDataView: DataView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    var actionBtn: UIButton?
    var deleteBtn: UIButton?
    var pressedAddAction:(()->())?
    var pressedDeleteAction:(()->())?

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.valueLabel?.numberOfLines = 2
        //self.valueLabel?.font = UIFont(name: "Helvetica-Neue", size: 10.0)
        let btn = UIButton(type: .custom)
        btn.setTitle("Add Ghost", for: .normal)
        btn.setTitleColor(.systemGray, for: .normal)
        btn.addTarget(self, action: #selector(pressedAdd), for: .touchUpInside)
        self.addSubview(btn)
        btn.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(30)
        }
        self.actionBtn = btn

        let deleteBtn = UIButton(type: .custom)
        deleteBtn.setTitle("Reset ghost", for: .normal)
        deleteBtn.setTitleColor(.red, for: .normal)
        deleteBtn.isHidden = true
        deleteBtn.addTarget(self, action: #selector(pressedDelete), for: .touchUpInside)
        self.addSubview(deleteBtn)
        deleteBtn.snp.makeConstraints { make in

            make.width.equalToSuperview()
            make.height.equalTo(30)
            make.bottom.equalToSuperview()
        }
        self.deleteBtn = deleteBtn

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func pressedAdd() {
        pressedAddAction?()
    }

    @objc func pressedDelete() {
        pressedDeleteAction?()
    }
}

extension DataView {
    static func Button(_ unit:String = " ") -> ButtonDataView {
        let dataView = ButtonDataView(frame: .zero)
        dataView.iconIv?.image = #imageLiteral(resourceName: "ic_icons8-trainers")
        dataView.valueLabel?.text = ""
        dataView.unitLabel?.text = unit
        return dataView
    }
}
