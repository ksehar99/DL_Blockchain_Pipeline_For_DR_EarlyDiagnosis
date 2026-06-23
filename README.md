# DL + Blockchain Pipeline for Diabetic Retinopathy Early Diagnosis

This repository contains the ongoing development of an internship project that integrates Deep Learning and Blockchain technology for the secure and automated diagnosis of Diabetic Retinopathy (DR). 

The goal of this project is to use a Deep Learning network for classification and an Ethereum smart contract to maintain a tamper-proof ledger of the diagnosis records.

---

## Current Implementation Status

### 1. Deep Learning Model
* **Environment & Dataset:** Developed using Google Colab (with GPU acceleration) 
* **Pipeline:** Handles image preprocessing, dataset loading, and splitting into training and testing subsets.
* **Training Metrics:** The notebook includes initial model evaluation with classification reports, tracks class-wise precision/recall, and monitors overall accuracy.

### 2. Smart Contract
* **Contract Name:** `DRDiagnosisResuls`
* **Core Structures:** Implements `Patient` registry and `Diagnosis` records containing cryptographic image hashes (`bytes32 diagnosisImageHash`) and multi-class categories (`uint diagnosisResultCategory`).
* **Access Control:** * `onlyOwner` modifier ensures that only the hospital admin can register patients and assign them to doctors.
  * `uploadDiagnosis` restricts data uploads exclusively to the doctor assigned to that specific patient.
  * `viewRecords` allows the admin and the assigned doctor to query historical records.

---

## Repository Structure

* `DR-Diagnosis.sol`: Solidity smart contract managing data validation and state variables.
* `Copy_of_DR_DL_training.ipynb`: Jupyter Notebook detailing data handling and model training metrics.

---

## Next Steps 

* **Pipeline Integration:** Utilizing `Web3.py` to connect the Python environment with the deployed blockchain network.
* **Automation:** Integrating the trained classification model directly with the smart contract to automatically compute image hashes and log diagnosis results (0–4) on-chain.
* **Validation:** Conducting end-to-end testing with mock patient profiles to verify data access control and record retrieval.
