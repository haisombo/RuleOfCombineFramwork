//
//  Router+Request.swift
//  RuleOfCombineFramwork
//
//  Created by Hai Sombo on 7/8/24.
//

import Foundation


extension Router {
    private func url(with baseURL: String) -> URL? {
        guard var urlComponents = URLComponents(string: baseURL) else { return nil }
        urlComponents.queryItems = queryItems
        guard let url = urlComponents.url?.appendingPathComponent(path) else { return nil }
        return url
    }
    
    public func request() -> URLRequest? {
        guard let url = url(with: url) else { return nil }
        
        var request = URLRequest(url: url)
        if requiresAuth {
            request.setValue("", forHTTPHeaderField: HTTPHeaderField.authentication.rawValue)
        }
        
        if requestType == .upload {
            request.setValue(ContentType.formData.rawValue + UUID().uuidString,
                             forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
        }
        
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.cachePolicy = kRequestCachePolicy
        request.timeoutInterval = kTimeoutInterval
        request.httpBody = requestType != .upload ? encodedBody : formDataBody
        
        return request
    }
    
    var formDataBody: Data? {
        guard [.post].contains(method), let body = body else {
            return nil
        }
        
        let httpBody = NSMutableData()
        let boundary = "Boundary-\(UUID().uuidString)"
        
        let mirror = Mirror(reflecting: body)
        for child in mirror.children {
            if let imageData = child.value as? ImageData {
                httpBody.append(dataFormField(named: child.label ?? "imageData", data: imageData.data, mimeType: imageData.memeType , boundary: boundary))
            } else if let value = child.value as? String {
                httpBody.append(textFormField(named: child.label ?? "unknown", value: value, boundary: boundary))
            }
        }
        
        httpBody.append("--\(boundary)--")
        
        return httpBody as Data
    }
    
    var queryItems: [URLQueryItem]? {
        guard method == .get, let body = body else {
            return nil
        }
        
        let mirror = Mirror(reflecting: body)
        return mirror.children.compactMap { child -> URLQueryItem? in
            guard let label = child.label else { return nil }
            let valueString = String(describing: child.value)
            return URLQueryItem(name: label, value: valueString)
        }
    }
    
    var encodedBody: Data? {
        guard [.post, .put, .patch].contains(method), let body = body else {
            return nil
        }
        
        do {
            let jsonData = try JSONEncoder().encode(body)
            return jsonData
        } catch {
            print("Error encoding JSON: \(error)")
            return nil
        }
    }
    
    private func textFormField(named name: String, value: String, boundary: String) -> Data {
        var fieldString = "--\(boundary)\r\n"
        fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
        fieldString += "Content-Type: text/plain; charset=ISO-8859-1\r\n"
        fieldString += "Content-Transfer-Encoding: 8bit\r\n"
        fieldString += "\r\n"
        fieldString += "\(value)\r\n"
        fieldString += "\r\n"
        
        return fieldString.data(using: .utf8) ?? Data()
    }
    
    private func dataFormField(named name: String, data: Data, mimeType: String, boundary: String) -> Data {
        var fieldData = Data()
        
        fieldData.append("--\(boundary)\r\n".data(using: .utf8) ?? Data())
        fieldData.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"file\"\r\n".data(using: .utf8) ?? Data())
        fieldData.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8) ?? Data())
        fieldData.append(data)
        fieldData.append("\r\n".data(using: .utf8) ?? Data())
        
        return fieldData
    }
}
