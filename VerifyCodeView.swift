//
//  VerifyCodeField.swift
//  ChouTi
//
//  Created by 杨雨哲 on 2017/11/6.
//  Copyright © 2017年 com.longdai. All rights reserved.
//

import UIKit

private let kFontSize: CGFloat = 22
private let kBorderWidth: CGFloat = 1.5

protocol VerifyCodeFieldDelegate {
    func verifyCodeFieldDidDelete(field:VerifyCodeField)
}

class VerifyCodeField: UITextField {
    
    var fieldDelegate: VerifyCodeFieldDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.keyboardType = .numberPad
        self.textAlignment = .center
        self.tintColor = CTColor.colors.ct_yellow
        self.textColor = .black
        self.font = fontWithSize(kFontSize)
        self.layer.borderWidth = kBorderWidth
        self.layer.borderColor = CTColor.colors.ct_pullDownMenuTitleColor.cgColor
    }
    
    override func deleteBackward() {
        super.deleteBackward()
        fieldDelegate?.verifyCodeFieldDidDelete(field:self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol VerifyCodeViewDelegate {
    func verifyCodeViewDidFinishInput(code:String)
}

class VerifyCodeView: UIView {
    
    var delegate:VerifyCodeViewDelegate?
    
    var fieldNum: Int
    
    var textFields = [UITextField]()
    
    init(frame:CGRect, numOfField:Int, sizeOfField:CGFloat) {
        self.fieldNum = numOfField
        super.init(frame: frame)
        
        for index in 0..<numOfField {
            // 输入框frame
            let margin = (frame.size.width - CGFloat(numOfField)*sizeOfField)/CGFloat(numOfField - 1)
            let fieldFrame = CGRect(x: CGFloat(index)*(sizeOfField + margin), y: (frame.size.height - sizeOfField)/2, width: sizeOfField, height: sizeOfField)
    
            let field = VerifyCodeField(frame: fieldFrame)
            field.delegate = self
            field.fieldDelegate = self
            self.addSubview(field)
            
            textFields.append(field)
        }
        
        textFields.first?.becomeFirstResponder()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension VerifyCodeView:UITextFieldDelegate, VerifyCodeFieldDelegate {
    
    func clear() {
        for field in textFields {
            field.text = ""
        }
        textFields.first?.becomeFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        textField.text = string
        textField.resignFirstResponder()
        
        if let index = textFields.index(of: textField)
        {
            if index+1 < fieldNum
            {
                textFields[index+1].becomeFirstResponder()
            }
        }
        
        if textField == textFields[fieldNum - 1]
        {
            var code = ""
            for field in textFields
            {
                if let text = field.text
                {
                    code = code + text
                }
            }
            delegate?.verifyCodeViewDidFinishInput(code: code)
        }
        
        return false
    }
    
    func verifyCodeFieldDidDelete(field: VerifyCodeField) {
        if let index = textFields.index(of: field) {
            if index != 0 {
                field.resignFirstResponder()
            }
            if index-1 >= 0 {
                let preField = textFields[index - 1]
                preField.becomeFirstResponder()
                preField.text = ""
            }
        }
    }
    
}
