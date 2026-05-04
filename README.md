# 🚀 Gemini Chat

# 📌 Overview

This project is a Flutter-based real-time chat application that integrates streaming AI responses
using the Gemini API.

## ⚙️ Architecture Overview

This project follows a clean and modular architecture.

## 🔹 Core Components

# ChatViewModel

Manages chat state, streaming lifecycle, and scroll behavior.

# LockedScrollController

Prevents unwanted programmatic scrolling and enforces scroll locking logic.

# GeminiStreamManager

Handles AI streaming lifecycle:
start → chunk → complete → error

# InMemoryChatController

Lightweight in-memory message storage without a database.

# Composer

Custom input component with send/stop streaming support.

## 🔄 Streaming Flow

User sends message
↓
Message inserted into chat
↓
Gemini API starts streaming response
↓
Agent message inserted lazily
↓
Chunks received in real-time
↓
UI updates progressively
↓
Stream completes → final message saved
↓
Scroll behavior updated based on user position

## 📱 Features

💬 Real-time AI chat using Gemini API

📡 Streaming responses (chunk by chunk)

📜 Smart auto-scroll system (WhatsApp-like behavior)

🧠 User scroll position preservation

🖼️ Image upload support

⛔ Stop streaming feature

🎨 Clean and responsive UI

🚀 Deployment

## 👉 Live Demo:

https://rad-gelato-eb2106.netlify.app/

## 🎥 Screen Recordings

## 🎬 Scenario 1: Basic Auto-Scroll :

https://github.com/user-attachments/assets/1a14043f-3818-46cc-8252-24c2f55a1809

# 🎬 Scenario 2: Pause on Manual Scroll :

https://github.com/user-attachments/assets/3b040f6b-3317-4670-b1bc-bd39b8b7df2c

# 🎬 Scenario 3: Send While Scrolled Up :

https://github.com/user-attachments/assets/b6fad2ed-bd0c-400a-8d34-1804eca6e048

# 🎬 Scenario 4: Resume Auto-Scroll :

https://github.com/user-attachments/assets/4deb9b68-216d-4f94-8dcb-eae6536b8c4c

## 🛠️ Tech Stack

Flutter & Dart
Provider (State Management)
Gemini API (Google Generative AI)
flutter_chat_ui
flutter_chat_core
Cross Cache
Image Picker

## 🧾 Notes

This project focuses on:

Smooth UX experience
Stable scroll behavior
Real-time streaming performance
Clean and scalable architecture
