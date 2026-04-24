from __future__ import annotations

import sys
from collections import Counter
from pathlib import Path

import yaml


EXPECTED_COUNTS = {
    "single-node": Counter(
        {
            "Namespace": 1,
            "ConfigMap": 1,
            "Deployment": 1,
            "Service": 1,
            "Ingress": 1,
            "PodDisruptionBudget": 1,
            "NetworkPolicy": 1,
        }
    ),
    "peer-cluster": Counter(
        {
            "Namespace": 1,
            "Service": 3,
            "Deployment": 2,
            "Ingress": 1,
            "PodDisruptionBudget": 1,
            "NetworkPolicy": 1,
        }
    ),
}


def fail(message: str) -> None:
    print(f"ERROR: {message}", file=sys.stderr)
    raise SystemExit(1)


def read_manifest_text(path: Path) -> str:
    data = path.read_bytes()

    for encoding in ("utf-8-sig", "utf-16", "utf-16-le", "utf-16-be"):
        try:
            return data.decode(encoding)
        except UnicodeDecodeError:
            continue

    fail(f"Manifest file '{path}' could not be decoded as UTF-8 or UTF-16.")


def validate_document(document: dict, index: int) -> tuple[str, str, str]:
    if not isinstance(document, dict):
        fail(f"Document #{index} is not a YAML object.")

    api_version = document.get("apiVersion")
    kind = document.get("kind")
    metadata = document.get("metadata")

    if not api_version:
        fail(f"Document #{index} is missing apiVersion.")
    if not kind:
        fail(f"Document #{index} is missing kind.")
    if not isinstance(metadata, dict):
        fail(f"Document #{index} is missing metadata.")

    name = metadata.get("name")
    if not name:
        fail(f"Document #{index} is missing metadata.name.")

    namespace = metadata.get("namespace", "")
    return kind, namespace, name


def validate_deployments(documents: list[dict]) -> None:
    for index, document in enumerate(documents, start=1):
        if document.get("kind") != "Deployment":
            continue

        containers = (
            document.get("spec", {})
            .get("template", {})
            .get("spec", {})
            .get("containers", [])
        )
        if not containers:
            fail(f"Deployment in document #{index} has no containers.")

        for container in containers:
            if "livenessProbe" not in container:
                fail(
                    f"Deployment {document['metadata']['name']} is missing livenessProbe."
                )
            if "readinessProbe" not in container:
                fail(
                    f"Deployment {document['metadata']['name']} is missing readinessProbe."
                )


def validate_overlay(overlay: str, documents: list[dict]) -> None:
    expected = EXPECTED_COUNTS.get(overlay)
    if expected is None:
        fail(f"Unknown overlay '{overlay}'.")

    counts = Counter(document["kind"] for document in documents)
    if counts != expected:
        fail(f"Overlay '{overlay}' has unexpected resource counts: {counts}.")

    seen = set()
    for index, document in enumerate(documents, start=1):
        kind, namespace, name = validate_document(document, index)
        identity = (kind, namespace, name)
        if identity in seen:
            fail(f"Duplicate resource detected: kind={kind}, namespace={namespace}, name={name}.")
        seen.add(identity)

        if kind != "Namespace" and namespace != "eureka":
            fail(
                f"Resource {kind}/{name} should be namespaced to 'eureka', got '{namespace or '<empty>'}'."
            )

    validate_deployments(documents)


def main() -> None:
    if len(sys.argv) != 3:
        fail("Usage: python scripts/validate_k8s.py <manifest-path> <overlay-name>")

    manifest_path = Path(sys.argv[1])
    overlay = sys.argv[2]

    if not manifest_path.exists():
        fail(f"Manifest file '{manifest_path}' does not exist.")

    manifest_text = read_manifest_text(manifest_path)
    documents = [doc for doc in yaml.safe_load_all(manifest_text) if doc is not None]

    if not documents:
        fail(f"Manifest file '{manifest_path}' is empty.")

    validate_overlay(overlay, documents)
    print(f"Validated {len(documents)} manifest(s) for overlay '{overlay}'.")


if __name__ == "__main__":
    main()
