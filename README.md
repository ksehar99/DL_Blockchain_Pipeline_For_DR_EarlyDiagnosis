# DR-Blockchain-PoC

## Diabetic Retinopathy Early Diagnosis — Deep Learning + Blockchain Pipeline
This repository contains an internship project integrating Deep Learning and Blockchain technology for secure, automated diagnosis of Diabetic Retinopathy (DR). A fine-tuned EfficientNetB3 model classifies retinal images by DR severity, while an Ethereum smart contract maintains a tamper-proof, access-controlled ledger of diagnosis records.

---

## Current Implementation Status

### 1. Deep Learning Model
- **Environment & Dataset:** Developed on Google Colab (GPU) using the APTOS 2019 dataset — 2,930 training images across 5 DR severity classes: No DR, Mild, Moderate, Severe, Proliferative.
- **Class Imbalance Handling:** Targeted augmentation applied to minority classes (Mild, Severe, Proliferative) to reach ~600 samples per class. Custom class weights further prioritize early-stage DR detection.
- **Architecture:** Transfer learning on EfficientNetB3 (ImageNet pretrained), fine-tuned on the last 30 layers. Classification head: GlobalAveragePooling2D → Dropout(0.3) → Dense(5, softmax).
- **Training:** Two-phase training — Phase 1 trains the head only; Phase 2 fine-tunes the last 30 base layers at a lower learning rate (1e-5). Adam optimizer, sparse categorical crossentropy, EarlyStopping (patience=5), ReduceLROnPlateau.
- **Evaluation Results (Validation Set — 586 images):**

| Class | Precision | Recall | F1-Score |
|---|---|---|---|
| No DR | 0.95 | 0.97 | 0.96 |
| Mild | 0.47 | 0.60 | 0.52 |
| Moderate | 0.69 | 0.82 | 0.75 |
| Severe | 0.83 | 0.17 | 0.28 |
| Proliferative | 0.82 | 0.29 | 0.43 |
| **Overall Accuracy** | | **0.79** | |

### 2. Smart Contract
- **Contract Name:** `DRDiagnosisResuls` — deployed on Sepolia testnet.
- **Core Structures:** `Patient` registry and `Diagnosis` records storing cryptographic image hashes (`bytes32`) and predicted DR severity class (`uint`).
- **Access Control:**
  - `onlyOwner` modifier restricts patient registration to the hospital admin.
  - `uploadDiagnosis` restricts uploads to the doctor assigned to that specific patient.
  - `viewRecords` is accessible only to the admin or the patient's assigned doctor.
  - Duplicate registration prevented via timestamp-based existence check.
- **Events:** `PatientRegistered` and `DiagnosisUploaded` emitted for transparent on-chain activity logging.

### 3. Python-Blockchain Bridge
- **Web3.py Integration:** Connected to Sepolia testnet via Alchemy RPC. Transactions are signed programmatically using the owner's private key — no MetaMask interaction required.
- **Patient Registration:** Synthetic patient profiles generated via Faker, persisted to a JSON store on Google Drive, and registered on-chain via the smart contract.
- **Diagnosis Upload:** Model inference runs on a randomly selected test image. The SHA-256 hash of the image and the predicted DR class (0–4) are uploaded on-chain via `uploadDiagnosis`.
- **Verification:** `verify_diagnosis` recomputes the image hash locally and compares it against the on-chain record — a mismatch flags potential data tampering.
- **Record Retrieval:** `view_records` and `view_patients` fetch on-chain data and enrich it with doctor and patient names from the local JSON store.

---

## Repository Structure
- `DR-Diagnosis.sol` — Solidity smart contract: patient registry, diagnosis records, access control.
- `Copy_of_DR_DL_training.ipynb` — Data preprocessing, augmentation, two-phase model training, and evaluation.
- `DR_Blockchain_Web3.ipynb` — Web3.py pipeline: patient registration, diagnosis upload, record retrieval, and tamper verification.

---

## Limitations
- **Doctor Authentication:** In this PoC, the hospital admin and doctor share the same wallet address. In production, each doctor would hold a separate wallet with their own private key.
- **Patient Privacy:** Patient data is stored in a local JSON file. A production system would require an encrypted database with blockchain-enforced access control at the API layer.
- **Model Recall on Severe Classes:** Recall for Severe (0.17) and Proliferative (0.29) DR is low — these are the most dangerous cases to miss. Further fine-tuning or focal loss is needed.
- **Data Persistence:** Google Colab sessions reset and clear `/content/`. The dataset and JSON store are on Drive, but the session must be re-initialized on each run.
- **Testnet Only:** The contract is deployed on Sepolia testnet. Mainnet deployment would require a full security audit, gas optimization, and HIPAA/GDPR compliance review.
- **No Frontend:** The pipeline is entirely script-based. A web interface would be needed for clinical use.

---

## Next Steps
- **Model Improvement:** Address low recall on Severe and Proliferative classes via focal loss, additional data, or class-specific fine-tuning.
- **Doctor Wallets:** Assign separate wallets per doctor and manage their private keys securely.
- **Database Layer:** Replace JSON with an encrypted database (e.g. MongoDB) with SC-enforced access control via a Python middleware layer.
- **IPFS Integration:** Store retinal images on IPFS and log the CID on-chain instead of a local hash — enabling decentralized, verifiable image storage.
- **Frontend:** Build a minimal web interface for patient registration, diagnosis upload, and record retrieval.
