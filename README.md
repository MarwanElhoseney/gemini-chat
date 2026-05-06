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

https://github.com/user-attachments/assets/72ea766e-c099-428c-9525-235cffb00cc9

# 🎬 Scenario 2: Pause on Manual Scroll :

https://github.com/user-attachments/assets/3cd66f76-0add-4fcf-b6b5-4b1193ccbb53

# 🎬 Scenario 3: Send While Scrolled Up :

https://github.com/user-attachments/assets/69796da2-b26e-4a8c-a929-ce5359a15ba2

# 🎬 Scenario 4: Resume Auto-Scroll :

https://github.com/user-attachments/assets/2d66c8be-47db-42ca-9672-3b33b5454f3a

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
