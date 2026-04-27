import os
import numpy as np
import matplotlib.pyplot as plt
import tensorflow as tf
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.applications.mobilenet_v2 import MobileNetV2, preprocess_input
from tensorflow.keras import layers, models, optimizers
from tensorflow.keras.callbacks import ModelCheckpoint
from sklearn.utils.class_weight import compute_class_weight

# --- CONFIGURATION ---
DATASET_PATH = '/content/PlantVillage'
IMG_SIZE = (224, 224)
BATCH_SIZE = 16
NUM_CLASSES = 15
PHASE_1_EPOCHS = 5
PHASE_2_EPOCHS = 5
LR_PHASE_1 = 1e-3
LR_PHASE_2 = 1e-5

def get_data_generators(dataset_path):
    """
    Creates training and validation data generators with augmentation.
    """
    # Data Augmentation & Preprocessing
    train_datagen = ImageDataGenerator(
        preprocessing_function=preprocess_input,
        rotation_range=15,
        width_shift_range=0.1,
        height_shift_range=0.1,
        zoom_range=0.1,
        horizontal_flip=True,
        validation_split=0.2
    )

    val_datagen = ImageDataGenerator(
        preprocessing_function=preprocess_input,
        validation_split=0.2
    )

    # Generators
    train_generator = train_datagen.flow_from_directory(
        dataset_path,
        target_size=IMG_SIZE,
        batch_size=BATCH_SIZE,
        class_mode='categorical',
        subset='training',
        shuffle=True,
        seed=42
    )

    validation_generator = val_datagen.flow_from_directory(
        dataset_path,
        target_size=IMG_SIZE,
        batch_size=BATCH_SIZE,
        class_mode='categorical',
        subset='validation',
        shuffle=False,
        seed=42
    )

    # Debug & Validation Prints
    print("\n--- DEBUG INFO ---")
    print(f"Train Class Indices: {train_generator.class_indices}")
    print(f"Validation Class Indices: {validation_generator.class_indices}")
    print(f"Number of training samples: {train_generator.samples}")
    print(f"Number of validation samples: {validation_generator.samples}")
    
    # Verify label shape (one-hot)
    x_batch, y_batch = next(train_generator)
    print(f"Batch Image Shape: {x_batch.shape}")
    print(f"Batch Label Shape: {y_batch.shape}")
    
    # Reset generator after debug batch
    train_generator.reset()
    
    return train_generator, validation_generator

def build_model(num_classes):
    """
    Builds the model with MobileNetV2 base and custom classification head.
    """
    base_model = MobileNetV2(
        weights='imagenet',
        include_top=False,
        input_shape=(IMG_SIZE[0], IMG_SIZE[1], 3)
    )

    # Classification Head
    x = base_model.output
    x = layers.GlobalAveragePooling2D()(x)
    x = layers.Dense(256, activation='relu')(x)
    x = layers.Dropout(0.5)(x)
    predictions = layers.Dense(num_classes, activation='softmax')(x)

    model = models.Model(inputs=base_model.input, outputs=predictions)
    return model, base_model

def plot_final_history(history_p1, history_p2):
    """
    Plots and saves consolidated training and validation metrics.
    """
    # Consolidate metrics
    acc = history_p1.history['accuracy'] + history_p2.history['accuracy']
    val_acc = history_p1.history['val_accuracy'] + history_p2.history['val_accuracy']
    loss = history_p1.history['loss'] + history_p2.history['loss']
    val_loss = history_p1.history['val_loss'] + history_p2.history['val_loss']
    
    epochs_range = range(1, len(acc) + 1)

    # Accuracy Plot
    plt.figure(figsize=(10, 5))
    plt.plot(epochs_range, acc, label='Training Accuracy')
    plt.plot(epochs_range, val_acc, label='Validation Accuracy')
    plt.axvline(x=PHASE_1_EPOCHS, color='r', linestyle='--', label='Start Fine-Tuning')
    plt.title('Training and Validation Accuracy')
    plt.xlabel('Epochs')
    plt.ylabel('Accuracy')
    plt.legend(loc='lower right')
    plt.savefig('accuracy.png')
    plt.close()

    # Loss Plot
    plt.figure(figsize=(10, 5))
    plt.plot(epochs_range, loss, label='Training Loss')
    plt.plot(epochs_range, val_loss, label='Validation Loss')
    plt.axvline(x=PHASE_1_EPOCHS, color='r', linestyle='--', label='Start Fine-Tuning')
    plt.title('Training and Validation Loss')
    plt.xlabel('Epochs')
    plt.ylabel('Loss')
    plt.legend(loc='upper right')
    plt.savefig('loss.png')
    plt.close()

def train():
    # 1. Load Data
    train_gen, val_gen = get_data_generators(DATASET_PATH)

    # 2. Compute Class Weights
    classes = train_gen.classes
    weights = compute_class_weight(
        class_weight='balanced',
        classes=np.unique(classes),
        y=classes
    )
    class_weights = dict(zip(np.unique(classes), weights))
    print(f"Computed Class Weights: {class_weights}")

    # 3. Build Model
    model, base_model = build_model(NUM_CLASSES)

    # --- PHASE 1: Training the Head ---
    print("\n--- PHASE 1: Training Classification Head ---")
    base_model.trainable = False  # Freeze ALL base model layers
    
    model.compile(
        optimizer=optimizers.Adam(learning_rate=LR_PHASE_1),
        loss='categorical_crossentropy',
        metrics=['accuracy']
    )

    checkpoint = ModelCheckpoint(
        'best_model.h5',
        monitor='val_accuracy',
        save_best_only=True,
        mode='max',
        verbose=1
    )

    history_p1 = model.fit(
        train_gen,
        validation_data=val_gen,
        epochs=PHASE_1_EPOCHS,
        class_weight=class_weights,
        callbacks=[checkpoint]
    )
    
    # --- PHASE 2: Fine-Tuning ---
    print("\n--- PHASE 2: Fine-Tuning Last 30 Layers ---")
    base_model.trainable = True
    # Freeze all but last 30 layers of the BASE model
    layers_to_freeze = len(base_model.layers) - 30
    for layer in base_model.layers[:layers_to_freeze]:
        layer.trainable = False
    
    # Re-compile for fine-tuning
    model.compile(
        optimizer=optimizers.Adam(learning_rate=LR_PHASE_2),
        loss='categorical_crossentropy',
        metrics=['accuracy']
    )

    history_p2 = model.fit(
        train_gen,
        validation_data=val_gen,
        epochs=PHASE_2_EPOCHS,
        class_weight=class_weights,
        callbacks=[checkpoint]
    )

    # 4. Save Final Model and Plots
    model.save('agroai_model_final.h5')
    plot_final_history(history_p1, history_p2)
    print("\nTraining Complete. Models saved as 'best_model.h5' and 'agroai_model_final.h5'.")
    print("Plots saved as 'accuracy.png' and 'loss.png'.")

if __name__ == "__main__":
    # Ensure directory exists (useful for local testing, though script is for Colab)
    if os.path.exists(DATASET_PATH):
        train()
    else:
        print(f"Error: Dataset path {DATASET_PATH} not found. Please ensure it is mounted or downloaded.")