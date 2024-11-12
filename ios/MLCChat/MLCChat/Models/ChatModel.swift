//
//  ChatModel.swift
//  MLCChat
//
//  Created by Debakshi Bhattacharjee on 12/11/24.
//

import Foundation

struct ChatModel:Codable{
    var id: String?
    var model: String?
    var version: String?
    var input: ChatInput?
    var logs: String?
    var output: String?
    var data_removed: Bool?
    var error: String?
    var status: String?
    var created_at: String?
    var urls: ChatUrls?
}

struct ChatInput:Codable {
    var max_tokens: Int? = 1024
    var prompt: String?
    var system_prompt = SystemPromptsList.defaultPrompt
}

struct ChatUrls: Codable {
    var cancel: String?
    var get: String?
    var stream: String?
}


struct MsgInputModel: Codable {
    var version: String? =  kModelVersion
    var  input: MsgInput?
}

struct MsgInput: Codable {
    var prompt: String?
    var max_tokens: Int? =  1024
    var system_prompt = SystemPromptsList.defaultPrompt
}

struct AnswerModel:Codable {
    var id: String?
    var model: String?
    var version: String?
    var input: MsgInputModel?
    var logs: String?
    var output: [String?]?
    var data_removed:Bool?
    var error: String?
    var status: String?
    var created_at: String?
    var started_at: String?
    var completed_at: String?
    var urls: ChatUrls?
    var metrics: Metrics?
}

struct Metrics:Codable {
    
    var batch_size: Double?
    var input_token_count: Double
    var output_token_count: Double
    var predict_time: Double
    var predict_time_share: Double?
    var time_to_first_token: Double
    var tokens_per_second: Double
}


enum MessageType {
    case loading
    case sending
    case receiving
}

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    var type: MessageType
    var message: String
}
