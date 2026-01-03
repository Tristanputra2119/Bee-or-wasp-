"""
Bee vs Wasp Classification API
FastAPI server for serving the Keras model predictions

This version rebuilds the model architecture and loads weights separately
to avoid Lambda layer deserialization issues.
"""

import os
import json
import zipfile
import tempfile
from pathlib import Path
from io import BytesIO

import numpy as np
from PIL import Image
from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List

# TensorFlow/Keras imports
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'  # Suppress TF warnings

import keras
from keras.applications.mobilenet_v2 import MobileNetV2, preprocess_input
from keras import layers, Model

# === Configuration ===
MODEL_PATH = Path(__file__).parent.parent / "model" / "model_serangga.keras"
CLASS_INDICES_PATH = Path(__file__).parent.parent / "model" / "class_indices.json"
IMG_SIZE = (224, 224)

# === Build Model Architecture ===
def build_model():
    """
    Rebuild the model architecture to match the original:
    - Input (224, 224, 3)
    - Lambda (preprocess_input) - skipped, we'll do this in preprocessing
    - MobileNetV2 (trainable=false)
    - GlobalAveragePooling2D
    - Dense(128, relu)
    - Dropout(0.2)
    - Dense(4, softmax)
    """
    # Base model
    base_model = MobileNetV2(
        weights=None,  # We'll load weights manually
        include_top=False,
        input_shape=(224, 224, 3)
    )
    base_model.trainable = False
    
    # Build the full model
    inputs = layers.Input(shape=(224, 224, 3), name='input_layer_3')
    
    # Skip Lambda layer - we'll do preprocessing manually before inference
    x = base_model(inputs, training=False)
    x = layers.GlobalAveragePooling2D(name='global_average_pooling2d_1')(x)
    x = layers.Dense(128, activation='relu', name='dense_2')(x)
    x = layers.Dropout(0.2, name='dropout_1')(x)
    outputs = layers.Dense(4, activation='softmax', name='dense_3')(x)
    
    model = Model(inputs=inputs, outputs=outputs)
    return model

# === Load Weights from .keras file ===
def load_weights_from_keras_file(model, keras_path):
    """Extract and load weights from .keras file (which is a zip)"""
    with tempfile.TemporaryDirectory() as tmpdir:
        with zipfile.ZipFile(keras_path, 'r') as zip_ref:
            # Extract model.weights.h5
            zip_ref.extract('model.weights.h5', tmpdir)
            weights_path = Path(tmpdir) / 'model.weights.h5'
            
            # Load weights
            model.load_weights(weights_path)
            print(f"Weights loaded from {keras_path}")
    return model

# === Initialize Model ===
print("Building model architecture...")
model = build_model()
print("Model architecture built successfully")

print("Loading weights...")
try:
    model = load_weights_from_keras_file(model, MODEL_PATH)
    print("Model weights loaded successfully!")
except Exception as e:
    print(f"Warning: Could not load weights: {e}")
    print("Using ImageNet weights instead")
    model = build_model()
    # Re-initialize base with imagenet weights
    base_model = MobileNetV2(weights='imagenet', include_top=False, input_shape=(224, 224, 3))
    model.layers[1].set_weights(base_model.get_weights())

# Load class names
with open(CLASS_INDICES_PATH, 'r') as f:
    class_names = json.load(f)
print(f"Classes: {class_names}")

# === FastAPI App ===
app = FastAPI(
    title="Bee vs Wasp Classifier API",
    description="API for classifying images of bees, wasps, and other insects",
    version="1.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# === Response Models ===
class SinglePrediction(BaseModel):
    class_name: str
    confidence: float

class PredictionResponse(BaseModel):
    class_name: str
    confidence: float
    all_predictions: List[SinglePrediction]

# === Image Preprocessing ===
def preprocess_image_for_prediction(image: Image.Image) -> np.ndarray:
    """
    Preprocess image for model prediction.
    Apply MobileNetV2 preprocessing (since we removed Lambda layer from model).
    """
    # Convert to RGB if necessary
    if image.mode != 'RGB':
        image = image.convert('RGB')
    
    # Resize to target size
    image = image.resize(IMG_SIZE, Image.Resampling.LANCZOS)
    
    # Convert to array
    img_array = np.array(image, dtype=np.float32)
    
    # Add batch dimension
    img_array = np.expand_dims(img_array, axis=0)
    
    # Apply MobileNetV2 preprocessing (the Lambda layer did this originally)
    img_array = preprocess_input(img_array)
    
    return img_array

# === API Endpoints ===
@app.get("/")
async def root():
    """Health check endpoint"""
    return {"status": "ok", "message": "Bee vs Wasp Classifier API is running"}

@app.get("/api/health")
async def health():
    """Health check endpoint"""
    return {"status": "ok", "model_loaded": model is not None}

@app.post("/api/predict", response_model=PredictionResponse)
async def predict(file: UploadFile = File(...)):
    """
    Predict whether an uploaded image contains a bee, wasp, or other insect.
    """
    if model is None:
        raise HTTPException(status_code=500, detail="Model not loaded")
    
    # Validate file type
    if not file.content_type or not file.content_type.startswith('image/'):
        raise HTTPException(status_code=400, detail="File must be an image")
    
    try:
        # Read and preprocess image
        contents = await file.read()
        image = Image.open(BytesIO(contents))
        processed_image = preprocess_image_for_prediction(image)
        
        # Make prediction
        predictions = model.predict(processed_image, verbose=0)
        predicted_class_idx = np.argmax(predictions[0])
        confidence = float(predictions[0][predicted_class_idx])
        
        # Build all predictions list
        all_predictions = [
            SinglePrediction(
                class_name=class_names[i],
                confidence=float(predictions[0][i])
            )
            for i in range(len(class_names))
        ]
        # Sort by confidence descending
        all_predictions.sort(key=lambda x: x.confidence, reverse=True)
        
        return PredictionResponse(
            class_name=class_names[predicted_class_idx],
            confidence=confidence,
            all_predictions=all_predictions
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Prediction failed: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
