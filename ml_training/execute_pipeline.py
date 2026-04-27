import os
import json
import glob
import numpy as np
import tensorflow as tf
from tensorflow.keras.applications import EfficientNetB0
from tensorflow.keras.layers import Dense, GlobalAveragePooling2D, Dropout
from tensorflow.keras.models import Model
from tensorflow.keras.preprocessing.image import ImageDataGenerator, load_img, img_to_array
from sklearn.metrics import classification_report, confusion_matrix
import matplotlib.pyplot as plt
from PIL import Image, ImageFilter

# ======================
# CONFIGURATION
# ======================
IMAGE_SIZE = (224, 224)
BATCH_SIZE = 16
EPOCHS_INITIAL = 5
EPOCHS_FINE = 5
MODEL_PATH = "agroai_model_final.h5"
LABELS_PATH = "class_labels.json"

# ======================
# STEP 1: DATASET VALIDATION
# ======================
def validate_dataset(data_dir):
    print("--- STEP 1: DATASET VALIDATION ---")
    if not os.path.exists(data_dir):
        raise ValueError(f"Dataset path {data_dir} not found.")

    classes = [d for d in os.listdir(data_dir) if os.path.isdir(os.path.join(data_dir, d))]
    num_classes = len(classes)
    
    print(f"Total classes found: {num_classes}")
    
    class_counts = {}
    for c in classes:
        files = glob.glob(os.path.join(data_dir, c, "*.*"))
        # filter images
        images = [f for f in files if f.lower().endswith(('.png', '.jpg', '.jpeg'))]
        class_counts[c] = len(images)
    
    print("\nImages per class:")
    for c, count in class_counts.items():
        print(f" - {c}: {count} images")
        
    counts = list(class_counts.values())
    if counts:
        max_c = max(counts)
        min_c = min(counts)
        imbalance_ratio = max_c / min_c if min_c > 0 else float('inf')
        print(f"\nClass imbalance ratio (Max/Min): {imbalance_ratio:.2f}")
        if imbalance_ratio > 3.0:
            print("WARNING: Significant class imbalance detected!")
    print("-" * 40)
    return num_classes

# ======================
# STEP 2 & 3: BUILD AND TRAIN
# ======================
def build_model(num_classes):
    base_model = EfficientNetB0(
        weights='imagenet',
        include_top=False,
        input_shape=(*IMAGE_SIZE, 3)
    )
    
    for layer in base_model.layers[:-50]:
        layer.trainable = False

    for layer in base_model.layers[-50:]:
        layer.trainable = True

    x = base_model.output
    x = GlobalAveragePooling2D()(x)
    x = Dense(512, activation='relu')(x)
    x = Dropout(0.5)(x)
    predictions = Dense(num_classes, activation='softmax')(x)

    model = Model(inputs=base_model.input, outputs=predictions)
    
    # We will compute precision and recall manually via sklearn in final evaluation
    # as tf.keras.metrics for multi-class require one-hot, keeping it simple here.
    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=0.0001),
        loss='categorical_crossentropy',
        metrics=['accuracy']
    )
    return model, base_model

