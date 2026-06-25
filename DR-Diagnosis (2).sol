// SPDX-License-Identifier: MIT

pragma solidity ^0.8.34;

contract DRDiagnosisResuls{
    // access control of db and data
    // data store krna BC pr
    // patints ki entry - registration

    struct Patient {
        uint patientId;
        address doctorId;
        uint timestamp;
    }

    struct Diagnosis{
        bytes32 diagnosisImageHash;
        uint diagnosisResultCategory;
        uint patientId;
        address doctorId;
        uint timestamp;
    }

    // Patient[] patients;

    address immutable owner;

    mapping (uint => Diagnosis[]) patientToDiagnosis;
    mapping (uint => Patient) patientIdToPatient;
    mapping (address => uint[]) doctorToPatientId; 

    error NotOwner();
    error NotAuthorized();
    error PatientAlreadyExist();

    event PatientRegistered(uint patientId, address doctorAddress);
    event DiagnosisUploaded(uint patientId, uint diagnosisResut, uint timestamp);

    modifier onlyOwner(){
        if(msg.sender != owner){
            revert NotOwner();
        }
        _;
    }    

    constructor(){
        owner = msg.sender;
    }

    // concerned doctor/pateints and hospital admin can access
        // admin (owner): Doctors authorize karna, Patients register karna 
        // Doctor: Diagnosis upload karna 
        // Patient: Sirf apna record dekhna


    // only admin/owner can access
    // registration: patient id, timestamp, doctor address assigned to this pateint
    // should not register if patientId already in use -- patient id should be unique across all data  
    function registerPatient(uint256 _patientId, address _doctorAddress) public onlyOwner{
        
        if (patientIdToPatient[_patientId].timestamp != 0){
            revert PatientAlreadyExist();
        }
        
        Patient memory patient = Patient(_patientId, _doctorAddress, block.timestamp);
        patientIdToPatient[_patientId] = patient;
        doctorToPatientId[_doctorAddress].push(_patientId);
        emit PatientRegistered(_patientId,_doctorAddress);
    }

    // only doctor can access
    // data: hash of image,diagnosis result, patient id, doctor address jsne upload kia, timestamp
    function uploadDiagnosis(uint patientId, bytes32 imageHash, uint diagnosisResult) external{
        if(patientIdToPatient[patientId].doctorId != msg.sender){
            revert NotAuthorized();
        }
        patientToDiagnosis[patientId].push(
        Diagnosis(imageHash, diagnosisResult, patientId, msg.sender, block.timestamp));
        emit DiagnosisUploaded(patientId, diagnosisResult, block.timestamp);
    }

    function viewPatients() external view returns(uint[] memory){
        return doctorToPatientId[msg.sender];
    }

    // doctor for its concerned patinets and admin for anyone
    // should be accessible for patients
    // if patient not exist should return error
    function viewRecords(uint _patientId) external view returns(Diagnosis[] memory){
        if(msg.sender != owner && msg.sender != patientIdToPatient[_patientId].doctorId){
            revert NotAuthorized();
        }
        return patientToDiagnosis[_patientId];
    }
}