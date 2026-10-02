// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title VerdiktaValidationAdapter
/// @notice Minimal, opt-in validator-attestation registry for ERC-8004-style agents.
/// @dev `agentId` and `subjectId` are intentionally opaque so an ERC-8004 integration
///      can bind them to its canonical agent and interaction/dispute identifiers.
contract VerdiktaValidationAdapter {
    enum Verdict {
        None,
        Approved,
        Rejected,
        Unresolved
    }

    struct Attestation {
        Verdict verdict;
        bytes32 evidenceHash;
        string evidenceURI;
        uint64 attestedAt;
        address attestor;
    }

    address public owner;
    address public verdiktaAttestor;

    mapping(uint256 agentId => mapping(bytes32 subjectId => Attestation)) private attestations;

    event AttestorUpdated(address indexed previousAttestor, address indexed newAttestor);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event ValidationAttested(
        uint256 indexed agentId,
        bytes32 indexed subjectId,
        Verdict verdict,
        bytes32 evidenceHash,
        string evidenceURI,
        address indexed attestor,
        uint64 attestedAt
    );

    error Unauthorized();
    error ZeroAddress();
    error InvalidVerdict();

    constructor(address initialAttestor) {
        if (initialAttestor == address(0)) revert ZeroAddress();
        owner = msg.sender;
        verdiktaAttestor = initialAttestor;
        emit OwnershipTransferred(address(0), msg.sender);
        emit AttestorUpdated(address(0), initialAttestor);
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert Unauthorized();
        _;
    }

    modifier onlyAttestor() {
        if (msg.sender != verdiktaAttestor) revert Unauthorized();
        _;
    }

    /// @notice Rotates the authorized Verdikta attestor.
    /// @dev Production users should place ownership behind appropriate governance.
    function setVerdiktaAttestor(address newAttestor) external onlyOwner {
        if (newAttestor == address(0)) revert ZeroAddress();
        address previous = verdiktaAttestor;
        verdiktaAttestor = newAttestor;
        emit AttestorUpdated(previous, newAttestor);
    }

    function transferOwnership(address newOwner) external onlyOwner {
        if (newOwner == address(0)) revert ZeroAddress();
        address previous = owner;
        owner = newOwner;
        emit OwnershipTransferred(previous, newOwner);
    }

    /// @notice Publishes the latest validation or dispute outcome for a subject.
    /// @param agentId Canonical agent ID supplied by the consuming ERC-8004 integration.
    /// @param subjectId Keccak-256 ID of the protocol-defined task, interaction, or dispute.
    /// @param verdict The validator outcome; `None` is reserved for absent records.
    /// @param evidenceHash Hash of the exact evidence bundle or manifest.
    /// @param evidenceURI Content-addressed or otherwise durable evidence location.
    function attest(
        uint256 agentId,
        bytes32 subjectId,
        Verdict verdict,
        bytes32 evidenceHash,
        string calldata evidenceURI
    ) external onlyAttestor {
        if (verdict == Verdict.None) revert InvalidVerdict();

        uint64 timestamp = uint64(block.timestamp);
        attestations[agentId][subjectId] = Attestation({
            verdict: verdict,
            evidenceHash: evidenceHash,
            evidenceURI: evidenceURI,
            attestedAt: timestamp,
            attestor: msg.sender
        });

        emit ValidationAttested(agentId, subjectId, verdict, evidenceHash, evidenceURI, msg.sender, timestamp);
    }

    /// @notice Returns the latest attestation. A `None` verdict means no record exists.
    function getAttestation(uint256 agentId, bytes32 subjectId)
        external
        view
        returns (Attestation memory)
    {
        return attestations[agentId][subjectId];
    }
}
