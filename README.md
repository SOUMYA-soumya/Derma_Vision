# Derma_Vision
# 🔬 Diagnomass: Derma-Vision AI (Web Frontend)

![Flutter](https://img.shields.io/badge/Flutter-Web-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Vercel](https://img.shields.io/badge/Deployed_on-Vercel-000000?style=for-the-badge&logo=vercel&logoColor=white)

This repository contains the cross-platform web frontend for **Derma-Vision**, an AI-powered dermatological analysis module under the Diagnomass ecosystem. 

The application provides a clean, responsive medical-grade interface for uploading dermoscopic images and patient metadata, which are then processed by a remote PyTorch backend.

## 🧠 Architecture Overview

Derma-Vision utilizes a decoupled architecture for maximum scalability:
* **Frontend:** Built with Flutter Web for a highly responsive, app-like experience in the browser.
* **Backend:** Hosted on Hugging Face Spaces, exposing a REST API.
* **AI Model:** A dual-stream EfficientNet-B7 ensemble that processes standard RGB visual features alongside custom pre-computed CTE (Color-Texture-Edge) maps.

## ✨ Features
* **Cross-Platform:** Runs flawlessly on desktop browsers and mobile web.
* **Secure Image Upload:** Processes high-resolution dermoscopic images via Base64 encoding.
* **Clinical Metadata Integration:** Incorporates patient age, biological sex, and anatomical site (Head/Neck, Torso, Extremities, etc.) into the AI's prediction matrix.
* **Real-time Inference:** Connects directly to the Python backend for sub-second clinical confidence scoring.