def execute_training(data_dir, num_classes):
    print("\n--- STEP 2: TRAIN MODEL ---")
    
    datagen = ImageDataGenerator(
        rescale=1./255,
        rotation_range=25,
        width_shift_range=0.2,
        height_shift_range=0.2,
        zoom_range=0.2,
        horizontal_flip=True,
        validation_split=0.2
    )

    train_gen = datagen.flow_from_directory(
        data_dir,
        target_size=IMAGE_SIZE,
        batch_size=BATCH_SIZE,
        class_mode='categorical',
        subset='training'
    )

    val_gen = datagen.flow_from_directory(
        data_dir,
        target_size=IMAGE_SIZE,
        batch_size=BATCH_SIZE,
        class_mode='categorical',
        subset='validation',
        shuffle=False # Needed for correct sklearn metrics evaluation
    )

    # Save class labels
    class_labels = {v: k for k, v in train_gen.class_indices.items()}
    with open(LABELS_PATH, 'w') as f:
        json.dump(class_labels, f, indent=4)

    model, base_model = build_model(num_classes)

    callbacks = [
        tf.keras.callbacks.ModelCheckpoint(
            'best_model.h5', monitor='val_accuracy', save_best_only=True, verbose=1
        ),
        tf.keras.callbacks.EarlyStopping(
            monitor='val_loss', patience=3, restore_best_weights=True
        )
    ]

    from sklearn.utils.class_weight import compute_class_weight
    class_weights = compute_class_weight(
        class_weight='balanced',
        classes=np.unique(train_gen.classes),
        y=train_gen.classes
    )
    class_weights = dict(enumerate(class_weights))

    print("\n[Phase 1] Training Head...")
    history = model.fit(
        train_gen,
        validation_data=val_gen,
        epochs=EPOCHS_INITIAL,
        callbacks=callbacks,
        class_weight=class_weights
    )

    print("\n[Phase 2] Fine-tuning...")
    for layer in base_model.layers[-30:]:
        layer.trainable = True

    model.compile(
        optimizer=tf.keras.optimizers.Adam(1e-5),
        loss='categorical_crossentropy',
        metrics=['accuracy']
    )

    history_fine = model.fit(
        train_gen,
        validation_data=val_gen,
        epochs=EPOCHS_FINE,
        callbacks=callbacks
    )

    # Combine histories for plotting
    acc = history.history['accuracy'] + history_fine.history['accuracy']
    val_acc = history.history['val_accuracy'] + history_fine.history['val_accuracy']
    loss = history.history['loss'] + history_fine.history['loss']
    val_loss = history.history['val_loss'] + history_fine.history['val_loss']

    # ======================
    # STEP 3: FINAL EVALUATION
    # ======================
    print("\n--- STEP 3: FINAL EVALUATION ---")
    val_gen.reset()
    predictions = model.predict(val_gen)
    y_pred = np.argmax(predictions, axis=1)
    y_true = val_gen.classes

    report = classification_report(y_true, y_pred, output_dict=True)
    
    val_accuracy = report['accuracy']
    precision = report['macro avg']['precision']
    recall = report['macro avg']['recall']

    metrics = {
        "num_classes": num_classes,
        "validation_accuracy": round(val_accuracy, 4),
        "precision": round(precision, 4),
        "recall": round(recall, 4)
    }
    
    with open("metrics.json", "w") as f:
        json.dump(metrics, f, indent=4)
        
    print(json.dumps(metrics, indent=2))

    # ======================
    # STEP 4: SAVE ARTIFACTS
    # ======================
    print("\n--- STEP 4: SAVE ARTIFACTS ---")
    model.save(MODEL_PATH)
    print(f"Model saved to {MODEL_PATH}")
    print(f"Class labels saved to {LABELS_PATH}")

    plt.figure()
    plt.plot(acc, label='Train Acc')
    plt.plot(val_acc, label='Val Acc')
    plt.legend()
    plt.title("Accuracy")
    plt.savefig("accuracy.png")

    plt.figure()
    plt.plot(loss, label='Train Loss')
    plt.plot(val_loss, label='Val Loss')
    plt.legend()
    plt.title("Loss")
    plt.savefig("loss.png")
    print("Training graphs saved (accuracy.png, loss.png).")
    
    return model, class_labels, val_gen

# ======================
# STEP 5: REAL-WORLD TEST FUNCTION
# ======================
def predict_image(model, class_labels, image_path):
    try:
        img = load_img(image_path, target_size=IMAGE_SIZE)
        img_array = img_to_array(img) / 255.0
        img_array = np.expand_dims(img_array, axis=0)

        predictions = model.predict(img_array, verbose=0)
        class_idx = np.argmax(predictions[0])
        confidence = float(predictions[0][class_idx])

        # Convert back int key from string dictionary keys if necessary
        # class_labels uses string keys when loaded from JSON, but here it's int
        disease = class_labels[class_idx]

        return {
            "disease": disease,
            "confidence": round(confidence, 4)
        }
    except Exception as e:
        return {"error": str(e)}

def run_tests(model, class_labels, val_gen):
    print("\n--- STEP 5: REAL-WORLD TEST FUNCTION ---")
    # Take 3 real images from the validation set
    test_files = val_gen.filepaths[:3]
    for i, path in enumerate(test_files):
        print(f"Test Image {i+1} ({os.path.basename(path)}):")
        result = predict_image(model, class_labels, path)
        print(json.dumps(result, indent=2))
        
    # ======================
    # STEP 7: FAILURE ANALYSIS
    # ======================
    print("\n--- STEP 7: FAILURE ANALYSIS ---")
    # Create artificial failure cases to analyze model robustness
    print("Generating failure cases (Blur, Lighting, Wrong Class)...")
    
    if len(val_gen.filepaths) > 0:
        sample_path = val_gen.filepaths[0]
        
        # 1. Blur
        blurred_path = "failure_blur.jpg"
        img = Image.open(sample_path)
        img.filter(ImageFilter.GaussianBlur(radius=10)).save(blurred_path)
        print("\nFailure Case 1: Motion/Focus Blur")
        print(json.dumps(predict_image(model, class_labels, blurred_path), indent=2))
        
        # 2. Lighting (Extreme Dark)
        dark_path = "failure_dark.jpg"
        img = Image.open(sample_path)
        img.point(lambda p: p * 0.1).save(dark_path)
        print("\nFailure Case 2: Extreme Poor Lighting")
        print(json.dumps(predict_image(model, class_labels, dark_path), indent=2))
        
        # 3. Random noise image (Wrong class proxy)
        noise_path = "failure_noise.jpg"
        noise_img = np.random.randint(0, 255, (224, 224, 3), dtype=np.uint8)
        Image.fromarray(noise_img).save(noise_path)
        print("\nFailure Case 3: Completely Unrelated Image (Noise)")
        print(json.dumps(predict_image(model, class_labels, noise_path), indent=2))
    else:
        print("Not enough images to perform failure analysis.")

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('--data_dir', type=str, required=True, help="Path to folder-based PlantVillage dataset")
    args = parser.parse_args()

    num_classes = validate_dataset(args.data_dir)
    model, class_labels, val_gen = execute_training(args.data_dir, num_classes)
    run_tests(model, class_labels, val_gen)
    print("\nPIPELINE EXECUTION COMPLETE.")
