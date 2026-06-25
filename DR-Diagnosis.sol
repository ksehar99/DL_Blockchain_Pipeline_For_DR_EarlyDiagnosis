// SUB-PIPELINE 1 

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

/**
 * @title DRDiagnosisResults
 * @notice Smart contract for managing Diabetic Retinopathy diagnosis records on-chain.
 * @dev Stores cryptographic hashes of retinal images and their AI-predicted DR severity.
 *      Access is role-based: Admin registers patients, Doctors upload diagnoses, 
 *      and both Admin and Doctor can view records.
 */
contract DRDiagnosisResuls {

    // ─── Data Structures ────────────────────────────────────────────────────

    /// @notice Stores patient registration details
    struct Patient {
        uint patientId;       // Unique patient identifier
        address doctorId;     // Wallet address of the assigned doctor
        uint timestamp;       // Registration timestamp
    }

    /// @notice Stores a single diagnosis record for a patient
    struct Diagnosis {
        bytes32 diagnosisImageHash;     // keccak256/sha256 hash of the retinal image
        uint diagnosisResultCategory;   // DR severity: 0=No DR, 1=Mild, 2=Moderate, 3=Severe, 4=Proliferative
        uint patientId;                 // Reference to the patient
        address doctorId;               // Doctor who uploaded this diagnosis
        uint timestamp;                 // Upload timestamp
    }

    // ─── State Variables ─────────────────────────────────────────────────────

    /// @notice Contract deployer — acts as hospital admin
    address immutable owner;

    /// @dev Maps patient ID to their list of diagnosis records
    mapping(uint => Diagnosis[]) patientToDiagnosis;

    /// @dev Maps patient ID to their Patient struct
    mapping(uint => Patient) patientIdToPatient;

    /// @dev Maps doctor address to list of their assigned patient IDs
    mapping(address => uint[]) doctorToPatientId;

    // ─── Errors ──────────────────────────────────────────────────────────────

    /// @notice Thrown when a non-owner calls an owner-only function
    error NotOwner();

    /// @notice Thrown when an unauthorized address attempts restricted access
    error NotAuthorized();

    /// @notice Thrown when attempting to register a patient ID that already exists
    error PatientAlreadyExist();

    // ─── Events ──────────────────────────────────────────────────────────────

    /// @notice Emitted when a new patient is registered
    event PatientRegistered(uint patientId, address doctorAddress);

    /// @notice Emitted when a diagnosis is uploaded for a patient
    event DiagnosisUploaded(uint patientId, uint diagnosisResult, uint timestamp);

    // ─── Modifiers ───────────────────────────────────────────────────────────

    /// @notice Restricts function access to the contract owner (admin) only
    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    // ─── Constructor ─────────────────────────────────────────────────────────

    /// @notice Sets the deploying address as the contract owner
    constructor() {
        owner = msg.sender;
    }

    // ─── Functions ───────────────────────────────────────────────────────────

    /**
     * @notice Registers a new patient and assigns them a doctor
     * @dev Only callable by the owner. Patient ID must be unique.
     * @param _patientId Unique identifier for the patient
     * @param _doctorAddress Wallet address of the assigned doctor
     */
    function registerPatient(uint256 _patientId, address _doctorAddress) public onlyOwner {
        if (patientIdToPatient[_patientId].timestamp != 0) revert PatientAlreadyExist();

        patientIdToPatient[_patientId] = Patient(_patientId, _doctorAddress, block.timestamp);
        doctorToPatientId[_doctorAddress].push(_patientId);
        emit PatientRegistered(_patientId, _doctorAddress);
    }

    /**
     * @notice Uploads a diagnosis record for a patient
     * @dev Only the doctor assigned to that patient can upload.
     * @param patientId The patient's unique ID
     * @param imageHash SHA-256 hash of the retinal image (bytes32)
     * @param diagnosisResult DR severity class (0-4)
     */
    function uploadDiagnosis(uint patientId, bytes32 imageHash, uint diagnosisResult) external {
        if (patientIdToPatient[patientId].doctorId != msg.sender) revert NotAuthorized();

        patientToDiagnosis[patientId].push(
            Diagnosis(imageHash, diagnosisResult, patientId, msg.sender, block.timestamp)
        );
        emit DiagnosisUploaded(patientId, diagnosisResult, block.timestamp);
    }

    /**
     * @notice Returns list of patient IDs assigned to the calling doctor
     * @return Array of patient IDs
     */
    function viewPatients() external view returns (uint[] memory) {
        return doctorToPatientId[msg.sender];
    }

    /**
     * @notice Returns all diagnosis records for a given patient
     * @dev Accessible by the owner (admin) or the assigned doctor only
     * @param _patientId The patient's unique ID
     * @return Array of Diagnosis structs
     */
    function viewRecords(uint _patientId) external view returns (Diagnosis[] memory) {
        if (msg.sender != owner && msg.sender != patientIdToPatient[_patientId].doctorId) {
            revert NotAuthorized();
        }
        return patientToDiagnosis[_patientId];
    }
}