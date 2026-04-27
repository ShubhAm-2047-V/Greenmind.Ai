import tensorflow as tf
from tensorflow.keras.applications import MobileNetV2
from tensorflow.keras.layers import Dense, GlobalAveragePooling2D, Dropout
from tensorflow.keras.models import Model
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.applications.mobilenet_v2 import preprocess_input
from sklearn.utils.class_weight import compute_class_weight
import numpy as np
import os
import json
import matplotlib.pyplot as plt

# ======================
# CONFIGURATION
# ======================
DATA_DIR = '/content/PlantVillage'
IMAGE_SIZE = (224, 224)
BATCH_SIZE = 16
EPOCHS_PHASE1 = 5
EPOCHS_PHASE2 = 5

# ======================
# BUILD MODEL
# ======================
def build_model(num_classes):
    """
    Builds the MobileNetV2 model with a custom classification head.
    Initializes with all base model layers frozen.
    """
    base_model = MobileNetV2(
        weights='imagenet',
        include_top=False,
        input_shape=(*IMAGE_SIZE, 3)
    )

    # Freeze ALL base model layers for Phase 1
    for layer in base_model.layers:
        layer.trainable = False

    # Classification Head
    x = base_model.output
    x = GlobalAveragePooling2D()(x)
    x = Dense(256, activation='relu')(x)
    x = Dropout(0.5)(x)
    predictions = Dense(num_classes, activation='softmax')(x)

    model = Model(inputs=base_model.input, outputs=predictions)

    # Compile for Phase 1
    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=1e-3),
        loss='categorical_crossentropy',
        metrics=['accuracy']
    )

    return model, base_model

# ======================
# TRAIN FUNCTION
# ======================
def train():
    if not os.path.exists(DATA_DIR):
        print(f"ERROR: Dataset path {DATA_DIR} not found!")
        return

    # 1. DATA GENERATORS
    datagen = ImageDataGenerator(
        preprocessing_function=preprocess_input,
        rotation_range=15,
        width_shift_range=0.1,
        height_shift_range=0.1,
        zoom_range=0.1,
        horizontal_flip=True,
        validation_split=0.2
    )

    train_gen = datagen.flow_from_directory(
        DATA_DIR,
        target_size=IMAGE_SIZE,
        batch_size=BATCH_SIZE,
        class_mode='categorical',
        subset='training',
        shuffle=True
    )

    val_gen = datagen.flow_from_directory(
        DATA_DIR,
        target_size=IMAGE_SIZE,
        batch_size=BATCH_SIZE,
        class_mode='categorical',
        subset='validation',
        shuffle=False
    )

    # 2. DEBUG & VALIDATION
    print("\n--- DEBUG INFO ---")
    print("Train class indices:", train_gen.class_indices)
    print("Validation class indices:", val_gen.class_indices)

    if train_gen.class_indices != val_gen.class_indices:
        raise ValueError("CRITICAL: Class index mismatch between train and validation!")

    print(f"Total training samples: {train_gen.samples}")
    print(f"Total validation samples: {val_gen.samples}")

    # Verify label shape (one-hot)
    sample_x, sample_y = next(train_gen)
    print(f"Batch image shape: {sample_x.shape}")
    print(f"Batch label shape: {sample_y.shape}")
    
    if len(sample_y.shape) != 2:
        raise ValueError("ERROR: Labels are not one-hot encoded!")
    
    train_gen.reset() # Reset generator after debug batch

    num_classes = len(train_gen.class_indices)
    print(f"Detected {num_classes} classes")

    # 3. CLASS IMBALANCE
    class_weights = compute_class_weight(
        class_weight='balanced',
        classes=np.unique(train_gen.classes),
        y=train_gen.classes
    )
    class_weights_dict = dict(enumerate(class_weights))
    print("Computed Class Weights:", class_weights_dict)

    # 4. BUILD MODEL
    model, base_model = build_model(num_classes)

    # Callbacks
    callbacks = [
        tf.keras.callbacks.ModelCheckpoint(
            'best_model.h5',
            monitor='val_accuracy',
            save_best_only=True,
            verbose=1
        ),
        tf.keras.callbacks.EarlyStopping(
            monitor='val_loss',
            patience=3,
            restore_best_weights=True
        )
    ]

    # 5. PHASE 1: TRAIN HEAD
    print("\n--- PHASE 1: TRAINING CLASSIFICATION HEAD ---")
    history_p1 = model.fit(
        train_gen,
        validation_data=val_gen,
        epochs=EPOCHS_PHASE1,
        class_weight=class_weights_dict,
        callbacks=callbacks
    )

    # 6. PHASE 2: FINE-TUNING
    print("\n--- PHASE 2: FINE-TUNING BASE MODEL ---")
    
    # Unfreeze ONLY last 30 layers
    for layer in base_model.layers[:-30]:
        layer.trainable = False
    for layer in base_model.layers[-30:]:
        layer.trainable = True

    # Recompile with lower learning rate
    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=1e-5),
        loss='categorical_crossentropy',
        metrics=['accuracy']
    )

    history_p2 = model.fit(
        train_gen,
        validation_data=val_gen,
        epochs=EPOCHS_PHASE2,
        class_weight=class_weights_dict,
        callbacks=callbacks
    )

    # 7. FINAL EVALUATION & SAVE
    print("\n--- FINAL EVALUATION ---")
    loss, acc = model.evaluate(val_gen)
    print(f"Final Validation Accuracy: {acc:.4f}")

    model.save("agroai_model_final.h5")
    print("Final model saved: agroai_model_final.h5")

    # 8. PLOTS
    # Merge histories for plotting
    full_acc = history_p1.history['accuracy'] + history_p2.history['accuracy']
    full_val_acc = history_p1.history['val_accuracy'] + history_p2.history['val_accuracy']
    full_loss = history_p1.history['loss'] + history_p2.history['loss']
    full_val_loss = history_p1.history['val_loss'] + history_p2.history['val_loss']

    plt.figure(figsize=(12, 4))
    
    plt.subplot(1, 2, 1)
    plt.plot(full_acc, label='Train Acc')
    plt.plot(full_val_acc, label='Val Acc')
    plt.axvline(x=EPOCHS_PHASE1-1, color='r', linestyle='--', label='Fine-tuning start')
    plt.title('Accuracy')
    plt.legend()
    plt.savefig('accuracy.png')

    plt.subplot(1, 2, 2)
    plt.plot(full_loss, label='Train Loss')
    plt.plot(full_val_loss, label='Val Loss')
    plt.axvline(x=EPOCHS_PHASE1-1, color='r', linestyle='--', label='Fine-tuning start')
    plt.title('Loss')
    plt.legend()
    plt.savefig('loss.png')

    print("Plots saved: accuracy.png, loss.png")

if __name__ == "__main__":
    train()
