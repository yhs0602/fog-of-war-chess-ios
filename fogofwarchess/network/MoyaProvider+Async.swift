//
//  MoyaProvider+Async.swift
//  fogofwarchess
//
//  Created by 양현서 on 2023/08/16.
//

import Moya

extension MoyaProvider {
    func request(_ target: Target) async -> Result<Response, MoyaError> {
        await withCheckedContinuation { continuation in
            self.request(target) { result in
                continuation.resume(returning: result)
            }
        }
    }
}
