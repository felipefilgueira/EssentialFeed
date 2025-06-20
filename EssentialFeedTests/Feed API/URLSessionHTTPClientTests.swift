//
//  URLSessionHTTPClientTests.swift
//  EssentialFeed
//
//  Created by Felipe Filgueira on 6/11/25.
//


import XCTest
@testable import EssentialFeed

class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        URLProtocolStub.startIntercepetingRequests()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopIntercepetingRequests()
    }
    
    //16:40
    
    func test_getFromURL_performsGETRequestWithURL() {
        let url = anyURL()
        let exp = expectation(description: "Wait for request")
        
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSUT().get(from: url) { _ in }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_failOnRequestError() {
        let requestError = anyNSError()
        let receivedError = resultErrorFor(data: nil, response: nil, error: requestError)

        XCTAssertEqual((receivedError as? NSError)?.code, requestError.code)
        XCTAssertEqual((receivedError as? NSError)?.domain, requestError.domain)
    }
    
    //19:34
    
    func test_getFromURL_failOnAllInvalidRepresentationCase() {
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: nil))
//        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: nil))
    }
    
    func test_getFromURL_sucessdsOnHTTPURLResponseWithData() {
        let data = anyData()
        let response = anyHTTPURLResponse()
        let receivedValues = resultValuesFor(data: data, response: response, error: nil)

        XCTAssertEqual(receivedValues?.data, data)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
        XCTAssertEqual(receivedValues?.response.url, response.url)

    }
    
    func test_getFromURL_sucessdsWithEmptyDataOnHTTPURLResponseWithNilData() {
        let response = anyHTTPURLResponse()
        let receivedValues = resultValuesFor(data: nil, response: response, error: nil)
        let emptyData = Data()

        XCTAssertEqual(receivedValues?.data, emptyData)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
        XCTAssertEqual(receivedValues?.response.url, response.url)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut, file: file, line: line)
        return URLSessionHTTPClient()
    }
    
    private func resultErrorFor(data: Data?,
                                response: URLResponse?,
                                error: Error?,
                                file: StaticString = #filePath,
                                line: UInt = #line ) -> Error? {
        
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        
        switch result {
        case let .failure(error):
            return error
        default:
            XCTFail("Expected failure, got \(result) instead")
            return nil
        }
    }
    
    private func resultValuesFor(data: Data?,
                                response: URLResponse?,
                                error: Error?,
                                file: StaticString = #filePath,
                                 line: UInt = #line ) -> (data: Data, response: HTTPURLResponse)? {
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)

        switch result {
        case let .success(data, response):
            return (data, response)
        default:
            XCTFail("Expected failure, got \(result) instead")
            return nil
        }
        
    }
    
    private func resultFor(data: Data?,
                                response: URLResponse?,
                                error: Error?,
                                file: StaticString = #filePath,
                           line: UInt = #line ) -> HTTPClientResult {
        URLProtocolStub.stub(data: data, response: response, error: error)
        
        let sut = makeSUT(file: file, line: line)
        let exp = expectation(description: "Waiting for completion")
        
        var receivedResult: HTTPClientResult!
        sut.get(from: anyURL()) { result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return receivedResult
    }
    
    private func anyURL() -> URL {
        URL(string: "http://any-url.com")!
    }
    
    private func anyData() -> Data {
        Data(bytes: "any data".utf8)
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
    
    private func nonHTTPURLResponse() -> URLResponse {
        URLResponse(url: anyURL(),
                    mimeType: nil,
                    expectedContentLength: 0,
                    textEncodingName: nil)
    }
    
    private func anyHTTPURLResponse() -> HTTPURLResponse {
        HTTPURLResponse(url: anyURL(),
                        statusCode: 200,
                        httpVersion: nil,
                        headerFields: nil)!
    }
    
    private class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        static func startIntercepetingRequests() {
            URLProtocol.registerClass(self)
        }
        
        static func stopIntercepetingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        override func startLoading() {
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {
            //
        }
    }
}
